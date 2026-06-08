# Lab

Personal home lab I built to get hands on with platform engineering. Started from scratch so some of this was trial and error.

## What it does

Deploys a web app to AKS. Push a change to main, GitHub Actions picks it up, builds a Docker image, pushes it to ACR and deploys it to Kubernetes. Health check runs after to make sure everything came up okay.

## Files

| File | What it does |
|------|-------------|
| `index.html` | The app |
| `Dockerfile` | Builds the image |
| `deployment.yaml` | Kubernetes config |
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

Uses OIDC so there are no stored passwords or credentials to rotate. GitHub and Azure trust each other directly via a federated credential scoped to this repo.

Secrets needed:
- `ACR_LOGIN_SERVER`
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

## Spin up

```bash
git clone https://github.com/lwr27/lab.git
cd lab/terraform
terraform init
terraform apply
```

Push a change to index.html to trigger the pipeline.

## Tear down

```bash
terraform destroy
```

## Stack

GitHub Actions · Docker · ACR · AKS · Terraform · Bash · OIDC
