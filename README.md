# Lab

A home lab for getting hands on with platform engineering tools and concepts.

## What it does

Deploys a simple web app to Azure Kubernetes Service. Every time I push a change to main, GitHub Actions builds a Docker image, pushes it to Azure Container Registry, and deploys it to AKS automatically. A health check script runs after deployment to verify the cluster is reachable and pods are running.

## Structure

| File | What it does |
|------|-------------|
| `index.html` | The web app |
| `Dockerfile` | Builds the Docker image |
| `deployment.yaml` | Tells Kubernetes how to run the app and expose it |
| `.github/workflows/deploy.yml` | The CI/CD pipeline |
| `terraform/main.tf` | Provisions all the Azure infrastructure |
| `scripts/health-check.sh` | Verifies AKS is reachable and pods are running after deployment |

## Infrastructure

Provisioned with Terraform so I can spin up and tear down quickly:

- Resource Group
- Azure Container Registry
- AKS cluster
- AcrPull role assignment

## First time setup

These only need doing once — they survive terraform destroy and apply cycles.

**1. Create a service principal**
```bash
az ad sp create-for-rbac --name "github-actions-lab" --role contributor --scopes /subscriptions/<subscription-id>/resourceGroups/platform-lab-rg --sdk-auth --years 10
```

Copy the entire JSON output and add it to GitHub as a secret called `AZURE_CREDENTIALS`.

**2. Add remaining GitHub secrets**

After running `terraform apply` (see below), get the ACR credentials:
```bash
terraform output acr_username
terraform output acr_password
```

Add these to GitHub secrets:
- `ACR_LOGIN_SERVER` — platformlablwr27.azurecr.io
- `ACR_USERNAME` — from terraform output
- `ACR_PASSWORD` — from terraform output

## Spin up

```bash
cd ~/lab/terraform
git pull
terraform apply
terraform output acr_username
terraform output acr_password
```

Update `ACR_USERNAME` and `ACR_PASSWORD` in GitHub secrets, then push a change to trigger the pipeline.

## Tear down

```bash
terraform destroy
```

## Tools used

GitHub Actions · Docker · Azure Container Registry · AKS · Terraform · kubectl · Bash

## Things I learned building this

- How CI/CD pipelines work end to end
- How Docker images get built and stored in a registry
- How Kubernetes deploys and manages containers
- How self-healing works in practice — deleted a pod and watched Kubernetes replace it automatically
- How to provision Azure infrastructure with Terraform
- How to write and run health check scripts in a pipeline
- How to manage secrets securely
- How to debug real errors — ImagePullBackOff, credential issues, missing manifests, duplicate Terraform outputs
