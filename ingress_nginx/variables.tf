variable "kube_config_path" {
  type        = string
  description = "Path to the kubeconfig file"
  default     = "/kubeconfig/config" # Path inside the container
}

variable "kube_config_context" {
  type        = string
  description = "Kubeconfig context to use"
  default     = "docker-desktop"
}

variable "helm_release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "ingress-nginx"
}

variable "helm_repository" {
  description = "Repository URL for the Helm chart"
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "helm_chart_name" {
  description = "Name of the Helm chart"
  type        = string
  default     = "ingress-nginx"
}

variable "ingress_namespace" {
  description = "Kubernetes namespace for the ingress controller"
  type        = string
  default     = "nginx"
}

variable "controller_watch_namespace" {
  description = "Namespace that the ingress controller should watch (empty means all namespaces)"
  type        = string
  default     = ""
}

variable "enable_ssl_passthrough" {
  description = "Whether to enable SSL passthrough in the ingress controller"
  type        = bool
  default     = true
}