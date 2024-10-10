# Define local variables for various file paths and sensitive data used in the configuration
locals {
  # CA Private Key and Certificate used for signing Vault certificates
  ca_private_key_pem = file("./01 - pre_reqs/ca_key.pem")  # Path to the CA private key file
  ca_cert_pem        = file("./01 - pre_reqs/ca_cert.pem") # Path to the CA certificate file

  # Vault Helm chart values and root token extraction
  vault_helm        = file("./02 - helm_charts/vault/values.vault.yaml") # Helm values for deploying Vault
  vault_init_script = file("./02 - helm_charts/vault/vault-init.sh")
  vault_root_token  = nonsensitive(data.kubernetes_secret.vault_init_credentials.data["root-token"])
  # Vault root token extracted from Kubernetes secret (marked as nonsensitive for readability in outputs)

  # OpenLDAP manifests for deployment and services
  openldap_statefulset = file("./03 - manifests/ldap/statefulset.yaml")          # OpenLDAP StatefulSet manifest
  openldap_service     = file("./03 - manifests/ldap/ldap_service.yaml")         # OpenLDAP Service manifest
  phpldapadmin_service = file("./03 - manifests/ldap/phpldapadmin_service.yaml") # phpLDAPadmin Service manifest
  openldap_ingress     = file("./03 - manifests/ldap/ingress.yaml")              # Ingress for OpenLDAP and phpLDAPadmin
  hashibank_ldif       = file("./03 - manifests/ldap/hashibank.ldif")            # LDIF file for initializing LDAP with data

  # Prometheus Helm chart and ConfigMap for monitoring
  prometheus_configmap = file("./02 - helm_charts/prometheus/configmap.yaml")         # Prometheus ConfigMap for scrape configs
  prometheus_helm      = file("./02 - helm_charts/prometheus/values.prometheus.yaml") # Helm values for Prometheus deployment

  # Grafana Helm chart and ConfigMap for dashboards
  grafana_configmap = file("./02 - helm_charts/grafana/configmap.yaml")      # Grafana ConfigMap for dashboards and configs
  grafana_helm      = file("./02 - helm_charts/grafana/values.grafana.yaml") # Helm values for Grafana deployment
}
