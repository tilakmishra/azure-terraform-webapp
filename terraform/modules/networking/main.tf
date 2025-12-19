# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-${var.environment}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Subnet for App Service
resource "azurerm_subnet" "app" {
  name                 = "${var.project_name}-${var.environment}-app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.app_subnet_address_prefixes

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for Cosmos DB Private Endpoint
resource "azurerm_subnet" "db" {
  name                 = "${var.project_name}-${var.environment}-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.db_subnet_address_prefixes
  
  private_endpoint_network_policies = "Disabled"
}

# Subnet for Static Web App (Frontend)
resource "azurerm_subnet" "frontend" {
  name                 = "${var.project_name}-${var.environment}-frontend-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.frontend_subnet_address_prefixes
}

# Network Security Group for App Service
resource "azurerm_network_security_group" "app" {
  name                = "${var.project_name}-${var.environment}-app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Network Security Group for Database
resource "azurerm_network_security_group" "db" {
  name                = "${var.project_name}-${var.environment}-db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowAppSubnet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.app_subnet_address_prefixes
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Associate NSG with App Subnet
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# Associate NSG with Database Subnet
resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.db.id
  network_security_group_id = azurerm_network_security_group.db.id
}

# Private DNS Zone for Cosmos DB
resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Link Private DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "cosmos" {
  name                  = "${var.project_name}-${var.environment}-cosmos-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}