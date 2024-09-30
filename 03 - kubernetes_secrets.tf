# Creating Vault Enterprise License Secret
resource "kubernetes_secret_v1" "vault_license" {
  metadata {
    name      = "vaultlicense"
    namespace = kubernetes_namespace.vault.id
  }
  data = {
    license = var.vault_license

  }
  type = "kubernetes.io/opaque"
}

# Step 3: Create the private key for the Vault TLS certificate
resource "tls_private_key" "vault_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Step 4: Create the Vault certificate signed by the CA
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
  ca_private_key_pem = file("./pre-reqs/ca_key.pem")
  ca_cert_pem        = file("./pre-reqs/ca_cert.pem")

  validity_period_hours = 8760 # 1 year
  early_renewal_hours   = 720  # Renew 1 month in advance

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
    "ca.crt"  = file("./pre-reqs/ca_cert.pem")
  }

  type = "kubernetes.io/tls"
}