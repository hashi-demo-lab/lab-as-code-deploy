# Vault and Kubernetes Setup for Terraform Cloud JWT Authentication

This setup enables Vault to authenticate Terraform Cloud workspaces using JWT authentication and provides a secure infrastructure deployed on Kubernetes. This README outlines the various components, how they interact, and the commands/scripts used to initialize and configure Vault.

## Prerequisites

- **Kubernetes Cluster**: The entire setup runs inside a Kubernetes cluster.
- **Helm**: Used for deploying Vault, Prometheus, Grafana, and other services.
- **Vault**: Deployed via Helm inside Kubernetes.
- **Terraform Cloud**: We set up JWT-based authentication for Terraform Cloud Workspaces.

## Components

### 1. **Kubernetes Namespaces**

We create Kubernetes namespaces for each service using a `for_each` loop in Terraform. This dynamically creates the required namespaces for Vault, LDAP, Prometheus, Grafana, and others.

### 2. **Vault TLS Setup**

Vault's TLS setup includes:
- A private key and certificate request.
- A locally signed certificate using a custom CA.
- The resulting certificate and key are stored in Kubernetes secrets.

This ensures secure communication between Vault and clients.

### 3. **Vault Initialization Script**

A ConfigMap stores the `vault-init.sh` script, which is mounted into a Kubernetes job responsible for initializing and unsealing Vault. The script:
- Initializes Vault and retrieves the root token and unseal key.
- Unseals the Vault pods and sets up Raft storage for HA.
- Creates a Kubernetes secret containing the root token and unseal key for future use.

The job is configured to wait for Vault to be fully deployed and is dependent on Vault's Helm release.

### 4. **JWT Authentication for Terraform Cloud**

The Vault setup includes enabling JWT authentication for Terraform Cloud workspaces. This is done via the following steps in the initialization script:
- A Vault policy (`tfc_workspace_access`) is created, granting full access (`create`, `read`, `update`, `delete`, `list`, `sudo`).
- The JWT auth method is enabled, and the OIDC discovery URL is set to `https://app.terraform.io`.
- A Vault role (`tfc_workspace_role`) is created, allowing Terraform Cloud JWT tokens to authenticate based on bound claims related to workspaces.

### 5. **LDAP Deployment**

OpenLDAP and phpLDAPadmin are deployed using Kubernetes manifests. These services are configured for user management within the cluster. Configuration is stored in Kubernetes ConfigMaps and Secrets.

### 6. **Prometheus and Grafana Monitoring**

- **Prometheus**: Configured via Helm to monitor Vault and other services. The Prometheus scrape config is stored in a Kubernetes ConfigMap.
- **Grafana**: Also deployed via Helm, with its configuration stored in a ConfigMap. Grafana is set up to visualize metrics from Prometheus and other sources.

Both Prometheus and Grafana use JWT authentication to access Vault secrets for secure metrics collection and visualization.

### 7. **Security**

- **Vault Policies**: The `tfc_workspace_access` policy defines access controls for Terraform Cloud workspaces, limiting their access to required capabilities only.
- **JWT Authentication**: Terraform Cloud workspaces use JWT-based workload identity to authenticate against Vault, ensuring secure token-based access.

### 8. **Helm Releases**

Helm releases are used to deploy the following:
- **Vault**: Deployed with secure TLS, high availability, and JWT authentication configured.
- **Prometheus**: Deployed with custom scrape configurations.
- **Grafana**: Deployed with data source configurations to visualize Vault metrics.

Each Helm release is dependent on the configuration of secrets, config maps, and other Kubernetes resources, ensuring a proper deployment sequence.

## Sequence of Deployment

1. **Namespaces**: Kubernetes namespaces for Vault, LDAP, Prometheus, Grafana, and other services are created.
2. **TLS Setup**: Vault's TLS certificates are generated and stored in Kubernetes secrets.
3. **Vault Deployment**: Vault is deployed via Helm, and the `vault-init.sh` script initializes and unseals Vault.
4. **JWT Authentication**: Vault is configured to authenticate Terraform Cloud workspaces using JWT tokens.
5. **Monitoring**: Prometheus and Grafana are deployed via Helm, configured to monitor Vault and other services.
6. **LDAP**: OpenLDAP and phpLDAPadmin are deployed for user management within the environment.

## How to Run

To run this setup, ensure you have all prerequisites installed and configured. You can apply the configuration by running the following:

```bash
terraform init
terraform apply
