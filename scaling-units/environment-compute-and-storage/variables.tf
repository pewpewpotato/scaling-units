variable "location" {
  description = "The Azure region where resources will be created"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must be a non-empty string."
  }
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
}

variable "suffix" {
  description = "The suffix to append to resource names for uniqueness"
  type        = string

  validation {
    condition = (
      can(regex("^[a-zA-Z0-9]+$", var.suffix)) &&
      length(var.suffix) > 0 &&
      length(var.suffix) <= 10
    )
    error_message = "Suffix must be a non-empty alphanumeric string and must be 10 characters or less."
  }
}

variable "aca_environment_sku" {
  description = "The SKU for the Azure Container Apps Environment"
  type        = string

  validation {
    condition     = length(var.aca_environment_sku) > 0
    error_message = "ACA Environment SKU must be a non-empty string."
  }

  validation {
    condition = contains([
      "Consumption",
      "Premium"
    ], var.aca_environment_sku)
    error_message = "ACA Environment SKU must be one of: Consumption, Premium."
  }
}

variable "aca_environment_subnet_id" {
  description = "The subnet ID where the Azure Container Apps Environment will be deployed"
  type        = string

  validation {
    condition     = length(var.aca_environment_subnet_id) > 0
    error_message = "ACA Environment subnet ID must be a non-empty string."
  }

  validation {
    condition = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", var.aca_environment_subnet_id))
    error_message = "ACA Environment subnet ID must be a valid Azure subnet resource ID."
  }
}

variable "cosmos_db_sku" {
  description = "The SKU for the Azure Cosmos DB Account"
  type        = string

  validation {
    condition     = length(var.cosmos_db_sku) > 0
    error_message = "Cosmos DB SKU must be a non-empty string."
  }

  validation {
    condition = contains([
      "Standard"
    ], var.cosmos_db_sku)
    error_message = "Cosmos DB SKU must be 'Standard'."
  }
}

variable "vnet_core_subnet_id" {
  description = "The VNET core subnet ID for the Cosmos DB private endpoint"
  type        = string

  validation {
    condition     = length(var.vnet_core_subnet_id) > 0
    error_message = "VNET core subnet ID must be a non-empty string."
  }

  validation {
    condition = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", var.vnet_core_subnet_id))
    error_message = "VNET core subnet ID must be a valid Azure subnet resource ID."
  }
}

variable "vnet_id" {
  description = "The VNET ID for the private DNS zone link"
  type        = string

  validation {
    condition     = length(var.vnet_id) > 0
    error_message = "VNET ID must be a non-empty string."
  }

  validation {
    condition = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+$", var.vnet_id))
    error_message = "VNET ID must be a valid Azure VNET resource ID."
  }
}
