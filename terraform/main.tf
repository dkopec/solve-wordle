terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Optional: Configure remote state in Azure Storage
  # Uncomment and configure after creating storage account
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstatesolvewordle"
  #   container_name       = "tfstate"
  #   key                  = "solve-wordle.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# Azure naming module for consistent resource naming
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.2"
  suffix  = [var.project_name]
}

locals {
  # Use Azure naming module for standardized, compliant names
  resource_group_name      = module.naming.resource_group.name
  container_app_env_name   = module.naming.container_app_environment.name
  container_app_name       = module.naming.container_app.name
  app_insights_name        = module.naming.application_insights.name
  log_analytics_name       = module.naming.log_analytics_workspace.name

  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Project   = var.project_name
  })
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Log Analytics Workspace for Container Apps
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

# Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                       = local.container_app_env_name
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = local.common_tags
}

# Container App
resource "azurerm_container_app" "main" {
  name                         = local.container_app_name
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "app"
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment == "production" ? "Production" : "Development"
      }

      dynamic "env" {
        for_each = var.enable_application_insights ? [1] : []
        content {
          name  = "ApplicationInsights__ConnectionString"
          value = azurerm_application_insights.main[0].connection_string
        }
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = local.common_tags
}

# Application Insights (Optional)
resource "azurerm_application_insights" "main" {
  count               = var.enable_application_insights ? 1 : 0
  name                = local.app_insights_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"

  tags = local.common_tags
}
