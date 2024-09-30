resource "kubernetes_role_v1" "vault_init_role" {
  metadata {
    name      = "vault-init-role"
    namespace = kubernetes_namespace.vault.id
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "get", "update"]
  }
}

resource "kubernetes_role_binding_v1" "vault_init_role_binding" {
  metadata {
    name      = "vault-init-role-binding"
    namespace = kubernetes_namespace.vault.id
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.vault_init_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.vault.id
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.vault.id

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = ""
  }
}

resource "helm_release" "vault" {

  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.id
  version    = var.vault_helm_version

  values = [
    "${file("values.vault.yaml")}"
  ]

  set {
    name  = "server.ingress.hosts[0].host"
    value = "vault-dc1.hashibank.com"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "vault-dc1.hashibank.com"
  }
}

resource "kubernetes_job_v1" "vault_init" {

  metadata {
    name      = "vault-init-job"
    namespace = kubernetes_namespace.vault.id
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
          image = "hashicorp/vault:latest" # Same version as Vault Helm chart


          command = [
            "/bin/sh",
            "-c",
            <<EOT

            echo "Initializing Vault..."
            
            # Install jq using apk, which is used in Alpine-based images
            apk --no-cache add curl jq kubectl

            export VAULT_CACERT=/vault/tls/ca.crt  # Path to the CA certificate
            export VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200
            init_output=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
            root_token=$(echo $init_output | jq -r '.root_token')

            unseal_key=$(echo $init_output | jq -r '.unseal_keys_b64[0]')
            
            echo "Root token: $root_token"
            echo "Unseal key: $unseal_key"

            # Unseal the same pod we just initialized (self-unsealing)
            # Load the CA certificate content (not the path)
            LEADER_CA_CERT=$(cat /vault/tls/ca.crt)
            echo "Unsealing Vault pod..."
            vault operator unseal $unseal_key

            export VAULT_TOKEN=$root_token
            echo "Enabling Vault audit logging..."
            vault audit enable file file_path=/vault/audit/vault_audit.log

            # Join and unseal vault-1
            export VAULT_ADDR=https://vault-1.vault-internal.vault.svc.cluster.local:8200
            echo "Joining and unsealing vault-1..."
            vault operator raft join -leader-ca-cert="$(cat /vault/tls/ca.crt)" https://vault-0.vault-internal.vault.svc.cluster.local:8200
            vault operator unseal $unseal_key

            # Join and unseal vault-2
            export VAULT_ADDR=https://vault-2.vault-internal.vault.svc.cluster.local:8200
            echo "Joining and unsealing vault-2..."
            vault operator raft join -leader-ca-cert="$(cat /vault/tls/ca.crt)" https://vault-0.vault-internal.vault.svc.cluster.local:8200
            vault operator unseal $unseal_key

            echo "Vault initialization and unsealing complete!"

            kubectl create secret generic vault-init-credentials \
              --from-literal=root-token=$root_token \
              --from-literal=unseal-key=$unseal_key \
              -n ${kubernetes_namespace.vault.id}
            EOT
          ]

          volume_mount {
            name       = "vault-tls"
            mount_path = "/vault/tls"
            read_only  = true
          }
        }
        volume {
          name = "vault-tls"

          secret {
            secret_name = "vaultcertificate" # Kubernetes secret that contains your TLS certs
            items {
              key  = "ca.crt" # Only mount the CA certificate
              path = "ca.crt"
            }
          }
        }
      }
    }
  }
}