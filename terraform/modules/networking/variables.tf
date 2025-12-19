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