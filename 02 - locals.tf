locals {
  ca_private_key_pem = file("./01 - pre_reqs/ca_key.pem")
  ca_cert_pem        = file("./01 - pre_reqs/ca_cert.pem")

  vault_helm       = file("./02 - helm_charts/vault/values.vault.yaml")
  vault_root_token = nonsensitive(data.kubernetes_secret.vault_init_credentials.data["root-token"])

  openldap_statefulset = file("./03 - manifests/ldap/statefulset.yaml")
  openldap_service     = file("./03 - manifests/ldap/ldap_service.yaml")
  phpldapadmin_service = file("./03 - manifests/ldap/phpldapadmin_service.yaml")
  openldap_ingress     = file("./03 - manifests/ldap/ingress.yaml")
  hashibank_ldif       = file("./03 - manifests/ldap/hashibank.ldif")

  prometheus_configmap = file("./02 - helm_charts/prometheus/configmap.yaml")
  prometheus_helm      = file("./02 - helm_charts/prometheus/values.prometheus.yaml")

  grafana_configmap = file("./02 - helm_charts/grafana/configmap.yaml")
  grafana_helm      = file("./02 - helm_charts/grafana/values.grafana.yaml")
}