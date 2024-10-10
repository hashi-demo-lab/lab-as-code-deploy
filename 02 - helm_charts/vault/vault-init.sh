#!/bin/sh
echo "Initializing Vault..."

# Install required packages
apk --no-cache add curl jq kubectl

export VAULT_CACERT=/vault/tls/ca.crt
export VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200

# Initialize Vault and capture root token and unseal key
init_output=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
root_token=$(echo $init_output | jq -r '.root_token')
unseal_key=$(echo $init_output | jq -r '.unseal_keys_b64[0]')

# Unseal the Vault pod
vault operator unseal $unseal_key

export VAULT_TOKEN=$root_token
vault audit enable file file_path=/vault/audit/vault_audit.log

# Join and unseal remaining Vault pods
for i in 1 2; do
  export VAULT_ADDR=https://vault-$i.vault-internal.vault.svc.cluster.local:8200
  vault operator raft join -leader-ca-cert="$(cat /vault/tls/ca.crt)" https://vault-0.vault-internal.vault.svc.cluster.local:8200
  vault operator unseal $unseal_key
done

echo "Vault initialization and unsealing complete!"

# Store the root token and unseal key in Kubernetes secret
kubectl create secret generic vault-init-credentials \
  --from-literal=root-token=$root_token \
  --from-literal=unseal-key=$unseal_key \
  -n $K8S_NAMESPACE

# After Vault initialization, proceed with setting up the policies and authentication
echo "Setting up Vault JWT auth for Terraform Cloud..."
export VAULT_ADDR=https://vault-active.vault.svc.cluster.local:8200

# Create a policy granting the TFC workspace access
vault policy write tfc_workspace_access - <<EOT
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT

# Enable the JWT authentication method for Terraform Cloud
vault auth enable -path=tfc_jwt jwt

vault write auth/tfc_jwt/config \
  oidc_discovery_url="https://app.terraform.io" \
  bound_issuer="https://app.terraform.io"

# Create the JWT auth backend role for TFC
vault write auth/tfc_jwt/role/tfc_workspace_role \
  role_type="jwt" \
  user_claim="terraform_full_workspace" \
  token_policies="tfc_workspace_access" \
  bound_audiences="vault.workload.identity" \
  bound_claims_type="glob" \
  bound_claims.sub="organization:lab-as-code:project:configurations:workspace:*:run_phase:*" \
  token_max_ttl="900"

echo "Vault JWT auth setup for Terraform Cloud completed!"