output "vault_root_token" {
  depends_on = [
    data.kubernetes_secret.vault_init_credentials
    ] # Ensure it depends in Vault initialization
  
  value = nonsensitive(data.kubernetes_secret.vault_init_credentials.data["root-token"])
  sensitive  = false
}
