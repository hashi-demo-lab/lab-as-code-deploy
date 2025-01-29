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
  default = [
    "vault.vault.svc.cluster.local",
    "vault-active.vault.svc.cluster.local",
    "vault-standby.vault.svc.cluster.local",
    "vault-0.vault.svc.cluster.local",
    "vault-1.vault.svc.cluster.local",
    "vault-2.vault.svc.cluster.local",
    "vault-0.vault-internal.vault.svc.cluster.local",
    "vault-1.vault-internal.vault.svc.cluster.local",
    "vault-2.vault-internal.vault.svc.cluster.local",
    "vault-dc1.hashibank.com",
    "vault-active.hashibank.com",
    "vault-standby.hashibank.com"
  ]
}

variable "vault_common_name" {
  type        = string
  description = "Common name for Vault certificate"
  default     = "vault-dc1.hashibank.com"
}

variable "organization" {
  type        = string
  description = "Organization name for both Vault and LDAP certificates"
  default     = "HashiBank"
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
  default = [
    "ldap.hashibank.com",
    "phpldapadmin.hashibank.com",
    "openldap.ldap.svc.cluster.local",
    "openldap-0.ldap.svc.cluster.local",
    "openldap-phpldapadmin.ldap.svc.cluster.local"
  ]
}

variable "ldap_common_name" {
  type        = string
  description = "Common name for LDAP certificate"
  default     = "ldap.hashibank.com"
}

variable "gitlab_runner_token" {
  description = "GitLab runner registration token"
  type        = string
  sensitive   = true # To keep the token secure
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