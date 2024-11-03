resource "kubernetes_secret_v1" "vault_license" {
  metadata {
    name      = "vaultlicense"
    namespace = var.vault_namespace
  }
  data = {
    license = var.vault_license
  }
  type = "Opaque"
}

resource "kubernetes_config_map_v1" "vault_init_script" {
  metadata {
    name      = "vault-init-script"
    namespace = var.vault_namespace
  }

  data = {
    "vault-init.sh" = var.vault_init_script
  }
}

# Role for Vault initialization to manage secrets
resource "kubernetes_role_v1" "vault_init_role" {
  metadata {
    name      = "vault-init-role"
    namespace = var.vault_namespace
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
    namespace = var.vault_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.vault_init_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = var.vault_namespace
  }
}

resource "helm_release" "vault" {
  depends_on = [ kubernetes_secret_v1.vault_license, kubernetes_secret_v1.vault_tls ]
  
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  version    = var.vault_helm_version

  values = [ var.vault_helm ]
  set {
    name  = "server.ingress.hosts[0].host"
    value = "vault-dc1.hashibank.com"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "vault-dc1.hashibank.com"
  }
}

# Kubernetes job to initialize Vault
resource "kubernetes_job_v1" "vault_init" {
  depends_on = [helm_release.vault]

  metadata {
    name      = "vault-init-job"
    namespace = var.vault_namespace
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
            value = var.vault_namespace
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

data "kubernetes_secret" "vault_init_credentials" {
  depends_on = [kubernetes_job_v1.vault_init]

  metadata {
    name      = "vault-init-credentials"
    namespace = "vault"
  }
}