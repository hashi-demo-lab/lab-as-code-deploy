# Map of namespaces and their corresponding team labels
locals {
  namespaces = {
    nginx      = "nginx"
    vault      = "vault"
    prometheus = "prometheus"
    ldap       = "ldap"
    grafana    = "grafana"
    mysql      = "mysql"
    neo4j      = "neo4j"
    gitlab     = "gitlab"
    app1       = "app1"
    app2       = "app2"
    app3-frontend      = "app3-frontend"
    app3-backend       = "app3-backend"
    app4-web   = "app4-web"
    app4-api   = "app4-api"
    app4-db    = "app4-db"
  }
}

# Creating Kubernetes Namespaces dynamically using for_each
resource "kubernetes_namespace" "namespace" {
  for_each = local.namespaces

  metadata {
    name = each.key

    annotations = {
      name = each.key
    }

    labels = {
      team = each.value
    }
  }
}