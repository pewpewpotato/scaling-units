# Environment Network Stamp Module

A reusable OpenTofu module that provisions a standardized network infrastructure stamp including a resource group, virtual network, network security group, and core subnet in Azure.

## Features

- **Resource Group**: Creates a new resource group for network resources
- **Virtual Network**: Provisions a VNet with configurable address space
- **Network Security Group**: Creates an NSG with Azure naming standards
- **Core Subnet**: Provisions a single subnet named "core" with configurable prefix
- **NSG Association**: Automatically associates the NSG with the core subnet
- **Azure Naming Standards**: Uses the `azure/naming` module for consistent resource naming

## Usage

```hcl
module "environment_network" {
  source = "./modules/environment-network"

  location           = "East US"
  vnet_address_space = "10.0.0.0/16"
  core_subnet_prefix = "10.0.1.0/24"
  
  tags = {
    environment = "production"
    team        = "infrastructure"
  }
  
  suffix = "prod01"
}
```

## Inputs

| Name | Description | Type | Required | Validation |
|------|-------------|------|----------|------------|
| `location` | The Azure region where resources will be created | `string` | Yes | Must be non-empty |
| `vnet_address_space` | The address space for the virtual network in CIDR notation | `string` | Yes | Must be valid CIDR |
| `core_subnet_prefix` | The address prefix for the core subnet in CIDR notation | `string` | Yes | Must be valid CIDR |
| `tags` | A map of tags to assign to resources | `map(string)` | Yes | - |
| `suffix` | The suffix to append to resource names for uniqueness | `string` | Yes | Alphanumeric, 1-10 chars |

## Outputs

| Name | Description |
|------|-------------|
| `virtual_network_name` | The name of the created virtual network |
| `virtual_network_id` | The ID of the created virtual network |
| `subnet_name` | The name of the core subnet |

## Examples

### Basic Example

```hcl
module "dev_network" {
  source = "./modules/environment-network"

  location           = "East US"
  vnet_address_space = "10.0.0.0/16"
  core_subnet_prefix = "10.0.1.0/24"
  
  tags = {
    environment = "development"
  }
  
  suffix = "dev01"
}

# Use outputs in other resources
resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = module.dev_network.virtual_network_name
  resource_group_name = "rg-${var.suffix}"
  allocation_method   = "Static"
  
  tags = var.tags
}
```

### Production Example

```hcl
module "prod_network" {
  source = "./modules/environment-network"

  location           = "West US 2"
  vnet_address_space = "172.16.0.0/12"
  core_subnet_prefix = "172.16.1.0/24"
  
  tags = {
    environment = "production"
    team        = "platform"
    cost_center = "12345"
  }
  
  suffix = "prod01"
}
```

### Multi-Environment Example

```hcl
# Development Environment
module "dev_network" {
  source = "./modules/environment-network"

  location           = "East US"
  vnet_address_space = "10.1.0.0/16"
  core_subnet_prefix = "10.1.1.0/24"
  
  tags = {
    environment = "development"
  }
  
  suffix = "dev01"
}

# Staging Environment
module "staging_network" {
  source = "./modules/environment-network"

  location           = "East US"
  vnet_address_space = "10.2.0.0/16"
  core_subnet_prefix = "10.2.1.0/24"
  
  tags = {
    environment = "staging"
  }
  
  suffix = "stage01"
}

# Production Environment
module "prod_network" {
  source = "./modules/environment-network"

  location           = "West US 2"
  vnet_address_space = "10.3.0.0/16"
  core_subnet_prefix = "10.3.1.0/24"
  
  tags = {
    environment = "production"
  }
  
  suffix = "prod01"
}
```

## Network Architecture

The module creates the following network architecture:

```
┌─────────────────────────────────────────────────────────────┐
│ Resource Group (rg-<suffix>)                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Virtual Network (vnet-<suffix>)                         │ │
│ │ Address Space: var.vnet_address_space                   │ │
│ │                                                         │ │
│ │ ┌─────────────────────────────────────────────────────┐ │ │
│ │ │ Subnet: core                                        │ │ │
│ │ │ Address Prefix: var.core_subnet_prefix              │ │ │
│ │ │                                                     │ │ │
│ │ │ ┌─────────────────────────────────────────────────┐ │ │ │
│ │ │ │ Network Security Group (nsg-<suffix>)           │ │ │ │
│ │ │ │ Associated with core subnet                     │ │ │ │
│ │ │ └─────────────────────────────────────────────────┘ │ │ │
│ │ └─────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Requirements

| Name | Version |
|------|---------|
| OpenTofu | >= 1.0 |
| azurerm | ~> 3.0 |
| azure/naming | ~> 0.4 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| naming | azure/naming/azurerm | ~> 0.4 |

## Resources

| Type | Name |
|------|------|
| `azurerm_resource_group` | this |
| `azurerm_virtual_network` | this |
| `azurerm_network_security_group` | this |
| `azurerm_subnet` | core |
| `azurerm_subnet_network_security_group_association` | core |

## Testing

The module includes comprehensive OpenTofu native tests covering:

- **Input Validation**: Variable constraints and CIDR format validation
- **Happy Path**: Successful resource creation scenarios
- **Sad Path**: Missing required inputs and error handling
- **Edge Cases**: Boundary conditions and limits
- **Naming Standards**: Azure naming convention compliance
- **Configuration**: Different input combinations and scenarios

Run tests with:

```bash
tofu test
```

See [tests/COVERAGE.md](tests/COVERAGE.md) for detailed test coverage information.

## Best Practices

1. **CIDR Planning**: Ensure subnet CIDR is a valid subset of the VNet CIDR
2. **Naming**: Use descriptive suffixes that indicate environment and instance
3. **Tagging**: Always include environment and team tags for resource management
4. **Region Selection**: Choose regions close to your users and other resources
5. **Address Spaces**: Plan address spaces to avoid conflicts with other networks

## Common Issues

### Subnet Not in VNet Range

If you get an error about subnet not being in the VNet range:

```
Error: subnet address prefix "10.1.0.0/24" is not within the address space "10.0.0.0/16"
```

Ensure your `core_subnet_prefix` is a valid subset of `vnet_address_space`.

### Invalid CIDR Format

If you get a CIDR validation error:

```
Error: The vnet_address_space must be a valid CIDR block.
```

Ensure your address spaces are in valid CIDR notation (e.g., "10.0.0.0/16").

### Suffix Validation

If you get a suffix validation error:

```
Error: Suffix must be a non-empty alphanumeric string and must be 10 characters or less.
```

Ensure your suffix contains only letters and numbers, and is 10 characters or less.

## Contributing

When contributing to this module:

1. Follow TDD practices - write tests first
2. Ensure all tests pass before submitting
3. Update documentation for any interface changes
4. Follow Azure and OpenTofu best practices
5. Update the COVERAGE.md file with new test scenarios

## License

This module is part of the internal infrastructure codebase. All rights reserved.
