resource "kubernetes_config_map_v1" "ldap_data_cm" {
  metadata {
    name      = "ldap-data-cm"
    namespace = kubernetes_namespace.ldap.id
  }

  data = {
    "hashibank.ldif" = file("./03 - manifests/ldap/hashibank.ldif")
  }
}

resource "kubernetes_manifest" "ldap_statefulset" {
  depends_on = [
    kubernetes_job_v1.vault_init
  ]

  manifest = provider::kubernetes::manifest_decode(local.openldap_statefulset)
}

resource "kubernetes_manifest" "ldap_service" {
  depends_on = [
    kubernetes_job_v1.vault_init
  ]

  manifest = provider::kubernetes::manifest_decode(local.openldap_service)
}

resource "kubernetes_manifest" "phpldapadmin_service" {
  depends_on = [
    kubernetes_job_v1.vault_init
  ]

  manifest = provider::kubernetes::manifest_decode(local.phpldapadmin_service)
}

resource "kubernetes_manifest" "ldap_ingress" {
  depends_on = [
    kubernetes_job_v1.vault_init
  ]

  manifest = provider::kubernetes::manifest_decode(local.openldap_ingress)
}