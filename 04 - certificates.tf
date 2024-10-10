# Reusable values for certificates (validity, renewal, uses)
locals {
  validity_period_hours = 8760 # 1 year
  early_renewal_hours   = 720  # 1 month
  allowed_cert_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Vault Certificate and TLS Secret
resource "tls_private_key" "vault_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "vault_cert_req" {
  private_key_pem = tls_private_key.vault_tls_key.private_key_pem

  dns_names = var.vault_dns_names

  subject {
    common_name  = var.vault_common_name
    organization = var.organization
  }
}

resource "tls_locally_signed_cert" "vault_cert" {
  cert_request_pem   = tls_cert_request.vault_cert_req.cert_request_pem
  ca_private_key_pem = local.ca_private_key_pem
  ca_cert_pem        = local.ca_cert_pem

  validity_period_hours = local.validity_period_hours
  early_renewal_hours   = local.early_renewal_hours

  allowed_uses = local.allowed_cert_uses
}

resource "kubernetes_secret_v1" "vault_tls" {
  metadata {
    name      = "vault-certificate" # Consistent and clear naming
    namespace = kubernetes_namespace.namespace["vault"].id
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.vault_cert.cert_pem
    "tls.key" = tls_private_key.vault_tls_key.private_key_pem
    "ca.crt"  = local.ca_cert_pem
  }

  type = "kubernetes.io/tls"
}

# OpenLDAP Certificate and TLS Secret
resource "tls_private_key" "ldap_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "ldap_cert_req" {
  private_key_pem = tls_private_key.ldap_tls_key.private_key_pem

  dns_names = var.ldap_dns_names

  subject {
    common_name  = var.ldap_common_name
    organization = var.organization
  }
}

resource "tls_locally_signed_cert" "ldap_cert" {
  cert_request_pem   = tls_cert_request.ldap_cert_req.cert_request_pem
  ca_private_key_pem = local.ca_private_key_pem
  ca_cert_pem        = local.ca_cert_pem

  validity_period_hours = local.validity_period_hours
  early_renewal_hours   = local.early_renewal_hours

  allowed_uses = local.allowed_cert_uses
}

resource "kubernetes_secret_v1" "ldap_tls" {
  metadata {
    name      = "ldap-certificate" # Consistent and clear naming
    namespace = kubernetes_namespace.namespace["ldap"].id
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.ldap_cert.cert_pem
    "tls.key" = tls_private_key.ldap_tls_key.private_key_pem
    "ca.crt"  = local.ca_cert_pem
  }

  type = "Opaque"
}
