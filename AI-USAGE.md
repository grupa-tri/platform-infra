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
