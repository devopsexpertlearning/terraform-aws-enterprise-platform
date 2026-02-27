# Environment: dev

This folder is a standalone Terraform root for the **dev** environment.

## Scope
`dev` is the full integration environment. Its `main.tf` is wired to run plan coverage across all modules and submodules in `modules/`.

## Prerequisites
- Terraform `>= 1.9.0`
- Valid AWS credentials for the dev account
- Updated values in `terraform.tfvars` (`ami_id`, `db_secret_string`, DNS zone, ARNs)

## Initialize
Use one of the following:

1. Local backend (default):
```bash
terraform init
```

2. Remote backend (optional, for shared state):
```bash
terraform init -backend-config=backend.hcl
```

`backend.hcl` is configured for S3 lockfile locking (`use_lockfile = true`).

## Validate and Plan

```bash
terraform validate
terraform plan -var-file=terraform.tfvars
```

## Apply (Optional)

```bash
terraform apply -var-file=terraform.tfvars
```

## What You Change
- `backend.hcl`: state bucket/key/region (only if using remote backend).
- `terraform.tfvars`: environment-specific values like CIDRs, AMI, database secret, DNS names, tags.

## Troubleshooting
- `No valid credential sources found`: set AWS credentials/profile.
- Backend errors: verify `backend.hcl` values and access permissions.
- Validation failures: run `terraform fmt -recursive` and re-run `terraform validate`.
