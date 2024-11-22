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
2. Get K3S_IP Address
```
K3S_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' k3s-service)
```
3. URLS:
   4. Grafana
    * user/pass : `admin/admin@321`
    * ip : `$K3S_IP:3000`
   7. Argo
    * user/pass : `admin/admin@321`
    * ip : `$K3S_IP:30080`

## Commiting changes on `token-validator`
1. Build docker
```
make token-validator-build
```
3. Publish to K3S registry
```
make token-validator-publish
```
5. Update docker tag on helm values `envs/k3s/podinfo/values.yaml`
```
git describe --tags --always --abbrev=24
```
6. Commit and push

## Cleaning
```
make clean
```
