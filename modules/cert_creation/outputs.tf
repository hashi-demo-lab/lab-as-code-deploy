output "cert_pem" {
  description = "The PEM-encoded certificate"
  value       = var.is_ca_certificate ? tls_self_signed_cert.ca_cert[0].cert_pem : tls_locally_signed_cert.signed_cert[0].cert_pem
}

output "private_key_pem" {
  description = "The PEM-encoded private key"
  value       = tls_private_key.tls_key.private_key_pem
}

output "cert_file_path" {
  description = "Path to the saved certificate file, or null if not saved"
  value       = length(local_file.cert_file) > 0 ? local_file.cert_file[0].filename : null
}

output "key_file_path" {
  description = "Path to the saved private key file, or null if not saved"
  value       = length(local_file.key_file) > 0 ? local_file.key_file[0].filename : null
}

