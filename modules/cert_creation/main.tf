# Generate private key
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate certificate signing request (CSR)
resource "tls_cert_request" "cert_req" {
  private_key_pem = tls_private_key.tls_key.private_key_pem
  dns_names       = var.dns_names

  subject {
    common_name  = var.common_name
    organization = var.organization
  }
}

# Conditional resource for CA certificate (self-signed)
resource "tls_self_signed_cert" "ca_cert" {
  count = var.is_ca_certificate ? 1 : 0

  private_key_pem = tls_private_key.tls_key.private_key_pem
  validity_period_hours = var.validity_period_hours
  early_renewal_hours   = var.early_renewal_hours
  is_ca_certificate   = true
  set_subject_key_id  = true
  set_authority_key_id = true
  
  allowed_uses = ["cert_signing"]

  subject {
    common_name  = var.common_name
    organization = var.organization
  }
}

# Conditional resource for non-CA certificates signed by a CA
resource "tls_locally_signed_cert" "signed_cert" {
  count = var.is_ca_certificate ? 0 : 1

  cert_request_pem   = tls_cert_request.cert_req.cert_request_pem
  ca_private_key_pem = var.ca_private_key_pem
  ca_cert_pem        = var.ca_cert_pem
  validity_period_hours = var.validity_period_hours
  early_renewal_hours   = var.early_renewal_hours
  allowed_uses = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "local_file" "cert_file" {
  count    = var.save_to_file ? 1 : 0
  filename = "${path.module}/${var.cert_file_name}"
  content  = var.is_ca_certificate ? tls_self_signed_cert.ca_cert[0].cert_pem : tls_locally_signed_cert.signed_cert[0].cert_pem
}

resource "local_file" "key_file" {
  count    = var.save_to_file ? 1 : 0
  filename = "${path.module}/${var.key_file_name}"
  content  = tls_private_key.tls_key.private_key_pem
}
