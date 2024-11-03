variable "kube_config_path" {
  type        = string
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config" # Default path on Mac
}

variable "kube_config_context" {
  type        = string
  description = "Kubeconfig context to use"
  default     = "docker-desktop"
}

variable "vault_license" {
  type        = string
  description = "Vault License"
}

variable "vault_dns_names" {
  type        = list(string)
  description = "DNS names for Vault certificate"
}

variable "vault_common_name" {
  type        = string
  description = "Common name for Vault certificate"
}

variable "organization" {
  type        = string
  description = "Organization name for both Vault and LDAP certificates"
}

variable "prometheus_helm_version" {
  type        = string
  description = "Prometheus Helm Release Version"
  default     = "~> 24"
}

# variable "prometheus_targets" {
#   type    = list(string)
#   default = ["vault-active.vault.svc.cluster.local:8200"]
# }

variable "grafana_helm_version" {
  type        = string
  description = "Grafana Helm Release Version"
  default     = "~> 7"
}

variable "ldap_dns_names" {
  type        = list(string)
  description = "DNS names for LDAP certificate"
}

variable "ldap_common_name" {
  type        = string
  description = "Common name for LDAP certificate"
}

# variable "github_organization" {
#   type        = string
#   description = "GitHub Organization"
# }

# variable "oidc_client_id" {
#   type        = string
#   description = "value of the client_id"
# }

# variable "oidc_client_secret" {
#   type        = string
#   description = "value of the client_secret"
# }