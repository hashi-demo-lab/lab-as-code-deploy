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