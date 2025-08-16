# Simple validation test file for testing input validation without provider authentication
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Use the module with test variables (direct values)
module "test_module" {
  source        = "../../"
  sku           = "Standard_AzureFrontDoor"
  location      = "eastus"
  tags = {
    environment = "test"
  }
  custom_domain = "example.com"
  suffix        = "test"
}
