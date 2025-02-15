#!/bin/sh
echo "Starting Primary Vault Cluster Setup..."

# Install required packages
apk --no-cache add curl jq kubectl

export VAULT_CACERT=/vault/tls/ca.crt

echo "Detecting Vault pods..."
NUM_REPLICAS=$(kubectl get pods -n "$K8S_NAMESPACE" -l "app.kubernetes.io/name=vault" -o jsonpath='{.items[*].metadata.name}' | wc -w | tr -d ' ')
echo "Number of Vault pods detected: $NUM_REPLICAS"

# Use node 0 as the primary Vault instance.
export VAULT_ADDR=https://${VAULT_RELEASE_NAME}-0.${VAULT_RELEASE_NAME}-internal.${K8S_NAMESPACE}.svc.cluster.local:8200

# Check if Vault is already initialized.
init_status=$(curl --silent --insecure "$VAULT_ADDR/v1/sys/init" | jq -r '.initialized')

if [ "$init_status" = "true" ]; then
  echo "Vault is already initialized. Waiting for auto-unseal..."
else
  echo "Initializing Vault for the first time with recovery keys..."
  # Use recovery options (recovery keys are generated instead of unseal keys)
  init_output=$(vault operator init -recovery-shares=5 -recovery-threshold=3 -format=json)
  root_token=$(echo "$init_output" | jq -r '.root_token')
  
  # In auto-unseal mode, do NOT call vault operator unseal manually.
  export VAULT_TOKEN=$root_token
  vault audit enable file file_path=/vault/audit/vault_audit.log log_raw=true
fi

# Wait for auto-unseal to complete.
echo "Waiting for Vault to become unsealed..."
while true; do
  sealed=$(vault status -format=json | jq -r .sealed)
  if [ "$sealed" = "false" ]; then
    echo "Vault is unsealed."
    break
  else
    echo "Vault is still sealed. Waiting..."
    sleep 5
  fi
done

# For additional nodes, join the Raft cluster (auto-unseal will handle unsealing).
if [ "$NUM_REPLICAS" -gt 1 ]; then
  for i in $(seq 1 $((NUM_REPLICAS - 1))); do
    export VAULT_ADDR=https://${VAULT_RELEASE_NAME}-$i.${VAULT_RELEASE_NAME}-internal.${K8S_NAMESPACE}.svc.cluster.local:8200
    echo "Joining node $i to the Raft cluster..."
    vault operator raft join -leader-ca-cert="$(cat /vault/tls/ca.crt)" https://${VAULT_RELEASE_NAME}-0.${VAULT_RELEASE_NAME}-internal.${K8S_NAMESPACE}.svc.cluster.local:8200 || echo "Node $i already joined."
  done
fi

# Create or update the Kubernetes secret with the Vault root token.
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: vault-init-credentials
  namespace: $K8S_NAMESPACE
type: Opaque
data:
  root-token: $(echo -n "$root_token" | base64)
EOF

echo "Vault setup complete. Vault is unsealed and credentials secret updated."
