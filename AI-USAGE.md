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

## Network

### Prompt

> Add a `network.tf` for GCP with a custom VPC (no auto subnets), a regional subnet with secondary ranges for GKE pods and services, plus a Cloud Router and NAT for outbound traffic. Use environment-prefixed resource names and variables for the CIDR blocks. Depend on the enabled project APIs.

### Validated

Checked VPC, subnet secondary ranges, and Cloud NAT docs:
https://cloud.google.com/vpc/docs
https://cloud.google.com/nat/docs/overview

performed

```bash
terraform validate -> success

terraform plan -> plan looking good
```

## Cloud DNS managed zone

### Prompt

> I need to add a `dns.tf` that creates the public Cloud DNS managed zone for the platform domain. It should depend on the enabled GCP APIs. Use an environment-prefixed name and a variable for the domain. Also consider suggestions for `outputs.tf` and `variables.tf` so the zone nameservers are exposed and the domain is configurable.

### Validated

Checked the managed zone resource and confirmed `visibility` defaults to public, but set it explicitly since the zone has to be public for ExternalDNS and cert-manager:
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone

Verified the `dns_name` has to be a FQDN ending with a trailing dot before applying.

performed

```bash
terraform fmt                 -> no changes
terraform init -backend=false -> success
terraform validate            -> Success!
tflint                        -> no issues
```

## GKE Service Account

> Create a Google service account for kubernetes nodes in Terraform with needed IAM bindings.

### Validated

Checked Google documentatio. https://docs.cloud.google.com/kubernetes-engine/security/configure-node-service-accounts

performed

```bash
terraform validate -> success
```

## Flux GitOps bootstrap

### Prompt

> Add the Flux bootstrap to the existing flat Terraform setup: configure the `flux` provider from the GKE cluster (endpoint, CA cert, access token) and add `flux_bootstrap_git` at the root. Git auth (url, branch, user, token) must come from variables and the token must never be committed.

### Validated

Pinned the provider to `~> 1.8`; `terraform init` resolved this to flux v1.8.8:
https://registry.terraform.io/providers/fluxcd/flux/latest

Configured the `flux` provider's `kubernetes` and `git` blocks based on the official GitHub-PAT bootstrap example, adapted to GKE: the cluster connection uses a short-lived token from `data.google_client_config.default.access_token` plus `base64decode` of `master_auth[0].cluster_ca_certificate` — no client certs and no kubeconfig file.

Set `depends_on` on the node pool as well as the cluster, otherwise the Flux controllers would stay Pending with no schedulable nodes.

performed

​`bash
terraform fmt                 -> formatted providers.tf
terraform init -backend=false -> flux v1.8.8 installed, lock updated
terraform validate            -> Success!
tflint                        -> no issues
​`

## Apply script

### Promt

> Erstelle mir ein shell script um einen angegebenen bucket für den terraform state zu erstellen und anschließend terraform apply ausführt. Achte darauf das dafür ein eigener service account genutzt wird.

### Validated

Checked script with own knowledge and tested it.

performed

```bash
./apply.sh
```
