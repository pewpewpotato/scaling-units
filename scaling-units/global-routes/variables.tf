# ================================================================
# Required Input Variables
# ================================================================

variable "apim_fqdn" {
  description = "The FQDN of the Azure API Management instance to route traffic to"
  type        = string

  validation {
    condition = (
      length(var.apim_fqdn) > 0 &&
      length(var.apim_fqdn) <= 253 &&
      can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.apim_fqdn)) &&
      !can(regex("^\\.", var.apim_fqdn)) &&
      !can(regex("\\.$", var.apim_fqdn))
    )
    error_message = "APIM FQDN must be a valid domain name between 1-253 characters, not starting or ending with a dot."
  }
}

variable "custom_domain" {
  description = "The custom domain to associate with the Front Door route"
  type        = string

  validation {
    condition = (
      length(var.custom_domain) > 0 &&
      length(var.custom_domain) <= 253 &&
      can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.custom_domain)) &&
      !can(regex("^\\.", var.custom_domain)) &&
      !can(regex("\\.$", var.custom_domain))
    )
    error_message = "Custom domain must be a valid domain name between 1-253 characters, not starting or ending with a dot."
  }
}

variable "route_name" {
  description = "The name of the Front Door route"
  type        = string

  validation {
    condition = (
      length(var.route_name) > 0 &&
      length(var.route_name) <= 80 &&
      can(regex("^[a-zA-Z0-9-]+$", var.route_name)) &&
      !can(regex("^-", var.route_name)) &&
      !can(regex("-$", var.route_name))
    )
    error_message = "Route name must be 1-80 characters, contain only alphanumeric characters and hyphens, and not start or end with a hyphen."
  }
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must be a non-empty string."
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

# ================================================================
# Optional Input Variables
# ================================================================

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
