resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.5"

  values = [file("../envs/k3s/argo-cd/release.yaml")]
}

# values = [templatefile("${path.module}/values.yaml",{})]
