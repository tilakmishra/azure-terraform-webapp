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

variable "unique_suffix" {
  description = "Unique suffix for globally unique resource names"
  type        = string
}

variable "db_subnet_id" {
  description = "ID of the database subnet for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone for Cosmos DB"
  type        = string
}

variable "private_dns_zone_name" {
  description = "Name of the private DNS zone for Cosmos DB"
  type        = string
}

variable "consistency_level" {
  description = "Cosmos DB consistency level"
  type        = string
  default     = "Session"
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover"
  type        = bool
  default     = false
}

variable "multiple_write_locations_enabled" {
  description = "Enable multiple write locations"
  type        = bool
  default     = false
}