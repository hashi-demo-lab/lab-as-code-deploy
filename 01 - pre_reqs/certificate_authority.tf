provider "tls" {}

# Step 1: Create the CA private key
resource "tls_private_key" "ca_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Step 2: Create the CA self-signed certificate
resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_tls_key.private_key_pem
  validity_period_hours = 87600 # CA certificate valid for 10 years
  early_renewal_hours   = 720   # Renew 30 days before expiration
  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]

  subject {
    common_name  = "vault-ca"
    organization = "HashiCorp"
  }
}

# Output the CA certificate and private key as files
resource "local_file" "ca_cert" {
  filename = "${path.module}/ca_cert.pem"
  content  = tls_self_signed_cert.ca_cert.cert_pem
}

resource "local_file" "ca_key" {
  filename = "${path.module}/ca_key.pem"
  content  = tls_private_key.ca_tls_key.private_key_pem
}

output "ca_cert_pem_path" {
  value = local_file.ca_cert.filename
}

output "ca_key_pem_path" {
  value = local_file.ca_key.filename
}
