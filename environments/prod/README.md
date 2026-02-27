# Environment: prod

This folder is a standalone Terraform root for the **prod** environment.

## Deploy

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## What You Change
- `backend.hcl`: state bucket/key/region (only if using remote backend).
- `terraform.tfvars`: environment-specific values like CIDRs, instance size, AMI, tags.
