# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# Networking Outputs
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = module.networking.app_subnet_id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = module.networking.db_subnet_id
}

# Cosmos DB Outputs
output "cosmos_account_name" {
  description = "Name of the Cosmos DB account"
  value       = module.cosmos_db.cosmos_account_name
}

output "cosmos_endpoint" {
  description = "Cosmos DB endpoint"
  value       = module.cosmos_db.cosmos_endpoint
}

output "database_name" {
  description = "Name of the Cosmos DB database"
  value       = module.cosmos_db.database_name
}

output "container_name" {
  description = "Name of the employees container"
  value       = module.cosmos_db.container_name
}

# App Service Outputs
output "app_service_name" {
  description = "Name of the App Service"
  value       = module.app_service.app_service_name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = module.app_service.app_service_url
}

output "app_service_managed_identity_principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = module.app_service.managed_identity_principal_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.app_service.key_vault_name
}

# Frontend Outputs
output "static_web_app_name" {
  description = "Name of the Static Web App"
  value       = module.frontend.static_web_app_name
}

output "static_web_app_url" {
  description = "URL of the Static Web App"
  value       = module.frontend.static_web_app_url
}

output "static_web_app_hostname" {
  description = "Default hostname of the Static Web App"
  value       = module.frontend.default_host_name
}

# Deployment Information
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    frontend_url    = module.frontend.static_web_app_url
    backend_url     = module.app_service.app_service_url
    cosmos_endpoint = module.cosmos_db.cosmos_endpoint
    environment     = var.environment
    location        = var.location
  }
}