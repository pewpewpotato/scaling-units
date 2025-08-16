# Environment Gateway Stamp Module

A reusable infrastructure module for provisioning Azure API Management (APIM) instances securely integrated with virtual networks, including automated subnet and NSG rule management.

## Overview

This module provisions:
- An Azure API Management instance with virtual network integration
- A dedicated subnet for APIM within an existing virtual network
- NSG rules to allow only necessary traffic to and from APIM
- Consistent naming using the azure/naming module
- Proper tagging and security configurations

## Features

- **Secure Network Integration**: APIM is deployed within a virtual network with dedicated subnet
- **Automated NSG Management**: Creates and applies only required security rules for APIM traffic
- **Consistent Naming**: Uses azure/naming module to enforce organizational naming standards
- **Input Validation**: Comprehensive validation for all inputs with clear error messages
- **Flexible Configuration**: Supports existing or new virtual networks and NSGs
- **Composability**: Outputs designed for use in downstream modules

## Usage

```hcl
module "environment_gateway" {
  source = "./modules/environment-gateway"
  
  vnet_name = "my-existing-vnet"
  nsg_name  = "my-existing-nsg"
  location  = "East US"
  tags = {
    environment = "production"
    project     = "api-gateway"
    team        = "platform"
  }
  suffix = "prod"
}

# Use outputs in other resources
resource "azurerm_api_management_api" "example" {
  name                = "example-api"
  resource_group_name = module.environment_gateway.resource_group_name
  api_management_name = module.environment_gateway.apim_name
  revision            = "1"
  display_name        = "Example API"
  protocols           = ["https"]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| naming | azure/naming/azurerm | ~> 0.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vnet_name | The name of the existing virtual network where APIM will be integrated. | `string` | n/a | yes |
| nsg_name | The name of the existing network security group to associate with the APIM subnet. | `string` | n/a | yes |
| location | The Azure region where resources will be created. | `string` | n/a | yes |
| tags | A map of tags to assign to all resources. | `map(string)` | n/a | yes |
| suffix | The suffix to append to resource names for uniqueness. Must be alphanumeric, 1-10 characters. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| apim_id | The ID of the created API Management instance |
| apim_name | The name of the created API Management instance |
| apim_gateway_url | The gateway URL of the API Management instance |
| apim_management_api_url | The management API URL of the API Management instance |
| subnet_id | The ID of the created or configured subnet for APIM |
| subnet_name | The name of the created or configured subnet for APIM |
| resource_group_id | The ID of the created resource group |
| resource_group_name | The name of the created resource group |
| resource_group_location | The location of the created resource group |

## Input Validation

This module includes comprehensive input validation:

### Virtual Network Name Validation
- Must be a non-empty string
- References an existing virtual network in Azure

### NSG Name Validation
- Must be a non-empty string
- References an existing network security group in Azure

### Location Validation
- Must be a non-empty string
- Represents the Azure region where resources will be created

### Suffix Validation  
- Must be 1-10 characters
- Only alphanumeric characters allowed
- Cannot be empty
- Follows azure/naming module requirements

## Examples

### Basic Configuration
```hcl
module "environment_gateway" {
  source = "./modules/environment-gateway"
  
  vnet_name = "production-vnet"
  nsg_name  = "apim-nsg"
  location  = "East US"
  tags = {
    environment = "production"
    team        = "platform"
  }
  suffix = "prod"
}
```

### Development Configuration
```hcl
module "environment_gateway" {
  source = "./modules/environment-gateway"
  
  vnet_name = "dev-vnet"
  nsg_name  = "dev-apim-nsg"
  location  = "West US 2"
  tags = {
    environment     = "development"
    project         = "api-gateway"
    team            = "platform"
    cost-center     = "dev-ops"
    auto-shutdown   = "enabled"
  }
  suffix = "dev001"
}
```

## Security Considerations

- APIM is deployed within a virtual network for enhanced security
- NSG rules are automatically configured to allow only necessary traffic
- All resources are tagged for compliance and cost tracking
- Publisher information should be updated for production deployments

## Module Composition

This module is designed to be composed with other modules:

```hcl
# Network foundation (using environment-network module)
module "network" {
  source = "./modules/environment-network"
  
  location            = "East US"
  vnet_address_space  = "10.0.0.0/16"
  core_subnet_prefix  = "10.0.0.0/24"
  tags                = local.common_tags
  suffix              = "prod"
}

# Gateway module uses the network foundation
module "gateway" {
  source = "./modules/environment-gateway"
  
  vnet_name = module.network.vnet_name
  nsg_name  = module.network.nsg_name
  location  = "East US"
  tags      = local.common_tags
  suffix    = "prod"
}
```

## Testing

The module includes comprehensive tests:
- Input validation tests
- Happy path tests
- Sad path tests
- Edge case tests
- Naming standards tests
- Output validation tests

Run tests with:
```bash
tofu test
```

## Generated Resource Names

The module uses the azure/naming (azurecaf) provider to generate consistent names:

| Resource Type | Example Input | Example Output |
|---------------|---------------|----------------|
| Resource Group | suffix="prod" | `rg-[random]-prod` |
| API Management | suffix="prod" | `apim-[random]-prod` |
| Subnet | suffix="prod" | `snet-[random]-prod` |

## Contributing

1. Ensure all tests pass
2. Follow the established naming conventions
3. Update documentation for any new inputs/outputs
4. Add appropriate validation for new inputs
5. Test with various network configurations

## License

This module is provided as-is for organizational use.
