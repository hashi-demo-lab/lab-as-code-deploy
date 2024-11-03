#!/bin/sh
echo "Starting Vault setup..."

# Install required packages
apk --no-cache add curl jq kubectl

export VAULT_CACERT=/vault/tls/ca.crt
export VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200

# Check if Vault is already initialized
init_status=$(curl --silent --insecure $VAULT_ADDR/v1/sys/init | jq -r '.initialized')

if [ "$init_status" = "true" ]; then
  echo "Vault is already initialized, proceeding with unseal."
  
  # Retrieve existing unseal key and root token from Kubernetes secret if they exist
  root_token=$(kubectl get secret vault-init-credentials -n $K8S_NAMESPACE -o jsonpath='{.data.root-token}' | base64 -d)
  unseal_key=$(kubectl get secret vault-init-credentials -n $K8S_NAMESPACE -o jsonpath='{.data.unseal-key}' | base64 -d)
  
  # Unseal the initial Vault pod (node 0)
  vault operator unseal $unseal_key
else
  echo "Initializing Vault for the first time..."
  
  # Initialize Vault and capture new root token and unseal key
  init_output=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)
  root_token=$(echo $init_output | jq -r '.root_token')
  unseal_key=$(echo $init_output | jq -r '.unseal_keys_b64[0]')
  
  # Unseal the initial Vault pod (node 0)
  vault operator unseal $unseal_key
  
  export VAULT_TOKEN=$root_token
  vault audit enable file file_path=/vault/audit/vault_audit.log
fi

# Unseal and join additional Vault pods
for i in 1 2; do
  export VAULT_ADDR=https://vault-$i.vault-internal.vault.svc.cluster.local:8200
  
  # Attempt to join the Raft cluster, ignoring errors if already joined
  vault operator raft join -leader-ca-cert="$(cat /vault/tls/ca.crt)" https://vault-0.vault-internal.vault.svc.cluster.local:8200 || echo "Node $i already joined."
  vault operator unseal $unseal_key
done

# Create or replace the Kubernetes secret with the root token and unseal key
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-init-credentials
  namespace: $K8S_NAMESPACE
type: Opaque
data:
  root-token: $(echo -n $root_token | base64)
  unseal-key: $(echo -n $unseal_key | base64)
EOF

echo "Vault setup complete with unseal and credentials secret updated."

# Additional setup (commented-out for now)
# echo "Setting up Vault JWT auth for Terraform Cloud..."
# export VAULT_ADDR=https://vault-active.vault.svc.cluster.local:8200

# vault policy write tfc_workspace_access - <<EOT
# path "*" {
#   capabilities = ["create", "read", "update", "delete", "list", "sudo"]
# }
# EOT

# vault auth enable -path=tfc_jwt jwt
# vault write auth/tfc_jwt/config \
#   oidc_discovery_url="https://app.terraform.io" \
#   bound_issuer="https://app.terraform.io"

# vault write auth/tfc_jwt/role/tfc_workspace_role \
#   role_type="jwt" \
#   user_claim="terraform_full_workspace" \
#   token_policies="tfc_workspace_access" \
#   bound_audiences="vault.workload.identity" \
#   bound_claims_type="glob" \
#   bound_claims.sub="organization:lab-as-code:project:configurations:workspace:*:run_phase:*" \
#   token_max_ttl="900"

# echo "Vault JWT auth setup for Terraform Cloud completed!"
