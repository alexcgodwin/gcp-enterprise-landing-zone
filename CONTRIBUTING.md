# Contributing

Changes should be small, reversible and supported by an architecture reason.

1. Open a change proposal for organization policy, IAM, network CIDR or retention changes.
2. Run `terraform fmt -recursive`, `terraform init -backend=false`, and `terraform validate` for every changed stack.
3. Check that no credentials, Terraform plans, state files, or non-example variable files are tracked.
4. Document cost, blast radius, rollback and any new required GCP IAM roles.
5. Do not add cloud deployment workflows or credential-bearing fixtures without a security review.

An accepted pull request is not permission to apply it to an organization.
