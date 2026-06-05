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

## Authentication

Uses OIDC (OpenID Connect) for passwordless authentication between GitHub Actions and Azure — no secrets to rotate or expire. A federated credential scoped to this repository allows the pipeline to authenticate directly without stored passwords.

GitHub secrets required:
- `ACR_LOGIN_SERVER` — ACR address (non-sensitive)
- `AZURE_CLIENT_ID` — OIDC app registration
- `AZURE_TENANT_ID` — Azure tenant
- `AZURE_SUBSCRIPTION_ID` — Azure subscription

## Spin up

```bash
git clone https://github.com/lwr27/lab.git
cd lab/terraform
terraform init
terraform apply
```

Then push a change to trigger the pipeline — no credential updates needed.

## Tear down

```bash
terraform destroy
```

## Tools used

GitHub Actions · Docker · Azure Container Registry · AKS · Terraform · kubectl · Bash · OIDC

## Things I learned building this

- How CI/CD pipelines work end to end
- How Docker images get built and stored in a registry
- How Kubernetes deploys and manages containers
- How self-healing works in practice
- How to provision Azure infrastructure with Terraform
- How to write and run health check scripts in a pipeline
- How to implement passwordless OIDC authentication between GitHub and Azure
- How to debug real errors — ImagePullBackOff, credential issues, missing manifests
