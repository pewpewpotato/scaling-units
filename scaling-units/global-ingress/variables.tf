variable "sku" {
  description = "The SKU of the Azure Front Door CDN Profile"
  type        = string
  validation {
    condition = contains([
      "Standard_AzureFrontDoor",
      "Premium_AzureFrontDoor"
    ], var.sku) && length(trimspace(var.sku)) > 0
    error_message = "SKU must be either 'Standard_AzureFrontDoor' or 'Premium_AzureFrontDoor' and cannot be empty."
  }
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  validation {
    condition     = length(trimspace(var.location)) > 0
    error_message = "Location cannot be empty."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  validation {
    condition = length(var.tags) > 0 && alltrue([
      for k, v in var.tags :
      length(k) <= 512 &&
      length(v) <= 256 &&
      !startswith(lower(k), "ms-") &&
      !startswith(lower(k), "azure-") &&
      can(regex("^[a-zA-Z0-9\\+\\-\\=\\.\\_\\:\\/]+$", k)) &&
      can(regex("^[^<>%&\\\\?/]*$", v))
    ])
    error_message = "Tags must be non-empty, tag keys max 512 chars, values max 256 chars. Keys cannot start with 'ms-' or 'azure-' (reserved). Keys must be alphanumeric with +-.=_:/. Values cannot contain <>%&\\?/."
  }
}

variable "custom_domain" {
  description = "The custom domain for the CDN profile"
  type        = string
  validation {
    condition = length(trimspace(var.custom_domain)) > 0 && can(regex("^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.[a-zA-Z]{2,}$", var.custom_domain)) && !can(regex("[\\x00-\\x1F\\x7F]", var.custom_domain)) && !can(regex("\\.\\./", var.custom_domain)) && length(var.custom_domain) <= 253
    error_message = "Custom domain must be a valid ASCII domain name (max 253 chars), cannot contain control characters or path traversal sequences (..), and cannot be empty."
  }
}

variable "suffix" {
  description = "Suffix to append to resource names for uniqueness"
  type        = string
  validation {
    condition = can(regex("^[a-zA-Z0-9]+$", var.suffix)) && length(var.suffix) >= 1 && length(var.suffix) <= 10 && !can(regex("[\\x00-\\x1F\\x7F]", var.suffix)) && !contains(["microsoft", "azure", "windows"], lower(var.suffix))
    error_message = "Suffix must be alphanumeric, 1-10 characters, cannot contain control characters, and cannot be reserved words (microsoft, azure, windows)."
  }
}
