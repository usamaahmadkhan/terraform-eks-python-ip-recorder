resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = "nginx-ingress"
  version = "4.2.3"
  timeout = 300

  values = [
    "${file("./values.yaml")}"
  ]

  set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }
}

resource "kubernetes_namespace" "nginx-ingress-ns" {
  metadata {

    labels = {
      mylabel = "label-value"
    }

    name = "nginx-ingress"
  }
}