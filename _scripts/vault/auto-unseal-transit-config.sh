#!/bin/sh
set -e

echo "Configuring transit secrets engine..."

# Ensure required environment variables are set.
: "${VAULT_ADDR:?VAULT_ADDR must be set}"
: "${VAULT_TOKEN:?VAULT_TOKEN must be set}"
: "${VAULT_CACERT:?VAULT_CACERT must be set}"

# Transit key name (can be overridden via AUTO_UNSEAL_KEY_NAME)
KEY_NAME=${AUTO_UNSEAL_KEY_NAME:-autounseal}
echo "Using transit key name: $KEY_NAME"

# Install required packages.
apk --no-cache add curl jq kubectl

# Enable the transit secrets engine; ignore error if already enabled.
vault secrets enable transit || echo "Transit already enabled"

# Create the transit key; ignore error if it already exists.
vault write -f transit/keys/$KEY_NAME || echo "Transit key already exists"

# Write the autounseal policy.
vault policy write autounseal - <<EOF
path "transit/encrypt/$KEY_NAME" {
  capabilities = ["update", "create"]
}
path "transit/decrypt/$KEY_NAME" {
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
fi

# Base64 encode the unwrapped token (remove any newlines).
TOKEN_BASE64=$(echo -n "$UNWRAPPED_TOKEN" | base64 | tr -d '\n')
echo "Token base64: '$TOKEN_BASE64'"

# Create (or update) a Kubernetes secret named "vault-seal-token" with the auto-unseal token.
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: vault-seal-token
  namespace: ${VAULT_NAMESPACE}
type: Opaque
data:
  token: "$TOKEN_BASE64"
EOF

echo "Transit configuration complete."