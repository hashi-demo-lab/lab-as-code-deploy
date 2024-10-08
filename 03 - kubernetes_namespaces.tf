# Creating Kubernetes Namespaces 
resource "kubernetes_namespace" "vault" {
  metadata {
    annotations = {
      name = "vault"
    }
    labels = {
      team = "vault"
    }

    name = "vault"
  }
}

resource "kubernetes_namespace" "ldap" {
  metadata {
    annotations = {
      name = "ldap"
    }
    labels = {
      team = "ldap"
    }

    name = "ldap"
  }
}

resource "kubernetes_namespace" "nginx" {
  metadata {
    annotations = {
      name = "nginx"
    }
    labels = {
      team = "nginx"
    }

    name = "nginx"
  }
}

resource "kubernetes_namespace" "prometheus" {
  metadata {
    annotations = {
      name = "prometheus"
    }
    labels = {
      team = "prometheus"
    }

    name = "prometheus"
  }
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    annotations = {
      name = "grafana"
    }
    labels = {
      team = "grafana"
    }

    name = "grafana"
  }
}

resource "kubernetes_namespace" "mysql" {
  metadata {
    annotations = {
      name = "mysql"
    }
    labels = {
      team = "mysql"
    }

    name = "mysql"
  }
} 