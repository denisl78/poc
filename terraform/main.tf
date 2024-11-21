resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [file("../envs/k3s/argo-cd/release.yaml")]
}

# values = [templatefile("${path.module}/values.yaml",{})]
