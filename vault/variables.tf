variable "kube_config_path" {
  type        = string
  description = "Path to the kubeconfig file"
  default     = "/kubeconfig/config" # Path inside the container
}

variable "kube_config_context" {
  type        = string
  description = "Kubeconfig context to use"
  default     = "docker-desktop"
}

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