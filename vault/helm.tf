# Helm release for Vault
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = "vault"
  version    = var.vault_helm_version

  values = [
    file("./values.vault.yaml")
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