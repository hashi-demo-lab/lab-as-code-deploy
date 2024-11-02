module "ca_cert" {
  source = "./modules/ca_cert"
}

module "namespaces" {
  source = "./modules/namespaces"
}

module "ingress_nginx" {
  source = "./modules/ingress_nginx"

  ingress_namespace = module.namespaces.nginx_namespace
}

module "vault" {
  source     = "./modules/vault"
  depends_on = [module.ingress_nginx]

  organization = var.organization

  ca_cert_pem = module.ca_cert.ca_cert_pem
  ca_key_pem  = module.ca_cert.ca_key_pem

  vault_namespace   = module.namespaces.vault_namespace
  vault_license     = var.vault_license
  vault_helm        = local.vault_helm_values
  vault_init_script = local.vault_init_script_contents
  vault_dns_names   = var.vault_dns_names
  vault_common_name = var.vault_common_name
}

data "kubernetes_secret" "vault_init_credentials" {
  depends_on = [module.vault.vault_init_job]

  metadata {
    name      = "vault-init-credentials"
    namespace = "vault"
  }
}

module "monitoring" {
  source                   = "./modules/monitoring"
  
  prometheus_namespace     = module.namespaces.prometheus_namespace
  grafana_namespace        = module.namespaces.grafana_namespace
  ca_cert_pem              = module.ca_cert.ca_cert_pem     # From ca_cert module
  prometheus_helm_values   = local.prometheus_helm_values   # Loaded from a file
  grafana_helm_values      = local.grafana_helm_values      # Loaded from a file
  prometheus_scrape_config = local.prometheus_scrape_config # Loaded from a file
  grafana_configmap        = local.grafana_configmap        # Loaded from a file
  vault_root_token         = local.decoded_root_token
  prometheus_helm_version  = var.prometheus_helm_version
  grafana_helm_version     = var.grafana_helm_version
}

module "ldap" {
  source                    = "./modules/ldap"

  ldap_namespace       = module.namespaces.ldap_namespace

  openldap_statefulset = local.openldap_statefulset
  openldap_service     = local.openldap_service
  phpldapadmin_service = local.phpldapadmin_service
  openldap_ingress     = local.openldap_ingress
  ldap_ldif_data       = local.ldap_ldif_data
}

