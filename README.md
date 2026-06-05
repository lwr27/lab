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
