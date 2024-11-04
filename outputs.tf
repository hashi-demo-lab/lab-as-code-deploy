output "vault_address" {
    value = "https://${var.vault_common_name}:443"
}

output "vault_ca_cert" {
    value = module.ca_cert.cert_file_path
}

output "https_ldap_common_name" {
    value = var.ldap_common_name
}

output "grafana_address" {
    value = "http://localhost:3000" 
}

output "prometheus_address" {
    value = "http://localhost:9090" 
}


output "command_trust_cert" {
    value = "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${path.root}/${module.ca_cert.cert_file_path}"
}

output "command_update_etc_hosts" {
    #update /etc/hosts
    value = "echo -e 127.0.0.1 ${var.vault_common_name} | sudo tee -a /etc/hosts > /dev/null\necho -e 127.0.0.1 ${var.ldap_common_name}| sudo tee -a /etc/hosts > /dev/null"
}

