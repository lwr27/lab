# Lab

Personal home lab built to get hands on with platform engineering concepts.

## What it does

Deploys a web app through a full staging and production pipeline on Azure Kubernetes Service. Infrastructure is provisioned with Terraform and authentication uses OIDC — no stored passwords anywhere.

---

## Pipeline

Push a change to main and this happens automatically:

1. Docker image built and pushed to Azure Container Registry
2. Deployed to staging namespace and health checked
3. Pipeline pauses for manual approval
4. Deployed to production namespace and health checked

![Pipeline paused waiting for approval](screenshots/approval-gate.png)

![All stages green after approval](screenshots/pipeline-complete.png)

---

## Infrastructure

Provisioned with Terraform — spin up with one command, tear down with one command.

![Terraform apply complete](screenshots/terraform-apply.png)

Resources created:
- Resource Group
- Azure Container Registry
- AKS cluster
- AcrPull role assignment

---

## Live app

![App running in browser](screenshots/live-app.png)

Both staging and production run as separate namespaces on the same cluster with their own public IPs.

![Staging and production services in AKS](screenshots/aks-services.png)

---

## Auth

Uses OIDC — GitHub and Azure trust each other directly via federated credentials. No passwords, nothing to rotate or expire.

Two federated credentials:
- Scoped to `refs/heads/main` for the build and staging stages
- Scoped to `environment:production` for the production stage

![GitHub secrets — IDs only, no passwords](screenshots/github-secrets.png)

Secrets needed:
- `ACR_LOGIN_SERVER`
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

---

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

---

## Spin up

```bash
git clone https://github.com/lwr27/lab.git
cd lab/terraform
terraform init
terraform apply
```

Push a change to `index.html` to trigger the pipeline.

## Tear down

```bash
terraform destroy
```
![Terraform destory results](screenshots/terraform-destroy.png)
---

## Stack

GitHub Actions · Docker · ACR · AKS · Terraform · Bash · OIDC · Kubernetes namespaces
