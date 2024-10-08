# Vault certificate
resource "tls_private_key" "vault_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "vault_cert_req" {
  private_key_pem = tls_private_key.vault_tls_key.private_key_pem

  dns_names = [
    "vault-active.vault.svc.cluster.local",
    "vault.vault.svc.cluster.local",
    "vault-0.vault.svc.cluster.local",
    "vault-1.vault.svc.cluster.local",
    "vault-2.vault.svc.cluster.local",
    "vault-0.vault-internal.vault.svc.cluster.local",
    "vault-1.vault-internal.vault.svc.cluster.local",
    "vault-2.vault-internal.vault.svc.cluster.local",
    "vault-dc1.hashibank.com"
  ]

  subject {
    common_name  = "vault-dc1.hashibank.com"
    organization = "HashiCorp"
  }
}

resource "tls_locally_signed_cert" "vault_cert" {
  cert_request_pem   = tls_cert_request.vault_cert_req.cert_request_pem
  ca_private_key_pem = local.ca_private_key_pem
  ca_cert_pem        = local.ca_cert_pem

  validity_period_hours = 8760 # 1 year
  early_renewal_hours   = 720

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret_v1" "vault_tls" {
  metadata {
    name      = "vaultcertificate"
    namespace = kubernetes_namespace.vault.id
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.vault_cert.cert_pem
    "tls.key" = tls_private_key.vault_tls_key.private_key_pem
    "ca.crt"  = local.ca_cert_pem
  }

  type = "kubernetes.io/tls"
}

# OpenLDAP Certificate
resource "tls_private_key" "ldap_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "ldap_cert_req" {
  private_key_pem = tls_private_key.ldap_tls_key.private_key_pem

  dns_names = [
    "ldap.hashibank.com",
    "phpldapadmin.hashibank.com",
    "openldap.ldap.svc.cluster.local",
    "openldap-0.ldap.svc.cluster.local",
    "openldap-phpldapadmin.ldap.svc.cluster.local"
  ]

  subject {
    common_name  = "ldap.hashibank.com"
    organization = "HashiCorp"
  }
}

resource "tls_locally_signed_cert" "ldap_cert" {
  cert_request_pem   = tls_cert_request.ldap_cert_req.cert_request_pem
  ca_private_key_pem = local.ca_private_key_pem
  ca_cert_pem        = local.ca_cert_pem

  validity_period_hours = 8760
  early_renewal_hours   = 720

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret_v1" "ldap_tls" {
  metadata {
    name      = "ldap-secrets"
    namespace = kubernetes_namespace.ldap.id
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.ldap_cert.cert_pem
    "tls.key" = tls_private_key.ldap_tls_key.private_key_pem
    "ca.crt"  = local.ca_cert_pem
  }

  type = "Opaque"
}