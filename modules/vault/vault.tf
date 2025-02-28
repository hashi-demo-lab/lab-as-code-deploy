# module/vault/vault.tf
resource "kubernetes_secret_v1" "vault_license" {
  metadata {
    name      = "vaultlicense"
    namespace = var.vault_namespace
  }
  data = { license = var.vault_license }
  type = "Opaque"
}

resource "kubernetes_secret_v1" "vault_tls" {
  metadata {
    name      = "vault-certificate"
    namespace = var.vault_namespace
  }

  data = {
    "tls.crt" = var.vault_cert_pem
    "tls.key" = var.vault_private_key_pem
    "ca.crt"  = var.ca_cert_pem
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "aws_credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = var.vault_namespace
  }

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    AWS_SESSION_TOKEN     = var.aws_session_token
  }

  type = "Opaque"
}

resource "kubernetes_config_map_v1" "vault_initialization_script" {
  metadata {
    name      = "vault-initialization-script"
    namespace = var.vault_namespace
  }
  data = { "vault-initialization.sh" = var.vault_initialization_script }
}

# Kuberenetes Role required for Vault initialization script to manage secrets
# We use this to store the root token in the namespace. This is not a best practice but for demo purposes only.
resource "kubernetes_role_v1" "vault_init_role" {
  metadata {
    name      = "vault-init-role"
    namespace = var.vault_namespace
  }
  rule {
    api_groups = [""]
    resources  = ["secrets", "pods"]
    verbs      = ["create", "get", "update", "delete", "patch", "list"]
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

locals {
  vault_helm_values = templatefile("${path.module}/vault_helm.tftpl", {
    namespace                   = var.vault_namespace
    vault_common_name           = var.vault_common_name
    vault_ha_enabled            = var.vault_ha_enabled
    enable_service_registration = var.enable_service_registration
    vault_replicas              = var.vault_replicas
    configure_seal              = var.configure_seal
    auto_unseal_addr            = var.auto_unseal_addr     # e.g. "vault-autounseal.hashibank.com:8200"
    auto_unseal_key_name        = var.auto_unseal_key_name # e.g. "autounseal"
    auto_unseal_token           = var.vault_mode == "primary" ? data.kubernetes_secret.auto_unseal_token[0].data["token"] : ""
    vault_mode                  = var.vault_mode
  })
}

resource "helm_release" "vault" {
  depends_on = [
    kubernetes_secret_v1.vault_license,
    kubernetes_secret_v1.vault_tls
  ]
  name       = var.vault_release_name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault" #"${path.module}/vault-0.29.1.tgz"
  namespace  = var.vault_namespace
  version    = var.vault_helm_version
  values     = [local.vault_helm_values]
}

# Kubernetes job to initialize Vault
resource "kubernetes_job_v1" "vault_initialization" {
  depends_on = [helm_release.vault]
  metadata {
    name      = "vault-init-job"
    namespace = var.vault_namespace
  }
  spec {
    template {
      metadata {
        labels = { app = "vault-init" }
      }
      spec {
        restart_policy = "Never"
        container {
          name    = "vault-init"
          image   = "hashicorp/vault:latest"
          command = ["/bin/sh", "/vault-init/vault-initialization.sh"]
          env {
            name  = "K8S_NAMESPACE"
            value = var.vault_namespace
          }
          env {
            name  = "VAULT_RELEASE_NAME"
            value = var.vault_release_name
          }
          volume_mount {
            name       = "vault-initialization-script"
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
          name = "vault-initialization-script"
          config_map {
            name = "vault-initialization-script"
            items {
              key  = "vault-initialization.sh"
              path = "vault-initialization.sh"
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
  depends_on = [ kubernetes_job_v1.vault_initialization ]
  metadata {
    name      = "vault-init-credentials"
    namespace = var.vault_namespace
  }
}

resource "kubernetes_config_map_v1" "auto_unseal_transit_config_script" {
  metadata {
    name      = "auto-unseal-transit-config-script"
    namespace = var.vault_namespace
  }
  data = { "auto-unseal-transit-config.sh" = var.auto_unseal_transit_config_script }
}

resource "kubernetes_job_v1" "auto_unseal_transit_config" {
  depends_on = [ kubernetes_job_v1.vault_initialization ]
  count = var.auto_unseal_transit_config_script != "" ? 1 : 0
  metadata {
    name      = "auto-unseal-transit-config-job"
    namespace = var.vault_namespace
  }
  spec {
    template {
      metadata {
        labels = { app = "auto-unseal-transit-config" }
      }
      spec {
        restart_policy = "Never"
        container {
          name    = "auto-unseal-transit-config"
          image   = "hashicorp/vault:latest"
          command = ["/bin/sh", "/auto-unseal-transit-config/auto-unseal-transit-config.sh"]
          env {
            name  = "VAULT_CACERT"
            value = "/vault/tls/ca.crt"
          }
          env {
            name  = "VAULT_ADDR"
            value = "https://auto-unseal-vault-0.auto-unseal-vault-internal.auto-unseal-vault.svc.cluster.local:8200"
          }
          env {
            name  = "VAULT_TOKEN"
            value = data.kubernetes_secret.vault_init_credentials.data["root-token"]
          }
          env {
            name = "AUTO_UNSEAL_KEY_NAME"
            value = var.auto_unseal_key_name
          }
          volume_mount {
            name       = "auto-unseal-transit-config-script"
            mount_path = "/auto-unseal-transit-config"
            read_only  = true
          }
          volume_mount {
            name       = "vault-tls"
            mount_path = "/vault/tls"
            read_only  = true
          }
        }
        volume {
          name = "auto-unseal-transit-config-script"
          config_map {
            name = kubernetes_config_map_v1.auto_unseal_transit_config_script.metadata[0].name
            items {
              key  = "auto-unseal-transit-config.sh"
              path = "auto-unseal-transit-config.sh"
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

data "kubernetes_secret" "auto_unseal_token" {
  count = var.vault_mode == "primary" ? 1 : 0

  metadata {
    name      = "vault-seal-token"
    namespace = "auto-unseal-vault" # This is the auto-unseal namespace.
  }
}