# Lab

A home lab I built to get hands on with platform engineering concepts while preparing for a role in the field.

## What it does

Deploys a simple web app to Azure Kubernetes Service using a fully automated CI/CD pipeline. Every time I push a change to main, GitHub Actions builds a Docker image, pushes it to Azure Container Registry, and deploys it to AKS automatically.

## How it's structured

| File | What it does |
|------|-------------|
| `index.html` | The web app |
| `Dockerfile` | Builds the Docker image |
| `deployment.yaml` | Tells Kubernetes how to run the app and expose it |
| `.github/workflows/deploy.yml` | The CI/CD pipeline |
| `terraform/main.tf` | Provisions all the Azure infrastructure |

## Infrastructure

Everything in Azure is provisioned with Terraform so I can spin it up and tear it down quickly without clicking around the portal:

- Resource Group
- Azure Container Registry
- AKS cluster
- AcrPull role assignment so AKS can pull images from ACR

## Spinning it up

```bash
cd ~/lab/terraform
git pull
terraform apply
terraform output acr_username
terraform output acr_password
```

Update the ACR secrets in GitHub then push a change to trigger the pipeline.

## Tearing it down

```bash
terraform destroy
```

## Things I learned building this

- How CI/CD pipelines actually work end to end
- How Docker images get built and stored in a registry
- How Kubernetes deploys and manages containers
- How to provision Azure infrastructure with Terraform
- How to debug real errors — ImagePullBackOff, credential issues, missing manifests
- How to manage secrets securely
