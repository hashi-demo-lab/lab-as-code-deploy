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