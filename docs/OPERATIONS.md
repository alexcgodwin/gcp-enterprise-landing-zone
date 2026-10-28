# Operations runbook

## Day-2 checks

- Weekly: review IAM membership, GCS state access, budget anomalies, security findings and failed organization log exports.
- After every change: record the approved plan, state serial/version, resource diff and cloud audit trail.
- Monthly: inspect VPC Flow Logs and NAT errors, subnets/route usage, quota pressure, organization policy exceptions, and Terraform provider updates.
- Quarterly: test restore of versioned state (in an isolated project), test denied OIDC from untrusted repos, review retention/legal requirements.

## Lost Terraform state or stale locking

1. Stop concurrent CI/local applies and identify the operator/process holding the lock.
2. Confirm exact backend bucket and prefix. Review GCS object versions and Cloud Audit Logs.
3. Back up the current state object before recovery.
4. Use state restore/import under a documented incident/change procedure; `terraform force-unlock` only after confirming no active apply and recording the lock ID.
5. Run plan and compare expected vs observed resources before resuming.

## Missing org audit logs

Check the organization sink destination/filter, bucket writer member, IAM propagation, Log Router availability and Data Access audit logging configuration. Storage export may be delayed. Verify with a new test event from an approved sandbox. Never widen archive access to troubleshoot casually.

## Broken Shared VPC attachment

Confirm host and service projects are in one organization, Compute Engine API is enabled in both, and Shared VPC administrator permissions are present. Inspect subnet IAM membership for workload service accounts. Check required project service agents, org policies and quotas before retrying. Avoid detaching any service project with active workloads.

## NAT and egress failure

Verify route to default internet gateway, subnet NAT coverage, router/NAT region, NAT error logs, available port capacity and policy/firewall routing. Private Google Access is not a blanket guarantee of private reachability for every Google API; evaluate restricted/private.googleapis.com routes and DNS separately as needed.

## Changing organization policy

Check effective inherited constraints and blast radius before apply. Scope test to a disposable nonproduction organization or folder whenever feasible. Keep a rollback plan approved by Org Policy Admins; policy changes can break workload creation operations even when existing workloads continue running.

## Ownership

This repository defines a baseline pattern. Assign actual service owners, escalation contacts, paging targets and recovery time objectives before putting it into production. No production monitoring alert or on-call integration is provisioned automatically.
