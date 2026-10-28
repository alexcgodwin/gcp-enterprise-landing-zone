# Deployment guide

This guide is for an **approved GCP organization administrator/platform engineer**. Do not paste secrets or use privileged personal keys in source control. Commands below are intentionally manual, require a real GCP account, and can generate charges.

## 0. Preconditions

- An existing Google Cloud organization and domain/identity controls.
- An approved billing account and a separate existing bootstrap project with billing linked.
- Appropriate roles delegated by an administrator for folders, project creation, billing association, API activation, organization policies (only if opting in), logging export, Shared VPC administration, and relevant IAM. Use a short-lived identity, not broad permanent privileges.
- Terraform >= 1.6, Google provider 7.x, gcloud or Workload Identity Federation for authentication, Git and a reviewed IP address plan.
- Enable the required Resource Manager, Cloud Billing, Service Usage, Org Policy, Logging and IAM APIs in the administering context as appropriate. Creating first projects may require an initial human bootstrap phase.
- Non-overlapping RFC1918 CIDRs, a region/legal data residency decision, a deletion recovery plan, costs/quotas, and an approved audit retention period.

## 1. Preflight without cloud access

```bash
terraform fmt -check -recursive
cd stacks/foundation
terraform init -backend=false -input=false
terraform validate
```

Repeat init/validate inside each stack. This checks syntax and provider schemas, **not** IAM privileges, organization constraints, quotas, costs or runtime behavior.

## 2. Bootstrap the state bucket

```bash
cd stacks/bootstrap
cp terraform.tfvars.example terraform.tfvars  # set your values locally
terraform init -backend=false
terraform plan -out=tfplan
terraform show tfplan                       # review before approval
terraform apply tfplan
```

Once the bucket is verified, back up the local state securely. Copy `backend.tf.example` to `backend.tf` (do not commit your environment-specific backend copy if it includes sensitive metadata), copy `backend.hcl.example` to `backend.hcl`, set bucket/prefix, and run:

```bash
terraform init -migrate-state -backend-config=backend.hcl
```

Confirm that the new state is readable and the local copy is secured/removed under policy. **Never erase a state object to “fix” a lock.** Ensure bucket IAM grants only approved operators and break-glass admins. Consider customer-managed encryption keys, Access Transparency and state-recovery procedures for regulated environments.

## 3. Foundation

```bash
cd stacks/foundation
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
# Edit all example IDs and set the state bucket; keep guardrails false initially.
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output project_ids
```

**Organization policy is disabled by default.** To enable, review effective policies and exemptions with the GCP organization administrators first, then set `enable_organization_policies = true`, perform a new plan, and obtain an explicit organization-wide change approval. Do not toggle existing organization policies blindly. Existing folders/projects may need `terraform import` rather than creation.

The audit sink can start exporting only after the identity exists and the bucket writer IAM grant is applied. Check actual log arrival; some Data Access events are not generated without service-specific audit logging configuration. Some GCS exports are batched/delayed.

## 4. Networking

```bash
cd stacks/network
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
# Use exact project IDs from foundation outputs and non-overlapping approved CIDRs.
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

Production and development host projects must be in the same organization as their service projects. Shared VPC needs appropriate organization permissions. Do **not** add broad subnet IAM grants; put only trusted `user:`, `group:` or `serviceAccount:` members under the correct environment in `subnet_users`.

## 5. Identity (optional)

```bash
cd stacks/identity
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
```

The example IDs are for this repository's **public** GitHub account/repo identifiers; verify them again with `gh api users/alexcgodwin --jq .id` and `gh api repos/alexcgodwin/gcp-enterprise-landing-zone --jq .id`. Review the OIDC trust expression and create separate approved permissions for the service account **only if** a deployment workflow is later designed. CI here does not request tokens or apply anything.

## 6. Acceptance checks after approved apply

1. Validate folder lineage and billing on each created project.
2. Check the effective organization policies for new projects and any previously managed descendants.
3. Confirm distinct prod/dev VPC host projects and Shared VPC attachments.
4. Confirm private subnets, Private Google Access, flow log emission and Cloud NAT (test with an approved temporary workload).
5. Verify no internet ingress is unintentionally allowed by inherited hierarchical firewall policies or workload configuration.
6. Confirm organization audit logs appear in the archive and that unauthorized principals cannot read or delete them.
7. Test federation with an approved main-branch workflow only after roles are reviewed; confirm untrusted branches/other repos are denied.
8. Capture a post-change cost baseline, log export volume, drift, IAM review, and alert requirements.

## Rollback and recovery

Treat organization policy rollback, Shared VPC detachment, project removal and storage retention changes as separately approved operations. Reversal is **not always safe** if active workloads depend on resources. Use state version history to restore corrupted Terraform state under a documented break-glass process; do not casually use force-unlock. `prevent_destroy` and project deletion prevention intentionally block easy destructive applies.
