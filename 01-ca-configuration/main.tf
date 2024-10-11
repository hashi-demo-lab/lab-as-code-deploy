# main.tf
resource "tls_private_key" "ca_tls_key" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem       = tls_private_key.ca_tls_key.private_key_pem
  validity_period_hours = var.validity_period_hours
  early_renewal_hours   = var.early_renewal_hours
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]

  subject {
    common_name  = var.ca_common_name
    organization = var.ca_organization
  }
}
