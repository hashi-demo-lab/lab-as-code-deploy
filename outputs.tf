output "vault_address" {
    value = "https://${var.vault_common_name}:443"
}

output "vault_ca_cert" {
    value = module.ca_cert.cert_file_path
}

output "https_ldap_common_name" {
    value = var.ldap_common_name
}

# output "cert_full_path" {
#     value = "${path.root}/${module.ca_cert.cert_file_path}"
# }

output "command_trust_cert" {
    value = "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${path.root}/${module.ca_cert.cert_file_path}"
}

output "command_update_etc_hosts" {
    #update /etc/hosts
    value = "sudo echo \"${var.vault_common_name} 127.0.0.1\" >> /etc/hosts \nsudo echo \"${var.ldap_common_name} 127.0.0.1\" >> /etc/hosts"
}
