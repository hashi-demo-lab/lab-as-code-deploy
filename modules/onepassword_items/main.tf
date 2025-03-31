terraform {
  required_providers {
    onepassword = {
      source  = "1password/onepassword"
      version = "~> 2.1.2"
    }
  }
}

variable "enabled" {
  type    = bool
  default = true
}

variable "vault_lab_name" {
  type = string
}

variable "primary_vault_root_token" {
  type = string
}

variable "auto_unseal_vault_root_token" {
  type = string
}

data "onepassword_vault" "vault_lab" {
  count = var.enabled ? 1 : 0
  name  = var.vault_lab_name
}

resource "onepassword_item" "primary_vault_root_token" {
  count    = var.enabled ? 1 : 0
  vault    = data.onepassword_vault.vault_lab[0].uuid
  title    = "HashiCorp Vault Lab Root Token"
  category = "login"
  url      = "https://vault.hashibank.com/"
  username = "token"
  password = var.primary_vault_root_token
}

resource "onepassword_item" "auto_unseal_vault_root_token" {
  count    = var.enabled ? 1 : 0
  vault    = data.onepassword_vault.vault_lab[0].uuid
  title    = "HashiCorp Vault (auto_unseal_vault) Lab Root Token"
  category = "login"
  url      = "https://auto-unseal-vault.hashibank.com/"
  username = "token"
  password = var.auto_unseal_vault_root_token
}