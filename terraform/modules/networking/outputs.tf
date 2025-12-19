output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "app_subnet_id" {
  description = "ID of the app subnet"
  value       = azurerm_subnet.app.id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.db.id
}

output "frontend_subnet_id" {
  description = "ID of the frontend subnet"
  value       = azurerm_subnet.frontend.id
}

output "cosmos_private_dns_zone_id" {
  description = "ID of the Cosmos DB private DNS zone"
  value       = azurerm_private_dns_zone.cosmos.id
}

output "cosmos_private_dns_zone_name" {
  description = "Name of the Cosmos DB private DNS zone"
  value       = azurerm_private_dns_zone.cosmos.name
}