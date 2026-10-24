# Control-plane restore (§19.4; SEV3: not user-critical, 99.5 % SLO)

**Trigger:** `control-plane /readyz failing`, `control-plane SLO burn rate`, a bad migration, data loss. **Owner:** Backend.

The app works without the control plane: corrections and telemetry fail softly. Restore calmly.

1. **Stop the bleeding:** a bad release is rolled back first. In Cloud Run, send 100 % of traffic to the previous revision (`gcloud run services update-traffic control-plane --to-revisions <prev>=100 --region <region>`).
2. **Data loss or a bad migration:** Cloud SQL point-in-time recovery (7 days) into a new instance:
   `gcloud sql instances clone <instance> <instance>-restore --point-in-time <RFC3339>`. Then point the `control-plane-database-url` secret at it (new version) and redeploy, or `terraform apply` with the restored instance name.
3. **Region or infrastructure loss:** `cd infra/terraform/control-plane && terraform apply` (owner credentials). Then run **deploy-control-plane**, which runs the tests, builds and pushes, runs the `migrate` job, rolls out and smoke-tests `/readyz`.
4. **Verify:** `/readyz` 200 through `api.dailymuslim.app`; a test correction with a dev attestation on a staging build; the purge job's next run succeeds.
5. **Quarterly drill:** step 2 into a throw-away instance, then `cmd/api migrate` and the smoke test against it. Record the time taken.
