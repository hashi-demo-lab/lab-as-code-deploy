# ConfigMap for LDAP Data
resource "kubernetes_config_map_v1" "ldap_data_cm" {
  metadata {
    name      = "ldap-data-cm"
    namespace = kubernetes_namespace.namespace["ldap"].id
  }

  data = {
    "hashibank.ldif" = file("./03 - manifests/ldap/hashibank.ldif") # Loading LDIF file for LDAP initialization
  }
}

# Kubernetes manifest for OpenLDAP StatefulSet
resource "kubernetes_manifest" "ldap_statefulset" {
  depends_on = [
    kubernetes_job_v1.vault_init # Ensure Vault is initialized before deploying LDAP
  ]

  manifest = provider::kubernetes::manifest_decode(local.openldap_statefulset) # Decoding the manifest from local file
}

# Kubernetes manifest for OpenLDAP Service
resource "kubernetes_manifest" "ldap_service" {
  depends_on = [
    kubernetes_job_v1.vault_init # Ensure Vault is initialized before deploying the LDAP service
  ]

  manifest = provider::kubernetes::manifest_decode(local.openldap_service) # Decoding the manifest from local file
}

# Kubernetes manifest for phpLDAPadmin Service
resource "kubernetes_manifest" "phpldapadmin_service" {
  depends_on = [
    kubernetes_job_v1.vault_init # Ensure Vault is initialized before deploying phpLDAPadmin service
  ]

  manifest = provider::kubernetes::manifest_decode(local.phpldapadmin_service) # Decoding the manifest from local file
}

# Kubernetes manifest for LDAP Ingress
resource "kubernetes_manifest" "ldap_ingress" {
  depends_on = [
    kubernetes_job_v1.vault_init # Ensure Vault is initialized before deploying LDAP ingress
  ]

  manifest = provider::kubernetes::manifest_decode(local.openldap_ingress) # Decoding the manifest from local file
}
