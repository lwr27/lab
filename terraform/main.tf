# Provisions Azure infrastructure for platform lab
# Run: terraform init && terraform apply
# Destroy: terraform destroy

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
  }
  skip_provider_registration = true
}

# Variables
variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "platform-lab-rg"
}

variable "acr_name" {
  default = "platformlablwr27"
}

variable "aks_name" {
  default = "platform-lab-aks"
}

variable "alert_email" {
  description = "Email address for monitoring alerts"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.aks_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "platformlab"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DC2as_v5"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }
}

# Attach ACR to AKS
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "platform-lab-logs"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Connect AKS to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "aks-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "kube-audit"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Action group — where to send alerts
resource "azurerm_monitor_action_group" "email" {
  name                = "platform-lab-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "lab-alerts"

  email_receiver {
    name          = "Admin"
    email_address = var.alert_email
  }
}

# Alert when pod count drops to zero
resource "azurerm_monitor_metric_alert" "pods_down" {
  name                = "no-pods-running"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_kubernetes_cluster.main.id]
  description         = "Alert when no pods are running in the cluster"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "kube_pod_status_ready"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.email.id
  }
}

# Outputs
output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}
