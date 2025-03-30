resource "helm_release" "vault_secrets_operator" {
  count = var.vso_helm == null ? 0 : 1

  name       = "vault-secrets-operator"
  chart      = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  namespace  = var.vault_namespace
  version    = "0.10.0"

  values = [var.vso_helm]
}
