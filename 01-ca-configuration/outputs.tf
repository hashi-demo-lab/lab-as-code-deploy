# outputs.tf
output "ca_cert_pem" {
  description = "The generated CA certificate in PEM format"
  value       = tls_self_signed_cert.ca_cert.cert_pem
}

output "ca_key_pem" {
  description = "The generated CA private key in PEM format"
  value       = tls_private_key.ca_tls_key.private_key_pem
  sensitive = true
}
