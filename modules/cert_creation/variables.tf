# modules/cert_creation/variables.tf

variable "common_name" {
  description = "Common name for the certificate"
  type        = string
}

variable "organization" {
  description = "Organization name for the certificate subject"
  type        = string
}

variable "dns_names" {
  description = "DNS names for the certificate"
  type        = list(string)
  default     = []
}

variable "is_ca_certificate" {
  description = "Whether the certificate is a CA certificate"
  type        = bool
  default     = false
}

variable "ca_private_key_pem" {
  description = "CA private key PEM, required if not a self-signed CA"
  type        = string
  default     = ""
}

variable "ca_cert_pem" {
  description = "CA certificate PEM, required if not a self-signed CA"
  type        = string
  default     = ""
}

variable "validity_period_hours" {
  description = "Validity period for the certificate in hours"
  type        = number
  default     = 8760  # Default to 1 year
}

variable "early_renewal_hours" {
  description = "Hours before expiration when renewal is allowed"
  type        = number
  default     = 720  # Default to 1 month
}

variable "save_to_file" {
  description = "Whether to save the certificate and key to local files"
  type        = bool
  default     = false
}

variable "cert_file_name" {
  description = "File name for the certificate"
  type        = string
}

variable "key_file_name" {
  description = "File name for the private key"
  type        = string
}
