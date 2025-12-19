variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "app_service_url" {
  description = "URL of the backend App Service"
  type        = string
}

variable "sku_tier" {
  description = "SKU tier for Static Web App"
  type        = string
  default     = "Free"
}

variable "sku_size" {
  description = "SKU size for Static Web App"
  type        = string
  default     = "Free"
}