# Define local variables for various file paths and sensitive data used in the configuration
locals {
  # CA Private Key and Certificate used for signing Vault certificates
  ca_private_key_pem = module.ca_cert.key_file_path
  ca_cert_pem        = module.ca_cert.cert_file_path

  # Load file contents for Helm values and script for Vault
  vault_helm_values          = file("${path.root}/_helm_charts/vault/values.yaml")
  vault_init_script_contents = file("${path.root}/_scripts/vault/vault-init.sh")
  decoded_root_token         = module.vault.root_token

  # OpenLDAP manifests for deployment and services
  openldap_statefulset = file("${path.root}/_manifests/openldap/statefulset.yaml")
  openldap_service     = file("${path.root}/_manifests/openldap/ldap_service.yaml")
  phpldapadmin_service = file("${path.root}/_manifests/openldap/phpldapadmin_service.yaml")
  openldap_ingress     = file("${path.root}/_manifests/openldap/ingress.yaml")
  ldap_ldif_data       = file("${path.root}/_manifests/openldap/hashibank.ldif")
  # openldap_statefulset = file("./_manifests/openldap/statefulset.yaml")          # OpenLDAP StatefulSet manifest
  # openldap_service     = file("./_manifests/openldap/ldap_service.yaml")         # OpenLDAP Service manifest
  # phpldapadmin_service = file("./_manifests/openldap/phpldapadmin_service.yaml") # phpLDAPadmin Service manifest
  # openldap_ingress     = file("./_manifests/openldap/ingress.yaml")              # Ingress for OpenLDAP and phpLDAPadmin
  # hashibank_ldif       = file("./_manifests/openldap/hashibank.ldif")            # LDIF file for initializing LDAP with data
  # Load OpenLDAP YAML manifests for resources


  # Prometheus Helm chart and ConfigMap for monitoring
  prometheus_scrape_config = file("./_helm_charts/prometheus/configmap.yaml")         # Prometheus ConfigMap for scrape configs
  prometheus_helm_values   = file("./_helm_charts/prometheus/values.prometheus.yaml") # Helm values for Prometheus deployment

  # Grafana Helm chart and ConfigMap for dashboards
  grafana_configmap   = file("./_helm_charts/grafana/configmap.yaml")      # Grafana ConfigMap for dashboards and configs
  grafana_helm_values = file("./_helm_charts/grafana/values.grafana.yaml") # Helm values for Grafana deployment
}
