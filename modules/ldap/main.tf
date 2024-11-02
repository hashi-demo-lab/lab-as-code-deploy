# ConfigMap for LDAP Data
resource "kubernetes_config_map_v1" "ldap_data_cm" {
  metadata {
    name      = "ldap-data-cm"
    namespace = var.ldap_namespace
  }

  data = {
    "hashibank.ldif" = var.ldap_ldif_data
  }
}

# Kubernetes manifest for OpenLDAP StatefulSet
resource "kubernetes_manifest" "ldap_statefulset" {

  manifest = yamldecode(var.openldap_statefulset)
}

# Kubernetes manifest for OpenLDAP Service
resource "kubernetes_manifest" "ldap_service" {

  manifest = yamldecode(var.openldap_service)
}

# Kubernetes manifest for phpLDAPadmin Service
resource "kubernetes_manifest" "phpldapadmin_service" {

  manifest = yamldecode(var.phpldapadmin_service)
}

# Kubernetes manifest for LDAP Ingress
resource "kubernetes_manifest" "ldap_ingress" {

  manifest = yamldecode(var.openldap_ingress)
}
