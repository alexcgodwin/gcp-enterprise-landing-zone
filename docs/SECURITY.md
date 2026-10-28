# Security model and threat boundaries

## Threats considered

| Risk | Mitigation in this project | Remaining work |
| --- | --- | --- |
| Accidental organizational policy change | Guardrails explicitly disabled unless approved | Cross-team policy review and exceptions |
| Leaked JSON service account keys | Opt-in short-lived OIDC federation, org key restrictions | Disable legacy keys everywhere appropriate |
| GitHub name takeover | Restrict to immutable numeric owner/repo IDs | Pin trust further to workflow identity/environment if adding deployment |
| Cross-environment pivoting | Separate Shared VPC host projects and per-subnet IAM | IAM Deny, Firewall Policies, dedicated perimeters |
| Public exposure | No ingress allow rules, Private Google Access | Review LB/front-door design and hierarchical firewall inheritance |
| Lost Terraform state | Versioned, private GCS bucket and stack-level separation | Key/backup recovery testing, disaster recovery |
| Audit log tampering | GCS retention, public access prevention, narrow sink writer role | IAM separation, legal hold/bucket lock decision, immutable SIEM sink |
| Excess egress/exfiltration | Private VMs supported without external IPs | **Cloud NAT does not restrict destinations**; add egress policy and perimeter controls |
| Production drift | GitHub static CI and manual approved plan/apply | Scheduled drift checks, attestations, policy-as-code |

## Minimum privilege

The Terraform operator has elevated bootstrap permissions by necessity; prefer time-limited group membership or an auditable privileged identity. Project application teams should not be granted write access to host-project networking. The sink receives **objectCreator**, not Storage Admin; archive readers should be a separately approved group.

## What this does not do

This repository does not configure VPC Service Controls, hierarchical firewall policies, Security Command Center, Cloud Armor, KMS, enterprise SSO, organizational budgets/alerts, production monitoring, GKE, Private Service Connect or regulated compliance standards. It cannot certify CIS, ISO 27001, SOC 2 or PCI DSS compliance. Address those items in an organization-specific security program before production use.

## Repository security

GitHub Actions is read-only and cannot deploy. No repository secrets are required. State, `.tfvars`, backend configuration, credentials and saved plans are ignored by Git. The local security check catches obvious tracked artifacts; run a dedicated secrets scanner and IaC security review before merging to regulated environments. Use branch protection, CODEOWNERS and required checks at the GitHub repository level.

To report a serious vulnerability, use GitHub's private vulnerability reporting where available rather than opening a public issue containing exploit details or credentials.
