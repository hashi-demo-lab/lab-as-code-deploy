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
    namespace         = var.vault_namespace
    vault_common_name = var.vault_common_name
    vault_ha_enabled  = var.vault_ha_enabled
    vault_replicas    = var.vault_replicas
    configure_seal       = var.configure_seal
    auto_unseal_addr     = var.auto_unseal_addr    # e.g. "vault-autounseal.hashibank.com:8200"
    auto_unseal_key_name = var.auto_unseal_key_name  # e.g. "autounseal"
    auto_unseal_token = var.vault_mode == "primary" ? data.kubernetes_secret.auto_unseal_token[0].data["token"] : ""
  })
}

resource "helm_release" "vault" {
  depends_on = [
    kubernetes_secret_v1.vault_license,
    kubernetes_secret_v1.vault_tls
  ]

  name       = var.vault_release_name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = var.vault_namespace
  version    = var.vault_helm_version

  values = [local.vault_helm_values]
  #values = [var.vault_helm]
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
          env {
            name = "VAULT_RELEASE_NAME"
            value = var.vault_release_name
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
    namespace = var.vault_namespace
  }
}

resource "kubernetes_job_v1" "transit_config" {
  count     = var.vault_mode == "auto_unseal" ? 1 : 0
  metadata {
    name      = "vault-transit-config"
    namespace = var.vault_namespace
  }
  spec {
    template {
      metadata {
        labels = {
          app = "vault-transit-config"
        }
      }
      spec {
        restart_policy = "Never"
        container {
          name  = "transit-config"
          image = "hashicorp/vault:latest"
          command = ["/bin/sh", "-ec"]
          args = [
            <<-EOT
              apk --no-cache add curl jq kubectl
              echo "Configuring transit secrets engine..."
              
              # Set Vault address and CA cert.
              export VAULT_ADDR="https://auto-unseal-vault-0.auto-unseal-vault-internal.auto-unseal-vault.svc.cluster.local:8200"
              export VAULT_TOKEN="${data.kubernetes_secret.vault_init_credentials.data["root-token"]}"
              echo "VAULT TOKEN: $VAULT_TOKEN"
              export VAULT_CACERT=/vault/tls/ca.crt
              
              # Enable transit secrets engine; ignore error if already enabled.
              vault secrets enable transit || echo "Transit already enabled"
              
              # Create the transit key; ignore error if it already exists.
              vault write -f transit/keys/${var.auto_unseal_key_name} || echo "Transit key already exists"
              
              # Write the autounseal policy.
              vault policy write autounseal - <<EOF
path "transit/encrypt/${var.auto_unseal_key_name}" {
  capabilities = ["update", "create"]
}
path "transit/decrypt/${var.auto_unseal_key_name}" {
  capabilities = ["update", "create"]
}
EOF
              
              # Create an orphan periodic token with the autounseal policy, wrapped for safety.
              WRAPPED_TOKEN=$(vault token create -orphan -policy="autounseal" -wrap-ttl=180 -period=24h -format=json | jq -r .wrap_info.token)
              echo "Wrapped token: '$WRAPPED_TOKEN'"
              
              # Unwrap the token using the -field flag.
              UNWRAPPED_TOKEN=$(vault unwrap -field=token "$WRAPPED_TOKEN")
              echo "Unwrapped token: '$UNWRAPPED_TOKEN'"
              
              if [ -z "$UNWRAPPED_TOKEN" ]; then
                echo "Error: Unwrapped token is empty. Exiting."
                exit 1
              fi
              
              # Remove any newlines from the base64 encoding.
              TOKEN_BASE64=$(echo -n "$UNWRAPPED_TOKEN" | base64 | tr -d '\n')
              echo "Token base64: '$TOKEN_BASE64'"
              
              # Create (or update) a Kubernetes secret named "vault-seal-token" with the auto-unseal token.
              cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: vault-seal-token
  namespace: ${var.vault_namespace}
type: Opaque
data:
  token: "$TOKEN_BASE64"
EOF
              
              echo "Transit configuration complete."
            EOT
          ]
          env {
            name  = "VAULT_CACERT"
            value = "/vault/tls/ca.crt"
          }
          volume_mount {
            name       = "vault-tls"
            mount_path = "/vault/tls"
            read_only  = true
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
  count     = var.vault_mode == "primary" ? 1 : 0

  metadata {
    name      = "vault-seal-token"
    namespace = "auto-unseal-vault"  # This is the auto-unseal namespace.
  }
}
