# Static Web App for Frontend
resource "azurerm_static_web_app" "main" {
  name                = "${var.project_name}-${var.environment}-frontend"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = var.sku_tier
  sku_size            = var.sku_size

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Note: Static Web App configuration (routes, fallback, etc.) should be done via
# staticwebapp.config.json in your frontend application, not through Terraform.
# See: https://learn.microsoft.com/en-us/azure/static-web-apps/configuration