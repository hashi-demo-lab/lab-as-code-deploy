# Creating Vault Enterprise License Secret
resource "kubernetes_secret_v1" "vault_license" {
  metadata {
    name      = "vaultlicense"
    namespace = "vault"
  }
  data = {
    license = var.vault_license
  }
  type = "Opaque" # Corrected to Opaque, as kubernetes.io/opaque is not valid
}

# ConfigMap to store the Vault init script
resource "kubernetes_config_map_v1" "vault_init_script" {
  metadata {
    name      = "vault-init-script"
    namespace = "vault"
  }

  data = {
    "vault-init.sh" = file("./vault-init.sh")
  }
}

# Kubernetes job to initialize Vault
resource "kubernetes_job_v1" "vault_init" {
  depends_on = [helm_release.vault]

  metadata {
    name      = "vault-init-job"
    namespace = "vault"
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
            value = "vault"
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