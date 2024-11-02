resource "tls_private_key" "vault_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "vault_cert_req" {
  private_key_pem = tls_private_key.vault_tls_key.private_key_pem
  dns_names       = var.vault_dns_names

  subject {
    common_name  = var.vault_common_name
    organization = var.organization
  }
}

resource "tls_locally_signed_cert" "vault_cert" {
  cert_request_pem   = tls_cert_request.vault_cert_req.cert_request_pem
  ca_private_key_pem = var.ca_key_pem
  ca_cert_pem        = var.ca_cert_pem

  validity_period_hours = 8760 # 1 year
  early_renewal_hours   = 720  # 1 month
  allowed_uses          = [ "key_encipherment", "digital_signature", "server_auth" ]
}

resource "kubernetes_secret_v1" "vault_tls" {
  metadata {
    name      = "vault-certificate"
    namespace = "vault"
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.vault_cert.cert_pem
    "tls.key" = tls_private_key.vault_tls_key.private_key_pem
    "ca.crt"  = var.ca_cert_pem
  }

  type = "kubernetes.io/tls"
}