# Token Validator

## Requirement
- Packages
  - `terraform`
  - `skopeo`
  - `git`
- Running `docker` service

## Info
1. Using K3S in docker
2. Using docker registry on K3S
3. Terraform only for argo deploy
4. Any other deployments:
   - Argo release under `argocd/k3s/`
   - Helm values related to K3S deployment under `envs/k3s/`
7. Token Validator under `token-validator`, contains:
   - Python script
   - Helm template under `chart` path
   - Argo release deploy

## Bring up K3S environment
### Run
```
make
```
### Get K3S_IP Address
```
K3S_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3s-service)
```
### K3S kubeconfig
```
export KUBECONFIG=envs/k3s/k3s.yaml
```
### URLS
#### Grafana
##### user/pass : 
`admin/admin@321`
##### ip : 
`$K3S_IP:3000`
#### Argo
##### user/pass : 
`admin/admin@321`
##### ip :
`$K3S_IP:30080`

## Commiting changes on `token-validator`
### Build docker
```
make token-validator-build
```
### Publish to K3S registry
```
make token-validator-publish
```
### Update docker tag on helm values `envs/k3s/podinfo/values.yaml`
```
git describe --tags --always --abbrev=24
```
### Commit and push

## Cleaning
```
make clean
```
