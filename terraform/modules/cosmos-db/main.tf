# Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                = "${var.project_name}-${var.environment}-cosmos-${var.unique_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  automatic_failover_enabled         = var.automatic_failover_enabled
  multiple_write_locations_enabled   = var.multiple_write_locations_enabled
  public_network_access_enabled      = false
  is_virtual_network_filter_enabled  = true

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  # Network access control
  network_acl_bypass_for_azure_services = false
  network_acl_bypass_ids                = []

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "employees"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = 400
}

# Cosmos DB SQL Container for Employees
resource "azurerm_cosmosdb_sql_container" "employees" {
  name                  = "employees"
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths   = ["/department"]
  partition_key_version = 1
  throughput            = 400

  indexing_policy {
    indexing_mode = "consistent"

    included_path {
      path = "/*"
    }

    excluded_path {
      path = "/\"_etag\"/?"
    }
  }

  # Note: /id is a system property and cannot be used as unique key
  # Use business-specific fields like /employeeId or /email instead
  unique_key {
    paths = ["/employeeId"]
  }
}

# Private Endpoint for Cosmos DB
resource "azurerm_private_endpoint" "cosmos" {
  name                = "${var.project_name}-${var.environment}-cosmos-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.db_subnet_id

  private_service_connection {
    name                           = "${var.project_name}-${var.environment}-cosmos-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  # DNS zone group auto-creates A records - no need for manual azurerm_private_dns_a_record
  private_dns_zone_group {
    name                 = "${var.project_name}-${var.environment}-cosmos-dns-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Note: Private DNS A Record is automatically created by private_dns_zone_group above
# Manual azurerm_private_dns_a_record removed to avoid conflict