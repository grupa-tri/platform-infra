variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary region"
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "Zone location"
  type        = string
  default     = "europe-west3-a"
}

variable "environment" {
  description = "Environment name used in resource names."
  type        = string
  default     = "group-c"
}

variable "subnet_cidr" {
  description = "Primary subnet CIDR."
  type        = string
  default     = "10.10.0.0/20"
}

variable "pods_cidr" {
  description = "Secondary range for GKE pods."
  type        = string
  default     = "10.20.0.0/16"
}

variable "services_cidr" {
  description = "Secondary range for GKE services."
  type        = string
  default     = "10.30.0.0/20"
}

variable "domain_name" {
  description = "Public domain for ExternalDNS and cert-manager DNS-01. Must end with a dot, e.g. platform.example.com."
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name."
  type        = string
  default     = "cluster"
}

variable "node_count" {
  description = "Node count for cluster."
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "Machine type which is applied."
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Boot disk size per node."
  type        = number
  default     = 30
}

variable "git_token" {
  type      = string
  sensitive = true
}

variable "git_url" {
  type = string
}

variable "git_user" {
  type = string
}

variable "git_branch" {
  type    = string
  default = "main"
}

variable "flux_cluster_path" {
  type    = string
  default = "clusters/my-cluster"
}