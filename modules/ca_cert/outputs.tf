# Export the raw PEM data for direct use in other Terraform resources
output "ca_cert_pem" {
  description = "The CA certificate PEM"
  value       = tls_self_signed_cert.ca_cert.cert_pem
}

output "ca_key_pem" {
  description = "The CA private key PEM"
  value       = tls_private_key.ca_tls_key.private_key_pem
}

# Export the file paths to the CA certificate and private key for use by external tools
output "ca_cert_pem_path" {
  description = "Path to the CA certificate PEM file on the local filesystem"
  value       = local_file.ca_cert.filename
}

output "ca_key_pem_path" {
  description = "Path to the CA private key PEM file on the local filesystem"
  value       = local_file.ca_key.filename
}
