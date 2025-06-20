output "root_token" {
  description = "The decoded Vault root token from the vault-init-credentials secret"
  value       = try(nonsensitive(data.kubernetes_secret.vault_init_credentials.data["root-token"]), "")
}

#unseal key if it exists
output "unseal_key" {
  description = "The decoded Vault unseal key from the vault-init-credentials secret"
  value       = try(nonsensitive(data.kubernetes_secret.vault_init_credentials.data["unseal-key"]), "")
}
