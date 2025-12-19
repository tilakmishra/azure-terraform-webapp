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

variable "app_subnet_id" {
  description = "ID of the app service subnet"
  type        = string
}

variable "cosmos_endpoint" {
  description = "Cosmos DB endpoint"
  type        = string
}

variable "cosmos_account_name" {
  description = "Cosmos DB account name"
  type        = string
}

variable "cosmos_account_id" {
  description = "Cosmos DB account ID"
  type        = string
}

variable "cosmos_primary_key" {
  description = "Cosmos DB primary key"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Cosmos DB database name"
  type        = string
}

variable "container_name" {
  description = "Cosmos DB container name"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "os_type" {
  description = "OS type for the App Service Plan"
  type        = string
  default     = "Linux"
}