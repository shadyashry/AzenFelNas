import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/activate_staged.dart';
import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/channel_trust.dart';
import 'package:dm_packages/src/client/network_kind.dart';
import 'package:dm_packages/src/client/package_event.dart';
import 'package:dm_packages/src/client/package_file_state.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/client/ports/fetch_channel.dart';
import 'package:dm_packages/src/client/ports/package_trust_store.dart';
import 'package:dm_packages/src/client/ports/read_network_kind.dart';
import 'package:dm_packages/src/client/ports/read_package_catalog.dart';
import 'package:dm_packages/src/client/ports/record_package_event.dart';
import 'package:dm_packages/src/client/select_targets.dart';
import 'package:dm_packages/src/client/stage_target.dart';
import 'package:dm_packages/src/client/sync_outcome.dart';
import 'package:dm_packages/src/client/sync_policy.dart';
import 'package:dm_packages/src/client/sync_report.dart';
import 'package:dm_packages/src/client/target_choice.dart';
import 'package:dm_packages/src/tuf/tuf_metadata.dart';
import 'package:dm_packages/src/tuf/tuf_signed.dart';
import 'package:dm_packages/src/verify/metadata_files.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:dm_packages/src/verify/package_failure.dart';
import 'package:dm_packages/src/verify/signed_envelope.dart';
import 'package:dm_packages/src/verify/trusted_root.dart';
import 'package:dm_packages/src/verify/verified_metadata.dart';
import 'package:dm_packages/src/verify/verify_metadata_chain.dart';

/// One sync of the package channel on app open (§7.4): at most every 6 h,
/// the four metadata files on any network, the chain verified against the
/// last trusted root (rotation per Appendix C), then each chosen target
/// staged and activated. Large payloads wait for an unmetered network
/// unless `urgent` (REQ-PKG-004). Every failure leaves the last-known-good
/// active (REQ-PKG-001); expiry only warns (REQ-PKG-002). Never in the
/// alarm path.
final class SyncPackages {
  /// The use case over its ports; `embeddedRoot` holds the root keys built
  /// into the app.
  const new({
    required this._network,
    required this._trust,
    required this._fetch,
    required this._verify,
    required this._embeddedRoot,
    required this._catalog,
    required this._stage,
    required this._activate,
    required this._events,
    this._policy = const SyncPolicy(),
  });

  final ReadNetworkKind _network;
  final PackageTrustStore _trust;
  final FetchChannel _fetch;
  final VerifyMetadataChain _verify;
  final TrustedRoot _embeddedRoot;
  final ReadPackageCatalog _catalog;
  final StageTarget _stage;
  final ActivateStaged _activate;
  final RecordPackageEvent _events;
  final SyncPolicy _policy;

  static const SelectTargets _select = SelectTargets();

  /// Runs one sync at [nowUtcMs].
  Future<SyncReport> call({required int nowUtcMs}) async {
    final trust = await _trust.read();
    if (!_policy.due(lastSyncUtcMs: trust.lastSyncUtcMs, nowUtcMs: nowUtcMs)) {
      return SyncReport(outcome: SyncOutcome.skippedInterval);
    }
    final network = await _network();
    if (network == NetworkKind.offline) {
      return SyncReport(outcome: SyncOutcome.offline);
    }
    final attempt = ChannelTrust(
      rootJson: trust.rootJson,
      sequences: trust.sequences,
      lastSyncUtcMs: nowUtcMs,
      lastVerifiedUtcMs: trust.lastVerifiedUtcMs,
    );
    if (await _trust.write(attempt) case Err(:final failure)) {
      return await _failed(failure, nowUtcMs, null);
    }
    final MetadataFiles files;
    final int? serverDate;
    switch (await _fetchMetadata()) {
      case Ok(:final value):
        (files, serverDate) = value;
      case Err(:final failure):
        return await _failed(failure, nowUtcMs, null);
    }
    final verified = await _verify(
      files: files,
      trustedRoot: _anchor(trust),
      trusted: trust.sequences,
      nowUtcMs: nowUtcMs,
    );
    return switch (verified) {
      Err(:final failure) => await _failed(failure, nowUtcMs, serverDate),
      Ok(:final value) => await _accept(
        value,
        files,
        attempt,
        network,
        serverDate,
      ),
    };
  }

  Future<SyncReport> _accept(
    VerifiedMetadata verified,
    MetadataFiles files,
    ChannelTrust attempt,
    NetworkKind network,
    int? serverDate,
  ) async {
    final nowUtcMs = attempt.lastSyncUtcMs;
    final trusted = ChannelTrust(
      rootJson: files.root,
      sequences: verified.sequences,
      lastSyncUtcMs: nowUtcMs,
      lastVerifiedUtcMs: verified.warnings.isEmpty
          ? nowUtcMs
          : attempt.lastVerifiedUtcMs,
    );
    if (await _trust.write(trusted) case Err(:final failure)) {
      return await _failed(failure, nowUtcMs, serverDate);
    }
    if (verified.warnings.isNotEmpty) {
      await _events.record(
        FreshnessUnverified(
          utcMs: nowUtcMs,
          expiredRoles: verified.warnings.length,
        ),
      );
    }
    final choices = _select(
      verified.targets,
      active: {for (final a in await _catalog.activeAll()) a.type: a},
      refusedNames: await _refused(),
      todayUtc: _utcDate(nowUtcMs),
    );
    final unchanged =
        verified.sequences.timestamp == attempt.sequences.timestamp;
    final report = await _install(
      choices,
      verified,
      network,
      nowUtcMs,
      unchanged && choices.isEmpty
          ? SyncOutcome.upToDate
          : SyncOutcome.completed,
      serverDate,
    );
    await _events.record(
      SyncFinished(
        utcMs: nowUtcMs,
        outcome: report.outcome.wire,
        activated: report.activated.length,
        failure: report.targetFailures.values.firstOrNull?.code,
      ),
    );
    return report;
  }

  Future<SyncReport> _install(
    List<TargetChoice> choices,
    VerifiedMetadata verified,
    NetworkKind network,
    int nowUtcMs,
    SyncOutcome outcome,
    int? serverDate,
  ) async {
    final activated = <ActivePackage>[];
    final deferred = <String>[];
    final failures = <String, PackageFailure>{};
    for (final choice in choices) {
      if (!_policy.mayDownload(choice.target, network)) {
        deferred.add(choice.name);
        continue;
      }
      final result = switch (await _stage(choice, nowUtcMs: nowUtcMs)) {
        Ok(value: final staged) => await _activate(
          staged,
          sequence: verified.sequences.targets,
          nowUtcMs: nowUtcMs,
        ),
        Err(:final failure) => Result<ActivePackage, PackageFailure>.err(
          failure,
        ),
      };
      switch (result) {
        case Ok(:final value):
          activated.add(value);
        case Err(:final failure):
          failures[choice.name] = failure;
      }
    }
    return SyncReport(
      outcome: outcome,
      activated: activated,
      deferred: deferred,
      targetFailures: failures,
      warnings: verified.warnings,
      serverDateUtcMs: serverDate,
    );
  }

  Future<SyncReport> _failed(
    PackageFailure failure,
    int nowUtcMs,
    int? serverDate,
  ) async {
    await _events.record(
      SyncFinished(
        utcMs: nowUtcMs,
        outcome: SyncOutcome.failed.wire,
        activated: 0,
        failure: failure.code,
      ),
    );
    return SyncReport(
      outcome: SyncOutcome.failed,
      failure: failure,
      serverDateUtcMs: serverDate,
    );
  }

  /// The four files, and the `Date` header of `timestamp.json`.
  Future<Result<(MetadataFiles, int?), PackageFailure>> _fetchMetadata() async {
    final fetched = <MetadataRole, List<int>>{};
    int? serverDate;
    for (final role in MetadataRole.values) {
      switch (await _fetch.metadata(
        role,
        maxBytes: SyncPolicy.maxMetadataBytes,
      )) {
        case Ok(:final value):
          fetched[role] = value.bytes;
          if (role == MetadataRole.timestamp) {
            serverDate = value.serverDateUtcMs;
          }
        case Err(:final failure):
          return Result.err(failure);
      }
    }
    List<int> file(MetadataRole role) => fetched[role] ?? const [];
    return Result.ok((
      MetadataFiles(
        root: file(MetadataRole.root),
        timestamp: file(MetadataRole.timestamp),
        snapshot: file(MetadataRole.snapshot),
        targets: file(MetadataRole.targets),
      ),
      serverDate,
    ));
  }

  /// The last verified root's root role, or the embedded keys before the
  /// first sync or if the stored root no longer parses.
  TrustedRoot _anchor(ChannelTrust trust) {
    final stored = trust.rootJson;
    if (stored == null) return _embeddedRoot;
    return switch (SignedEnvelope.parse(MetadataRole.root, stored)) {
      Ok(
        value: SignedEnvelope(
          metadata: TufMetadata(signed: final TufRootSigned root),
        ),
      ) =>
        TrustedRoot.ofRoot(root),
      _ => _embeddedRoot,
    };
  }

  /// Target names the client refused or rolled back from (`garbage`).
  Future<Set<String>> _refused() async => {
    for (final type in PackageType.values)
      for (final file in await _catalog.files(type))
        if (file.state == PackageFileState.garbage)
          '${type.wire}/${file.version}',
  };

  static String _utcDate(int utcMs) => DateTime.fromMillisecondsSinceEpoch(
    utcMs,
    isUtc: true,
  ).toIso8601String().substring(0, 10);
}
