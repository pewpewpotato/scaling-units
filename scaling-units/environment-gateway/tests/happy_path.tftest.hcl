provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_happy_path_all_valid_inputs" {
  command = plan

  variables {
    vnet_name                = "production-vnet"
    vnet_resource_group_name = "network-rg"
    nsg_name                 = "apim-nsg"
    nsg_resource_group_name  = "security-rg"
    apim_subnet_prefix       = "10.0.1.0/24"
    location                 = "East US"
    tags = {
      environment = "production"
      project     = "api-gateway"
      team        = "platform"
    }
    suffix = "prod"
  }

  # QA-001: Verify APIM is connected to the specified virtual network and subnet
  assert {
    condition     = azurerm_api_management.this.virtual_network_configuration[0].subnet_id == azurerm_subnet.apim.id
    error_message = "APIM should be connected to the created subnet"
  }

  # QA-002: Validate that required NSG rules are applied
  assert {
    condition     = length([for rule in azurerm_network_security_rule.apim_inbound : rule]) > 0
    error_message = "Required inbound NSG rules should be created"
  }

  assert {
    condition     = length([for rule in azurerm_network_security_rule.apim_outbound : rule]) > 0
    error_message = "Required outbound NSG rules should be created"
  }

  # QA-005: Confirm outputs include APIM and network resource details
  assert {
    condition     = output.apim_id != null && output.apim_name != null
    error_message = "APIM resource details should be in outputs"
  }

  assert {
    condition     = output.subnet_id != null && output.subnet_name != null
    error_message = "Network resource details should be in outputs"
  }

  # QA-011: Subnet is created and APIM is connected
  assert {
    condition     = azurerm_subnet.apim.name != null
    error_message = "Subnet should be created for APIM"
  }

  assert {
    condition     = contains(azurerm_subnet.apim.address_prefixes, "10.0.1.0/24")
    error_message = "Subnet should have the specified address prefix"
  }

  # QA-021: All required inputs provided, module provisions successfully
  assert {
    condition     = azurerm_api_management.this.name != null
    error_message = "APIM should be provisioned with valid inputs"
  }
}

run "test_minimal_valid_inputs" {
  command = plan

  # QA-009, QA-017: Test with minimal valid input values
  variables {
    vnet_name                = "v"
    vnet_resource_group_name = "r"
    nsg_name                 = "n"
    nsg_resource_group_name  = "s"
    apim_subnet_prefix       = "10.0.0.0/29"
    location                 = "East US"
    tags                     = {}
    suffix                   = "1"
  }

  assert {
    condition     = azurerm_api_management.this.name != null
    error_message = "Module should work with minimal valid inputs"
  }

  assert {
    condition     = azurerm_subnet.apim.name != null
    error_message = "Subnet should be created with minimal inputs"
  }
}

run "test_maximum_valid_inputs" {
  command = plan

  # QA-008, QA-016: Test with maximum length/size for input values
  variables {
    vnet_name                = "very-long-virtual-network-name-that-is-close-to-the-maximum-limit"
    vnet_resource_group_name = "very-long-resource-group-name-for-virtual-network-that-approaches-ninety-characters-max"
    nsg_name                 = "very-long-network-security-group-name-that-is-close-to-the-eighty-character-limit"
    nsg_resource_group_name  = "very-long-resource-group-name-for-network-security-group-approaching-limit-chars"
    apim_subnet_prefix       = "10.0.0.0/16"
    location                 = "West Europe"
    tags = {
      environment                        = "production"
      project                           = "api-gateway-infrastructure"
      team                              = "platform-engineering"
      cost-center                       = "engineering-department"
      compliance-requirement            = "required"
      backup-policy                     = "daily-backup-with-retention"
      monitoring-enabled                = "comprehensive-monitoring"
      security-classification           = "high-security-requirement"
      data-classification               = "sensitive-data-handling"
      business-unit                     = "core-business-platform"
    }
    suffix = "1234567890"
  }

  assert {
    condition     = azurerm_api_management.this.name != null
    error_message = "Module should work with maximum valid inputs"
  }

  assert {
    condition     = azurerm_subnet.apim.name != null
    error_message = "Subnet should be created with maximum inputs"
  }
}
