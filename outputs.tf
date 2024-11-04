output "vault_address" {
    value = "https://${var.vault_common_name}:443"
}

output "vault_ca_cert" {
    value = module.ca_cert.cert_file_path
}

output "https_ldap_common_name" {
    value = var.ldap_common_name
  
}