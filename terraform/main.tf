# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
  
  # Configure backend for remote state (optional)
  # backend "azurerm" {
  #   resource_group_name   = "terraform-state-rg"
  #   storage_account_name  = "terraformstatestg"
  #   container_name        = "tfstate"
  #   key                   = "employee-management.tfstate"
  # }
}

# Configure the Azure Provider features
provider "azurerm" {
  skip_provider_registration = true
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Random suffix for globally unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${local.project_name}-${var.environment}-rg"
  location = var.location

  tags = local.common_tags
}

# Local values
locals {
  prefix        = "dte"
  project_name  = "${local.prefix}-${var.project_name}"
  unique_suffix = random_string.suffix.result
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = local.project_name

  vnet_address_space              = var.vnet_address_space
  app_subnet_address_prefixes     = var.app_subnet_address_prefixes
  db_subnet_address_prefixes      = var.db_subnet_address_prefixes
  frontend_subnet_address_prefixes = var.frontend_subnet_address_prefixes
}

# Cosmos DB Module
module "cosmos_db" {
  source = "./modules/cosmos-db"

  resource_group_name     = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  environment            = var.environment
  project_name           = local.project_name
  unique_suffix          = local.unique_suffix

  db_subnet_id           = module.networking.db_subnet_id
  private_dns_zone_id    = module.networking.cosmos_private_dns_zone_id
  private_dns_zone_name  = module.networking.cosmos_private_dns_zone_name

  consistency_level                  = var.cosmos_consistency_level
  automatic_failover_enabled         = var.cosmos_automatic_failover_enabled
  multiple_write_locations_enabled   = var.cosmos_multiple_write_locations_enabled
}

# App Service Module
module "app_service" {
  source = "./modules/app-service"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = local.project_name

  app_subnet_id      = module.networking.app_subnet_id
  cosmos_endpoint    = module.cosmos_db.cosmos_endpoint
  cosmos_account_name = module.cosmos_db.cosmos_account_name
  cosmos_account_id  = module.cosmos_db.cosmos_account_id
  cosmos_primary_key = module.cosmos_db.cosmos_primary_key
  database_name      = module.cosmos_db.database_name
  container_name     = module.cosmos_db.container_name

  sku_name = var.app_service_sku_name
  os_type  = var.app_service_os_type
}

# Frontend Module
module "frontend" {
  source = "./modules/frontend"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  environment        = var.environment
  project_name       = local.project_name

  app_service_url = module.app_service.app_service_url
  sku_tier       = var.static_web_app_sku_tier
  sku_size       = var.static_web_app_sku_size
}