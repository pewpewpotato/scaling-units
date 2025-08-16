variable "vnet_name" {
  description = "The name of the existing virtual network where APIM will be integrated"
  type        = string

  validation {
    condition = (
      length(var.vnet_name) > 0 &&
      length(var.vnet_name) <= 64 &&
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?$", var.vnet_name))
    )
    error_message = "Virtual network name must be 1-64 characters, start and end with alphanumeric characters, and contain only letters, numbers, periods, hyphens, and underscores."
  }
}

variable "vnet_resource_group_name" {
  description = "The name of the resource group containing the existing virtual network"
  type        = string

  validation {
    condition = (
      length(var.vnet_resource_group_name) > 0 &&
      length(var.vnet_resource_group_name) <= 90 &&
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?$", var.vnet_resource_group_name))
    )
    error_message = "Resource group name must be 1-90 characters, start and end with alphanumeric characters, and contain only letters, numbers, periods, hyphens, and underscores."
  }
}

variable "nsg_name" {
  description = "The name of the existing network security group to associate with the APIM subnet"
  type        = string

  validation {
    condition = (
      length(var.nsg_name) > 0 &&
      length(var.nsg_name) <= 80 &&
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?$", var.nsg_name))
    )
    error_message = "NSG name must be 1-80 characters, start and end with alphanumeric characters, and contain only letters, numbers, periods, hyphens, and underscores."
  }
}

variable "nsg_resource_group_name" {
  description = "The name of the resource group containing the existing network security group"
  type        = string

  validation {
    condition = (
      length(var.nsg_resource_group_name) > 0 &&
      length(var.nsg_resource_group_name) <= 90 &&
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?$", var.nsg_resource_group_name))
    )
    error_message = "Resource group name must be 1-90 characters, start and end with alphanumeric characters, and contain only letters, numbers, periods, hyphens, and underscores."
  }
}

variable "apim_subnet_prefix" {
  description = "The address prefix for the APIM subnet in CIDR notation"
  type        = string

  validation {
    condition = (
      can(cidrhost(var.apim_subnet_prefix, 0)) &&
      can(cidrnetmask(var.apim_subnet_prefix)) &&
      tonumber(split("/", var.apim_subnet_prefix)[1]) >= 16 &&
      tonumber(split("/", var.apim_subnet_prefix)[1]) <= 29
    )
    error_message = "The apim_subnet_prefix must be a valid CIDR block with a subnet mask between /16 and /29 (suitable for APIM deployment)."
  }
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string

  validation {
    condition = (
      length(var.location) > 0 &&
      length(var.location) <= 50 &&
      can(regex("^[a-zA-Z0-9 ]+$", var.location))
    )
    error_message = "Location must be a valid Azure region name (1-50 characters, letters, numbers, and spaces only)."
  }
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)

  validation {
    condition = alltrue([
      for k, v in var.tags : (
        length(k) > 0 &&
        length(k) <= 512 &&
        length(v) <= 256 &&
        !startswith(k, "microsoft") &&
        !startswith(k, "azure") &&
        !startswith(k, "windows")
      )
    ])
    error_message = "Tag keys must be 1-512 characters, values must be ≤256 characters, and keys cannot start with 'microsoft', 'azure', or 'windows' (case-insensitive)."
  }
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
