# Provider configuration for testing
provider "azurerm" {
  features {}

  # Use ARM_ environment variables for authentication
  # or configure service principal authentication here
  skip_provider_registration = true
}
