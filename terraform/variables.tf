variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "employee-mgmt"
  
  validation {
    condition     = can(regex("^[a-z0-9-]{3,15}$", var.project_name))
    error_message = "Project name must be 3-15 characters long and contain only lowercase letters, numbers, and hyphens."
  }
}

# Networking Variables
variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_address_prefixes" {
  description = "Address prefixes for the app subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "db_subnet_address_prefixes" {
  description = "Address prefixes for the database subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "frontend_subnet_address_prefixes" {
  description = "Address prefixes for the frontend subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

# Cosmos DB Variables
variable "cosmos_consistency_level" {
  description = "Cosmos DB consistency level"
  type        = string
  default     = "Session"
  
  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.cosmos_consistency_level)
    error_message = "Consistency level must be BoundedStaleness, Eventual, Session, Strong, or ConsistentPrefix."
  }
}

variable "cosmos_automatic_failover_enabled" {
  description = "Enable automatic failover for Cosmos DB"
  type        = bool
  default     = false
}

variable "cosmos_multiple_write_locations_enabled" {
  description = "Enable multiple write locations for Cosmos DB"
  type        = bool
  default     = false
}

# App Service Variables
variable "app_service_sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "B1"
  
  validation {
    condition = contains([
      "F1", "D1", "B1", "B2", "B3", 
      "S1", "S2", "S3", 
      "P1", "P2", "P3", "P4",
      "P1V2", "P2V2", "P3V2",
      "P1V3", "P2V3", "P3V3"
    ], var.app_service_sku_name)
    error_message = "App Service SKU must be a valid Azure App Service Plan SKU."
  }
}

variable "app_service_os_type" {
  description = "OS type for the App Service Plan"
  type        = string
  default     = "Linux"
  
  validation {
    condition     = contains(["Linux", "Windows"], var.app_service_os_type)
    error_message = "OS type must be Linux or Windows."
  }
}

# Static Web App Variables
variable "static_web_app_sku_tier" {
  description = "SKU tier for Static Web App"
  type        = string
  default     = "Free"
  
  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_tier)
    error_message = "Static Web App SKU tier must be Free or Standard."
  }
}

variable "static_web_app_sku_size" {
  description = "SKU size for Static Web App"
  type        = string
  default     = "Free"
  
  validation {
    condition     = contains(["Free", "Standard"], var.static_web_app_sku_size)
    error_message = "Static Web App SKU size must be Free or Standard."
  }
}