# Platform Infrastructure

This repo bootstraps our Kubernetes platform on Google Cloud. It creates the VPC, GKE cluster, DNS zone, service accounts, and Flux. Everything after bootstrap is managed in [platform-gitops](https://github.com/grupa-tri/platform-gitops).

The platform runs a multi-tenant todo app. Each tenant gets an isolated instance with its own Postgres database, backend, and frontend.

## Status

Day 1 bootstrap is done.

- VPC and zonal GKE cluster `group-c-cluster` in `europe-west3-a`
- Workload Identity for platform components
- Cloud DNS zone for `upondi.com`
- Flux bootstrapped against platform-gitops

Day 2 service catalog is active.

- Crossplane `ApplicationInstance` provisions tenant stacks
- ExternalDNS, cert-manager, External Secrets Operator, CloudNativePG

Live tenants

- https://tenant-a.upondi.com
- https://tenant-b.upondi.com

## Live endpoints

Each tenant host serves the frontend at `/` and the backend API at `/api`.

| Path             | Method | Description          |
| ---------------- | ------ | -------------------- |
| `/health`        | GET    | Backend health check |
| `/api/todos`     | GET    | List todos           |
| `/api/todos`     | POST   | Create todo          |
| `/api/todos/:id` | PATCH  | Update todo          |
| `/api/todos/:id` | DELETE | Delete todo          |

Full API details are in [app-backend](https://github.com/grupa-tri/app-backend).

## Related repositories

| Repository                                                      | Visibility | Purpose                          |
| --------------------------------------------------------------- | ---------- | -------------------------------- |
| [platform-infra](https://github.com/grupa-tri/platform-infra)   | public     | IaC bootstrap (this repo)        |
| [platform-gitops](https://github.com/grupa-tri/platform-gitops) | public     | Flux GitOps, Crossplane, tenants |
| [app-backend](https://github.com/grupa-tri/app-backend)         | public     | REST API and container image     |
| [app-frontend](https://github.com/grupa-tri/app-frontend)       | private    | React SPA and container image    |

## Bootstrap the platform

One-time setup. After this, the cluster reconciles itself from Git.

**Prerequisites**

- gcloud CLI with access to project `turing-cell-497816-p0`
- Terraform `>= 1.10`

**Steps**

1. Create `terraform.tfvars` in this repo (not committed). Required values are `project_id`, `domain_name` (must end with a dot, e.g. `upondi.com.`), `git_url`, `git_user`, and `git_token`.
2. Run `./apply.sh`. This creates the Terraform state bucket, service account, and applies all infrastructure.
3. Set your domain registrar nameservers to the output of `terraform output dns_name_servers`.
4. Store the GHCR pull secret in GCP Secret Manager under the key `ghcr-dockerconfigjson`. The frontend image is private and tenant pods need this to pull it.

Steps 3 and 4 are manual glue points. Everything else is automated through Terraform and Flux.

## How to add a tenant

Add a new `ApplicationInstance` YAML in [platform-gitops](https://github.com/grupa-tri/platform-gitops). Follow [How to contribute](#how-to-contribute) to get the change merged.

After merge, Flux reconciles and Crossplane creates the namespace, database, app, DNS record, and TLS certificate.

## How to update app versions

Bump the image tags in [environmentconfig-app-images.yaml](https://github.com/grupa-tri/platform-gitops/blob/main/clusters/my-cluster/infrastructure/crossplane-infra/environmentconfig-app-images.yaml) in platform-gitops. All tenants pick up the change on the next reconciliation.

To test a version on one tenant first, override `backendImage` or `frontendImage` in that tenant's YAML.

## How to contribute

This workflow applies to all platform repositories.

1. Open an issue in the repo you are changing. Use the Task issue template with Goal, Scope, and Acceptance criteria. Templates live in `.github/ISSUE_TEMPLATE/` in each repo.
2. Create a branch from `main`. Use a short name like `feat/tenant-c` or `fix/terraform-lint`.
3. Commit with Conventional Commits. Format is `type(scope): subject`. Allowed types are `feat`, `fix`, `docs`, `chore`, `refactor`, and `ci`. Put the issue reference in the commit body, not the title.

```
feat(gitops): add tenant-c application instance

Refs #42
```

4. Open a pull request against `main`. Fill in the PR template. Use `Closes #42` in the PR description when the change completes the issue.
5. All CI checks must pass before merge. No merge commits. Changes reach `main` only through verified pull requests.

| Repo                       | PR checks                       |
| -------------------------- | ------------------------------- |
| platform-infra             | Terraform fmt, validate, tflint |
| platform-gitops            | kubeconform                     |
| app-backend / app-frontend | typecheck, build                |

## CI

Pull requests run Terraform fmt, validate, and tflint via [.github/workflows/terraform.yml](.github/workflows/terraform.yml).

## Github Actions

Terraform formatting, validation, and linting checks run automatically on every pull request.

## Terraform

This repo manages GCP infrastructure with Terraform. Version constraints and provider configuration are defined in `versions.tf` and `providers.tf` input variables in `variables.tf`.

| Component       | Source             | Version     |
| --------------- | ------------------ | ----------- |
| Terraform       | —                  | `>= 1.10.0` |
| Google provider | `hashicorp/google` | `~> 7.0`    |

| Variable     | Description    | Default          |
| ------------ | -------------- | ---------------- |
| `project_id` | GCP project ID | —                |
| `region`     | Primary region | `europe-west3`   |
| `zone`       | Zone location  | `europe-west3-a` |

## Required services

The following GCP APIs are enabled automatically via `apis.tf` when Terraform is applied:

| Service                | API                                   |
| ---------------------- | ------------------------------------- |
| Compute Engine         | `compute.googleapis.com`              |
| Kubernetes Engine      | `container.googleapis.com`            |
| Cloud DNS              | `dns.googleapis.com`                  |
| Secret Manager         | `secretmanager.googleapis.com`        |
| IAM                    | `iam.googleapis.com`                  |
| Cloud Resource Manager | `cloudresourcemanager.googleapis.com` |
| Cloud Storage          | `storage.googleapis.com`              |
| Cloud Logging          | `logging.googleapis.com`              |

### GKE cluster

Terraform provisions a zonal GKE cluster (`group-c-cluster` in `europe-west3-a` by default). Specs are defined in `gke.tf` and `variables.tf`.

| Setting            | Default / value                          |
| ------------------ | ---------------------------------------- |
| Node pool          | `primary` (single pool)                  |
| Nodes              | 3 × `e2-standard-2` (2 vCPU, 8 GB RAM)   |
| Boot disk          | 30 GB `pd-standard` per node             |
| Release channel    | `REGULAR`                                |
| Networking         | VPC-native (`10.10.0.0/20` subnet)       |
| Pod / service CIDR | `10.20.0.0/16` / `10.30.0.0/20`         |
| Workload Identity  | enabled                                  |
| Config Connector   | enabled                                  |
| Node management    | auto-repair and auto-upgrade             |

`node_count`, `machine_type`, and `disk_size_gb` can be overridden in `terraform.tfvars`.
