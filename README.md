# Token Validator

## Requirement
<<<<<<< HEAD
- Pre installed packages
  - `terraform`
  - `skopeo`
  - `git`
  - `kubectl`
  - `make`
- Running `docker` service

## Info
0. Example project with `terraform`, `argocd`, `helm chart` and k3s
=======

- `terraform`
- Running `docker` service

## Info
>>>>>>> fb2d2a5 (use latest tag for first deploy)
1. Using K3S in docker
2. Using docker registry on K3S
3. Terraform only for argo deploy
4. Any other deployments:
<<<<<<< HEAD
   - Argo release under `envs/k3s/` as `release.yaml`
   - Helm values related to K3S deployment under `envs/k3s/` as `values.yaml`
5. Token Validator under `token-validator`, contains:
   - Python script
   - Helm template under `chart` path

## Bring up K3S environment
### Run
```
make
```
### Get K3S_IP Address
```bash
K3S_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3s-service)
```
### K3S kubeconfig
```bash
export KUBECONFIG=envs/k3s/k3s.yaml
```
### URLS
| Service  | Connection  | user/password  |
|---|---|---|
| Grafana  | `http://${K3S_IP}:3000`  | `admin/admin@321`  |
| ArgoCD  | `http://$K3S_IP:30080`  | `admin/admin@321`  |


## Commiting changes on `token-validator`
### Build docker
```bash
make token-validator-build
```
### Publish to K3S registry
```bash
make token-validator-publish
```
### Update docker tag on helm values
```
envs/k3s/token-validator/values.yaml
```
with related tag
```bash
git describe --tags --always --abbrev=24
```
### Commit and push

## Cleaning
```bash
make clean
```
=======
   5. Argo release under `argocd/k3s/`
   6. Helm values related to K3S deployment under `envs/k3s/`
7. Token Validator under `token-validator`, contains:
   8. Python script
   9. Helm template under `chart` path
   10. Argo release deploy

## Bring up K3S environment
1. Run
```
make
```
2. Get K3S IP Address
```
K3S_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3s-service)
```
3. URLS:
   4. Grafana
      5. user/pass : `admin/admin@321`
      6. ip : `$K3S_IP:3000`
   7. Argo
      8. user/pass : `admin/admin@321`
      9. ip : `$K3S_IP:30080`
>>>>>>> fb2d2a5 (use latest tag for first deploy)
