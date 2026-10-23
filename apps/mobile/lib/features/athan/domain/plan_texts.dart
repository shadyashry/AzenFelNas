import 'package:daily_muslim/features/athan/domain/plan_text_key.dart';
import 'package:dm_contracts/dm_contracts.dart';

/// Port: the pre-rendered `ar` and `en` copy of a plan entry (§7.7). Native
/// code renders it as given and never formats text itself.
///
/// Contract: total and pure; every string is non-empty.
abstract interface class PlanTexts {
  /// The notification title of [key].
  LocalizedText title(PlanTextKey key);

  /// The notification body of [key].
  LocalizedText body(PlanTextKey key);
}
