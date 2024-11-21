provider "kubernetes" {
   config_path = "../envs/k3s/k3s.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "../envs/k3s/k3s.yaml"
  }
}

