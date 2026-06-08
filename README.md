# Lab

Personal home lab I built to get hands on with platform engineering. Started from scratch so some of this was trial and error.

## What it does

Deploys a web app through a full staging and production pipeline. Push a change to main, GitHub Actions builds a Docker image, deploys to staging automatically, runs a health check, then waits for manual approval before deploying to production.

## Pipeline flow

Push to main → Build image → push to ACR → Deploy to staging → health check → Manual approval → Deploy to production → health check → Live

## Files

| File | What it does |
|------|-------------|
| `index.html` | The app |
| `Dockerfile` | Builds the image |
| `k8s/staging.yaml` | Kubernetes config for staging |
| `k8s/production.yaml` | Kubernetes config for production |
| `.github/workflows/deploy.yml` | Pipeline |
| `terraform/main.tf` | Azure infrastructure |
| `scripts/health-check.sh` | Post-deploy health check |

## Infrastructure

All provisioned with Terraform so I can spin it up and tear it down without clicking around the portal.

- Resource Group
- Azure Container Registry
- AKS cluster
- AcrPull role so AKS can pull from ACR

## Auth

Uses OIDC so there are no stored passwords or credentials to rotate. GitHub and Azure trust each other directly via federated credentials — one scoped to the main branch, one scoped to the production environment.

Secrets needed:
- ACR_LOGIN_SERVER
- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID

## Spin up

git clone https://github.com/lwr27/lab.git

cd lab/terraform

terraform init

terraform apply

Push a change to index.html to trigger the pipeline.

## Tear down

terraform destroy

## Stack

GitHub Actions · Docker · ACR · AKS · Terraform · Bash · OIDC · Kubernetes namespaces
