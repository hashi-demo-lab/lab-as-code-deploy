# Creating Vault Enterprise License Secret
resource "kubernetes_secret_v1" "vault_license" {
  metadata {
    name      = "vaultlicense"
    namespace = kubernetes_namespace.namespace["vault"].id
  }
  data = {
    license = var.vault_license
  }
  type = "Opaque" # Corrected to Opaque, as kubernetes.io/opaque is not valid
}

# Role for Vault initialization to manage secrets
resource "kubernetes_role_v1" "vault_init_role" {
  metadata {
    name      = "vault-init-role"
    namespace = kubernetes_namespace.namespace["vault"].id
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "get", "update"]
  }
}

# Binding role to default service account for Vault init
resource "kubernetes_role_binding_v1" "vault_init_role_binding" {
  metadata {
    name      = "vault-init-role-binding"
    namespace = kubernetes_namespace.namespace["vault"].id
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.vault_init_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.namespace["vault"].id
  }
}

# Helm release for Vault
resource "helm_release" "vault" {
  depends_on = [
    kubernetes_secret_v1.vault_license,
    helm_release.ingress_nginx
  ] # Add a dependency on the license secret & the Ingress controller

  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.namespace["vault"].id
  version    = var.vault_helm_version

  values = [
    local.vault_helm
  ]

  set {
    name  = "server.ingress.hosts[0].host"
    value = "vault-dc1.hashibank.com"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "vault-dc1.hashibank.com"
  }
  
  lifecycle {
    ignore_changes = [
      metadata,  # Ignores all changes within the metadata block
    ]
  }
}

# ConfigMap to store the Vault init script
resource "kubernetes_config_map_v1" "vault_init_script" {
  metadata {
    name      = "vault-init-script"
    namespace = kubernetes_namespace.namespace["vault"].id
  }

  data = {
    "vault-init.sh" = local.vault_init_script # Reference the script loaded via locals
  }
}

# Kubernetes job to initialize Vault
resource "kubernetes_job_v1" "vault_init" {
  depends_on = [helm_release.vault]

  metadata {
    name      = "vault-init-job"
    namespace = kubernetes_namespace.namespace["vault"].id
  }

  spec {
    template {
      metadata {
        labels = {
          app = "vault-init"
        }
      }

      spec {
        restart_policy = "Never"

        container {
          name  = "vault-init"
          image = "hashicorp/vault:latest"

          # Use the script from the ConfigMap
          command = ["/bin/sh", "/vault-init/vault-init.sh"]

          # Pass the Kubernetes namespace as an environment variable
          env {
            name  = "K8S_NAMESPACE"
            value = kubernetes_namespace.namespace["vault"].id
          }

          volume_mount {
            name       = "vault-init-script"
            mount_path = "/vault-init"
            read_only  = true
          }

          volume_mount {
            name       = "vault-tls"
            mount_path = "/vault/tls"
            read_only  = true
          }
        }

        volume {
          name = "vault-init-script"

          config_map {
            name = "vault-init-script"
            items {
              key  = "vault-init.sh"
              path = "vault-init.sh"
            }
          }
        }

        volume {
          name = "vault-tls"

          secret {
            secret_name = "vault-certificate"
            items {
              key  = "ca.crt"
              path = "ca.crt"
            }
          }
        }
      }
    }
  }
}

# Fetch the Vault root token and unseal key from Kubernetes secret
data "kubernetes_secret" "vault_init_credentials" {
  metadata {
    name      = "vault-init-credentials"
    namespace = kubernetes_namespace.namespace["vault"].id
  }

  depends_on = [kubernetes_job_v1.vault_init] # Ensure the job runs before accessing secret
}