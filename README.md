# GCP Enterprise Landing Zone

> Terraform-based, security-first Google Cloud foundations for enterprise platform teams.

[![Terraform CI](https://github.com/alexcgodwin/gcp-enterprise-landing-zone/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/alexcgodwin/gcp-enterprise-landing-zone/actions/workflows/terraform-ci.yml)
![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.6-844FBA)
![GCP](https://img.shields.io/badge/Google_Cloud-Landing_Zone-4285F4)
![Status](https://img.shields.io/badge/Status-Reference_Implementation-informational)

## Why this project exists

A reliable cloud platform starts with resource boundaries, identity, networking, governance, and auditability—not virtual machines. This is an opinionated starting point for setting up **Google Cloud at an organizational scale** using version-controlled infrastructure.

**Project status:** Source-code reference implementation. It has NOT been deployed to a real GCP organization, and passing CI does not prove live readiness. Applying it creates chargeable resources and can alter organization-wide policies.

## Architecture

```text
Google Cloud Organization
├── Platform/               Common organizational boundary
├── Security/
│   └── central-audit        Organization audit logs → restricted GCS bucket
├── Production/
│   ├── prod-net-host        Dedicated Shared VPC host (prod only)
│   └── prod-app             Production service project
└── Nonproduction/
    ├── dev-net-host         Dedicated Shared VPC host (nonprod only)
    └── dev-app              Development service project

GitHub ── static checks ── review ── manual terraform plan/apply
    └── optional OIDC federation (numeric repository and owner binding)

GCS: bootstrap creates a versioned bucket; each layer uses a distinct state prefix.
```

## What's implemented

| Area | Design |
| --- | --- |
| Governance | Folders, project factory, organization guardrails (disabled by default) |
| Environment isolation | Independent production/nonproduction Shared VPC hosts |
| Private networking | Custom-mode VPC, subnet flow logs, Private Google Access, Cloud NAT |
| Secure-by-default | No public ingress rule; opt-in subnet IAM grants |
| Central security | Aggregated org audit sink, locked-down GCS log bucket with retention |
| Secretless identity | Optional GitHub OIDC / GCP Workload Identity Federation |
| State discipline | Separate bootstrap bucket and backend prefixes; protection against deletion |
| Continuous integration | Terraform format, init/validate and secret-oriented static checks |
| Operations | Decision log, deployment steps, security boundaries, incident runbook |

## Repository

```text
.github/workflows/terraform-ci.yml
modules/project/                  Reusable project factory
stacks/bootstrap/                 State bucket (existing bootstrap project)
stacks/foundation/                Folders, projects, baseline policy, audit export
stacks/network/                   Production and development Shared VPCs
stacks/identity/                  Optional identity federation for GitHub
 docs/                            Architecture, deployment, threat model, runbooks
```

## Quick start

1. Read [Deployment](docs/DEPLOYMENT.md) and [Security](docs/SECURITY.md) before setting any variable.
2. Prepare an **existing** GCP organization, billing account, and bootstrap project. Use an approved operator identity with least-privilege grants.
3. Copy each layer's `terraform.tfvars.example` to **untracked** `terraform.tfvars`. Provide your own project IDs, subnet ranges and billing account ID. No credentials belong in this repository.
4. Validate with `terraform fmt -check -recursive`, `terraform init -backend=false`, and `terraform validate` from the stack directory.
5. Apply the bootstrap stack locally, then configure **separate** GCS state prefixes per stack and migrate the state by following the deployment guide.
6. Review and apply the foundation stack, then the network stack, then optionally the identity stack. **Nothing automatically applies on push.**

## Key engineering decisions

- **Blast-radius control:** Separate remote state per layer, separate VPC hosts per trust boundary, and no cross-environment firewall grants.
- **Least privilege:** No primitive Owner/Editor grants, no automatic access to service subnets, no static service account keys.
- **Auditability:** Sink writer is granted *objectCreator* on a single audit bucket; retention is enabled without irreversibly locking the bucket.
- **Secure networking:** Private Google Access plus NAT. NAT enables outbound communication; it is **not** an egress firewall or data-exfiltration control.
- **Guardrail safety:** Organization policies are off until explicitly enabled after a change assessment.
- **Cost control:** NAT, logs, GCS objects, network traffic, and premium security products can incur charges. No cost estimates are promised.

## References

- [Google Cloud landing zone design](https://docs.cloud.google.com/architecture/landing-zones)
- [Google Cloud enterprise foundations](https://docs.cloud.google.com/architecture/security-foundations)
- [Organization policies](https://docs.cloud.google.com/organization-policy/overview)
- [Shared VPC](https://docs.cloud.google.com/vpc/docs/shared-vpc)
- [GCP Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)

MIT License. See [LICENSE](LICENSE).
