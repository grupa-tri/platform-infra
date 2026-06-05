# This is the main documentation file for documenting AI usage

## Terraform basics

### Prompt

> Set up the basic Terraform scaffolding for a GCP project. I need `versions.tf`, `variables.tf`, and `providers.tf` — pin Terraform and the Google provider, add variables for project ID, region and zone, and wire the provider to them. No hardcoded project ID, just the three files.

### Validated

Checked latest google version https://registry.terraform.io/providers/hashicorp/google/latest
Checked latest terraform version https://github.com/hashicorp/terraform

performed
```bash
terraform init -> success

terraform validate -> success
```