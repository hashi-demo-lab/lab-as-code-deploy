variable "vault_version" {
  type        = string
  description = "Vault Version"
  default     = "latest"
}

variable "vault_license" {
  type        = string
  description = "Vault License"
}

variable "vault_helm_version" {
  type        = string
  description = "Vault's Helm Release Version"
  default     = "~> 0"
}

variable "prometheus_helm_version" {
  type        = string
  description = "Prometheus Helm Release Version"
  default     = "~> 24"
}

variable "prometheus_targets" {
  type    = list(string)
  default = ["vault-active.vault.svc.cluster.local:8200"]
}

variable "grafana_helm_version" {
  type        = string
  description = "Grafana Helm Release Version"
  default     = "~> 7"
}

variable "github_organization" {
  type        = string
  description = "GitHub Organization"
}