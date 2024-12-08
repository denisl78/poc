# Token Validator

## Requirement
- Pre installed packages
  - `terraform`
  - `skopeo`
  - `git`
  - `kubectl`
  - `make`
- Running `docker` service

## Info
0. Example project with `terraform`, `argocd`, `helm chart` and k3s
1. Using K3S in docker
2. Using docker registry on K3S
3. Terraform only for argo deploy
4. Any other deployments:
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
