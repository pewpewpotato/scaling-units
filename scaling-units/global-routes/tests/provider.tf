# Provider configuration for testing
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Use ARM_ environment variables for authentication
  # or configure service principal authentication here
  skip_provider_registration = true
}
