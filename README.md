# Repository Documentation

## Github Actions

Terraform formatting, validation, and linting checks run automatically on every pull request.

## Terraform

This repo manages GCP infrastructure with Terraform. Version constraints and provider configuration are defined in `versions.tf` and `providers.tf` input variables in `variables.tf`.

| Component | Source | Version |
| --- | --- | --- |
| Terraform | — | `>= 1.10.0` |
| Google provider | `hashicorp/google` | `~> 7.0` |

| Variable | Description | Default |
| --- | --- | --- |
| `project_id` | GCP project ID | — |
| `region` | Primary region | `europe-west3` |
| `zone` | Zone location | `europe-west3-a` |

## Required services

The following GCP APIs are enabled automatically via `apis.tf` when Terraform is applied:

| Service | API |
| --- | --- |
| Compute Engine | `compute.googleapis.com` |
| Kubernetes Engine | `container.googleapis.com` |
| Cloud DNS | `dns.googleapis.com` |
| Secret Manager | `secretmanager.googleapis.com` |
| IAM | `iam.googleapis.com` |
| Cloud Resource Manager | `cloudresourcemanager.googleapis.com` |
| Cloud Storage | `storage.googleapis.com` |
| Cloud Logging | `logging.googleapis.com` |
