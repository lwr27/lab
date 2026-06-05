# Lab

A home lab for getting hands on with platform engineering tools and concepts.

## What it does

Deploys a simple web app to Azure Kubernetes Service. Every time I push a change to main, GitHub Actions builds a Docker image, pushes it to Azure Container Registry, and deploys it to AKS automatically.

## Structure

| File | What it does |
|------|-------------|
| `index.html` | The web app |
| `Dockerfile` | Builds the Docker image |
| `deployment.yaml` | Tells Kubernetes how to run the app and expose it |
| `.github/workflows/deploy.yml` | The CI/CD pipeline |
| `terraform/main.tf` | Provisions all the Azure infrastructure |

## Infrastructure

Provisioned with Terraform so I can spin up and tear down quickly:

- Resource Group
- Azure Container Registry
- AKS cluster
- AcrPull role assignment

## Spin up

```bash
cd ~/lab/terraform
git pull
terraform apply
terraform output acr_username
terraform output acr_password
```

Update ACR secrets in GitHub then push a change to trigger the pipeline.

## Tear down

```bash
terraform destroy
```

## Tools

GitHub Actions · Docker · Azure Container Registry · AKS · Terraform · kubectl
