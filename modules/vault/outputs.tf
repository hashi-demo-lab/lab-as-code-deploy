output "root_token" {
  description = "The decoded Vault root token from the vault-init-credentials secret"
  value       = nonsensitive(data.kubernetes_secret.vault_init_credentials.data["root-token"])
}
