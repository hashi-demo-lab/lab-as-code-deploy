# #convert the follwoing command to terraform using helm provider
# #helm install vault-secrets-operator hashicorp/vault-secrets-operator --namespace="$namespace" --create-namespace --values vault-operator-values.yaml

resource "helm_release" "vault_secrets_operator" {
  name       = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  namespace  = var.vault_namespace
  version    = var.vault_helm_version

  values = [ var.vso_helm ]
}

