variable "ldap_namespace" {
  description = "Namespace where LDAP resources are deployed"
  type        = string
}

variable "openldap_statefulset" {
  description = "Content of the OpenLDAP StatefulSet YAML manifest"
  type        = string
}

variable "openldap_service" {
  description = "Content of the OpenLDAP Service YAML manifest"
  type        = string
}

variable "phpldapadmin_service" {
  description = "Content of the phpLDAPadmin Service YAML manifest"
  type        = string
}

variable "openldap_ingress" {
  description = "Content of the LDAP Ingress YAML manifest"
  type        = string
}

variable "ldap_ldif_data" {
  description = "LDIF data for initializing OpenLDAP with data"
  type        = string
}
