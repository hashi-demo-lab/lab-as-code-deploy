# variables.tf
variable "ca_common_name" {
  description = "Common name for the self-signed CA certificate"
  type        = string
  default     = "vault-ca"
}

variable "ca_organization" {
  description = "Organization name for the self-signed CA certificate"
  type        = string
  default     = "lab-as-code"
}

variable "rsa_bits" {
  description = "Number of bits for the RSA private key"
  type        = number
  default     = 4096
}

variable "validity_period_hours" {
  description = "Validity period of the CA certificate in hours"
  type        = number
  default     = 87600 # 10 years
}

variable "early_renewal_hours" {
  description = "How many hours before the certificate expires that it should be renewed"
  type        = number
  default     = 720 # 30 days
}

variable "cert_filename" {
  description = "Filename for storing the generated CA certificate"
  type        = string
  default     = "ca_cert.pem"
}

variable "key_filename" {
  description = "Filename for storing the generated CA private key"
  type        = string
  default     = "ca_key.pem"
}
