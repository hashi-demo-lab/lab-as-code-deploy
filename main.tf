module "namespaces" {
  source = "./modules/namespaces"
}

module "ca_cert" {
  source                = "./modules/cert_creation"
  common_name           = "vault-ca"
  organization          = "HashiBank"
  is_ca_certificate     = true
  validity_period_hours = 87600
  cert_file_name        = "vault-ca.crt"
  key_file_name         = "vault-ca.key"
  save_to_file          = true
}

module "ingress_nginx" {
  source = "./modules/ingress_nginx"

  ingress_namespace = module.namespaces.nginx_namespace
}

module "vault" {
  source     = "./modules/vault"
  depends_on = [module.ingress_nginx]

  vault_namespace = module.namespaces.vault_namespace
  ca_cert_pem     = module.ca_cert.cert_pem
  ca_key_pem      = module.ca_cert.private_key_pem

  organization      = var.organization
  vault_license     = var.vault_license
  vault_dns_names   = var.vault_dns_names
  vault_common_name = var.vault_common_name

  vault_helm        = local.vault_helm_values
  vault_init_script = local.vault_init_script_contents
}

module "monitoring" {
  source = "./modules/monitoring"

  prometheus_namespace = module.namespaces.prometheus_namespace
  grafana_namespace    = module.namespaces.grafana_namespace
  ca_cert_pem          = module.ca_cert.cert_pem # From ca_cert module

  prometheus_helm_version = var.prometheus_helm_version
  grafana_helm_version    = var.grafana_helm_version

  prometheus_helm_values   = local.prometheus_helm_values   # Loaded from a file
  grafana_helm_values      = local.grafana_helm_values      # Loaded from a file
  prometheus_scrape_config = local.prometheus_scrape_config # Loaded from a file
  grafana_configmap        = local.grafana_configmap        # Loaded from a file
  vault_root_token         = local.decoded_root_token
}

module "neo4j" {
  source = "./modules/neo4j"
  neo4j_namespace = "neo4j"
  helm_release_name = "neo4j"
  helm_repository = "https://helm.neo4j.com/neo4j"
  helm_chart_name = "neo4j"
  helm_values = local.neo4j_helm_values
}


module "ldap_cert" {
  source = "./modules/cert_creation"

  ca_private_key_pem = module.ca_cert.private_key_pem
  ca_cert_pem        = module.ca_cert.cert_pem

  common_name  = var.ldap_common_name
  organization = var.organization
  dns_names    = var.ldap_dns_names

  is_ca_certificate     = false
  validity_period_hours = 8760
  cert_file_name        = "ldap.crt"
  key_file_name         = "ldap.key"
  save_to_file          = true
}

module "ldap" {
  source         = "./modules/ldap"
  ldap_namespace = module.namespaces.ldap_namespace

  # Pass certificate and key data from the ldap_cert module
  ldap_cert_pem        = module.ldap_cert.cert_pem
  ldap_private_key_pem = module.ldap_cert.private_key_pem
  ca_cert_pem          = module.ca_cert.cert_pem

  # Other manifest content and LDIF data
  openldap_statefulset = local.openldap_statefulset
  openldap_service     = local.openldap_service
  phpldapadmin_service = local.phpldapadmin_service
  openldap_ingress     = local.openldap_ingress
  ldap_ldif_data       = local.ldap_ldif_data
}