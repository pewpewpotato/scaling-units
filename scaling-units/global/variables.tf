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
