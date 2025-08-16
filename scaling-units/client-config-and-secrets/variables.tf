variable "location" {
  description = "The Azure region where resources will be created"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must be a non-empty string."
  }
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string

  validation {
    condition     = length(var.vnet_name) > 0
    error_message = "VNET name must be a non-empty string."
  }
}

variable "vnet_resource_id" {
  description = "The resource ID of the virtual network"
  type        = string

  validation {
    condition = can(regex("^/subscriptions/[a-fA-F0-9-]{36}/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+$", var.vnet_resource_id))
    error_message = "VNET resource ID must be a valid Azure virtual network resource ID format."
  }
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string

  validation {
    condition     = length(var.subnet_name) > 0
    error_message = "Subnet name must be a non-empty string."
  }
}

variable "subnet_resource_id" {
  description = "The resource ID of the subnet"
  type        = string

  validation {
    condition = can(regex("^/subscriptions/[a-fA-F0-9-]{36}/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.subnet_resource_id))
    error_message = "Subnet resource ID must be a valid Azure subnet resource ID format."
  }
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 50
    error_message = "Azure supports a maximum of 50 tags per resource."
  }
}

variable "suffix" {
  description = "The suffix to append to resource names for uniqueness"
  type        = string

  validation {
    condition = (
      can(regex("^[a-zA-Z0-9]+$", var.suffix)) &&
      length(var.suffix) > 0 &&
      length(var.suffix) <= 10 &&
      !contains(["azure", "microsoft", "windows"], lower(var.suffix))
    )
    error_message = "Suffix must be a non-empty alphanumeric string, 10 characters or less, and cannot contain reserved words like 'azure', 'microsoft', or 'windows'."
  }
}

variable "key_vault_sku" {
  description = "The SKU name of the Key Vault. Possible values are standard and premium"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}

variable "app_configuration_sku" {
  description = "The SKU name of the App Configuration. Possible values are free and standard"
  type        = string
  default     = "free"

  validation {
    condition     = contains(["free", "standard"], var.app_configuration_sku)
    error_message = "App Configuration SKU must be either 'free' or 'standard'."
  }
}
