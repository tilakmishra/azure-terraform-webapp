
# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-${var.environment}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# User Assigned Managed Identity for App Service
resource "azurerm_user_assigned_identity" "app_service" {
  name                = "${var.project_name}-${var.environment}-app-identity"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "${var.project_name}-${var.environment}-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  # Disable public network access for security
  public_network_access_enabled = false

  # Enable system assigned managed identity
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_service.id]
  }

  # VNet integration for outbound traffic
  virtual_network_subnet_id = var.app_subnet_id

  site_config {
    always_on                         = false
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    remote_debugging_enabled          = false
    scm_use_main_ip_restriction       = true
    vnet_route_all_enabled            = true
    
    # Configure Python runtime for Linux Web App
    application_stack {
      python_version = "3.11"
    }

    # Restrict access to VNet and Frontend only
    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Deny"

    cors {
      allowed_origins = ["*"]
      support_credentials = false
    }
  }

  # Application settings
  app_settings = {
    "COSMOS_ENDPOINT"     = var.cosmos_endpoint
    "COSMOS_DATABASE"     = var.database_name
    "COSMOS_CONTAINER"    = var.container_name
    "PYTHON_ENV"          = var.environment
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD"              = "true"
  }

  # Connection strings - using managed identity
  connection_string {
    name  = "CosmosDB"
    type  = "Custom"
    value = "AccountEndpoint=${var.cosmos_endpoint};Database=${var.database_name};"
  }

  https_only = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Key Vault for storing secrets (optional, using managed identity instead)
resource "azurerm_key_vault" "main" {
  name                = "kv-${var.environment}-${random_string.kv_suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization = true
  purge_protection_enabled  = false

  # Allow access from Azure services and current user for Terraform operations
  network_acls {
    default_action = "Allow"  # Changed to Allow for Terraform access
    bypass         = "AzureServices"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Random string for Key Vault name uniqueness
resource "random_string" "kv_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Role assignment for App Service to access Cosmos DB
resource "azurerm_cosmosdb_sql_role_assignment" "app_service" {
  resource_group_name = var.resource_group_name
  account_name        = var.cosmos_account_name
  role_definition_id  = "${var.cosmos_account_id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002" # Cosmos DB Built-in Data Contributor
  principal_id        = azurerm_linux_web_app.main.identity[0].principal_id
  scope               = var.cosmos_account_id
}

# Key Vault access policy for App Service managed identity
resource "azurerm_role_assignment" "app_service_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.main.identity[0].principal_id
}

# Key Vault access for Terraform user to create secrets
resource "azurerm_role_assignment" "terraform_kv_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Store Cosmos DB key in Key Vault (for backup access if needed)
resource "azurerm_key_vault_secret" "cosmos_key" {
  name         = "cosmos-primary-key"
  value        = var.cosmos_primary_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_role_assignment.app_service_kv_secrets_user,
    azurerm_role_assignment.terraform_kv_secrets_officer
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}