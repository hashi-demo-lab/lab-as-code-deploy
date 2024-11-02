# modules/monitoring/variables.tf

variable "prometheus_namespace" {
  description = "Namespace where Prometheus will be deployed"
  type        = string
}

variable "grafana_namespace" {
  description = "Namespace where Grafana will be deployed"
  type        = string
}

variable "prometheus_helm_values" {
  description = "Content of Prometheus Helm values YAML file"
  type        = string
}

variable "grafana_helm_values" {
  description = "Content of Grafana Helm values YAML file"
  type        = string
}

variable "prometheus_scrape_config" {
  description = "Content of Prometheus scrape configuration YAML"
  type        = string
}

variable "grafana_configmap" {
  description = "Content of Grafana ConfigMap for datasources"
  type        = string
}

variable "ca_cert_pem" {
  description = "CA certificate PEM for Prometheus secret"
  type        = string
}

variable "vault_root_token" {
  description = "Vault root token used by Prometheus and Grafana"
  type        = string
}

variable "prometheus_helm_version" {
  description = "Prometheus Helm chart version"
  type        = string
}

variable "grafana_helm_version" {
  description = "Grafana Helm chart version"
  type        = string
}
