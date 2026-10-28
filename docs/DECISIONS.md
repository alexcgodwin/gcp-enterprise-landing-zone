# Architecture decision records

## ADR-001: Independent production and nonproduction networks

**Decision:** Two Shared VPC host projects rather than one host with two subnets. **Reason:** A network trust boundary should not depend on labels or convenience. **Trade-off:** More projects, routing, NAT and cost.

## ADR-002: Separate Terraform roots and backend prefixes

**Decision:** Bootstrap, foundation, network and identity are separate state boundaries. **Reason:** Reduce accidental organization-level changes during normal networking work. **Trade-off:** Explicit dependency passing and additional setup effort.

## ADR-003: CI cannot deploy

**Decision:** GitHub Actions runs only formatting, validation and repository hygiene. **Reason:** No cloud tenancy or operator approval process is assumed; a public example must not carry privileged deployment credentials. **Trade-off:** Users must add gated and reviewed CD if appropriate.

## ADR-004: Numeric OIDC identity validation

**Decision:** Provider trust requires immutable GitHub account and repository IDs plus the main branch. **Reason:** Names can be renamed and repos deleted/recreated. **Trade-off:** Repo recreation requires deliberate identity rotation.

## ADR-005: Opt-in organization guardrails

**Decision:** Policies that affect the whole organization default to off. **Reason:** Disabling service-account keys or default networking can break existing teams. **Trade-off:** Operators must actively enable secure baselines after impact review.

## ADR-006: Cloud NAT and audit archive are minimal components

**Decision:** Private subnets use NAT and organization audit log export to a bucket. **Reason:** Demonstrate central control without claiming to deliver an entire enterprise security stack. **Trade-off:** Dedicated egress filtering, advanced logging, threat detection, KMS, SIEM and budget controls are future layers.
