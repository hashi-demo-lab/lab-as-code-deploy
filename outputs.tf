output "instructions" {
  value = {
    "vault" = {
      "address" = "https://${var.vault_common_name}:443"
      "ca_cert" = module.ca_cert.cert_file_path
      "encoded_ca_cert" = base64encode(module.ca_cert.cert_pem)
      "commands" = {
        "trust_cert"       = "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${path.root}/${module.ca_cert.cert_file_path}"
        "root_token"       = "kubectl config use-context docker-desktop; kubectl get secret vault-init-credentials -n vault -o jsonpath={.data.root-token} | base64 --decode"
        "update_etc_hosts" = "echo -e 127.0.0.1 ${var.vault_common_name} | sudo tee -a /etc/hosts > /dev/null"
      }
    }
    "ldap" = {
      "address" = var.ldap_common_name
      "commands" = {
        "update_etc_hosts" = "echo -e 127.0.0.1 ${var.ldap_common_name} | sudo tee -a /etc/hosts > /dev/null"
      }
    }
    "services" = {
      "grafana"    = "http://localhost:3000"
      "neo4j"      = "http://localhost:7474"
      "prometheus" = "http://localhost:9090"
    }
  }
  sensitive = false
}
