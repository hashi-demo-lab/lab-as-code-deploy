variable "vault_cert_pem" {
  description = "PEM-encoded LDAP certificate"
  type        = string
}

variable "vault_private_key_pem" {
  description = "PEM-encoded LDAP private key"
  type        = string
}

variable "ca_cert_pem" {
  description = "The CA certificate PEM"
  type        = string
}

variable "vault_version" {
  type        = string
  description = "Vault Version"
  default     = "latest"
}

variable "vault_helm_version" {
  type        = string
  description = "Vault's Helm Release Version"
  default     = "~> 0"
}

variable "vault_release_name" {
  description = "The Helm release name for the Vault deployment"
  type        = string
  default     = "vault"
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

variable "vault_namespace" {
  type        = string
  description = "Namespace for Vault"
}

variable "vault_init_script" {
  description = "contents of vault-init.sh script"
  type        = string
}

variable "vault_helm" {
  description = "Helm values for deploying Vault"
  type        = string
}

variable "vso_helm" {
  description = "Helm values for deploying Vault Secrets Operator"
  type        = string
  default     = null
}

variable "vault_ha_enabled" {
  description = "Enable high availability mode for Vault"
  type        = bool
  default     = true
}

variable "vault_replicas" {
  description = "Number of Vault replicas for HA mode"
  type        = number
  default     = 3
}

variable "configure_seal" {
  description = "Whether to configure the seal stanza"
  type        = bool
  default     = false
}

variable "auto_unseal_addr" {
  description = "The address of the auto-unseal Vault to be used by the primary Vault"
  type        = string
  default     = "auto-unseal-vault-0.auto-unseal-vault-internal.auto-unseal-vault.svc.cluster.local:8200"
}

variable "auto_unseal_key_name" {
  description = "The transit key name to use for auto unseal"
  type        = string
  default     = "autounseal"
}

variable "vault_mode" {
  description = "Mode of this Vault deployment: 'primary' or 'auto_unseal'"
  type        = string
}
