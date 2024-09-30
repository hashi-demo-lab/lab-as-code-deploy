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

/*resource "kubernetes_namespace" "blue" {
  metadata {
    annotations = {
      name = "blue"
    }
    labels = {
      team = "blue"
    }
    name = "blue"
  }
}

# Creating K8s Namespaces 
resource "kubernetes_namespace" "red" {
  metadata {
    annotations = {
      name = "red"
    }
    labels = {
      team = "red"
    }
    name = "red"
  }
}*/