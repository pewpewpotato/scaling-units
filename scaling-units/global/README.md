# Global Stamp Module

A reusable infrastructure module for provisioning a resource group and Azure DNS Zone with consistent naming conventions.

## Overview

This module provisions:
- An Azure Resource Group
- An Azure DNS Zone
- Consistent naming using the azure/naming module
- Proper tagging and organization

## Features

- **Consistent Naming**: Uses azure/naming module to enforce organizational naming standards
- **Input Validation**: Comprehensive validation for all inputs with clear error messages
- **Security**: Protection against injection attacks through strict alphanumeric validation
- **Flexibility**: Supports custom tags and configurable suffixes
- **Composability**: Outputs designed for use in downstream modules

## Usage

```hcl
module "global_stamp" {
  source = "./modules/global"
  
  location = "East US"
  tags = {
    environment = "production"
    project     = "global-infrastructure"
    team        = "platform"
  }
  suffix = "prod"
}

# Use outputs in other resources
resource "azurerm_storage_account" "example" {
  name                = replace(module.global_stamp.name, "-", "")
  resource_group_name = module.global_stamp.resource_group_name
  location            = "East US"
  
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = {
    created_for = module.global_stamp.name
  }
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
| location | The Azure region where resources will be created. | `string` | n/a | yes |
| tags | A map of tags to assign to all resources. | `map(string)` | n/a | yes |
| suffix | The suffix to append to resource names for uniqueness. Must be alphanumeric, 1-10 characters. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| name | The generated name using the naming convention |
| resource_group_name | The name of the created resource group |
| resource_group_id | The ID of the created resource group |
| dns_zone_name | The name of the created DNS zone |
| dns_zone_id | The ID of the created DNS zone |

## Input Validation

This module includes comprehensive input validation:

### Location Validation
- Must be a non-empty string
- Represents the Azure region where resources will be created

### Suffix Validation  
- Must be 1-10 characters
- Only alphanumeric characters allowed
- Cannot be empty
- Follows azure/naming module requirements

### Security Features
- Protection against script injection attacks
- Protection against SQL injection attempts  
- Protection against path traversal attacks
- Strict alphanumeric validation for critical inputs

## Examples

### Minimal Configuration
```hcl
module "global_stamp" {
  source = "./modules/global"
  
  name     = "app"
  location = "West US"
  tags     = {}
  suffix   = "1"
}
```

### Production Configuration
```hcl
module "global_stamp" {
  source = "./modules/global"
  
  name     = "productionapp"
  location = "East US"
  tags = {
    environment      = "production"
    project          = "global-stamp-module"
    team             = "infrastructure"
    cost-center      = "12345"
    owner            = "platform-team"
    compliance       = "required"
    backup-policy    = "daily"
    monitoring       = "enabled"
    security-level   = "high"
  }
  suffix = "prod001"
}
```

### Edge Cases
```hcl
# Maximum length inputs
module "global_stamp_max" {
  source = "./modules/global"
  
  name     = "verylongapplicationnamethatisnearthemaximumlimit"  # 50 characters
  location = "West US 2"
  tags = {
    very-long-tag-name = "very-long-tag-value-that-demonstrates-flexibility"
  }
  suffix = "1234567890"  # 10 characters
}
```

## Error Examples

```hcl
# This will fail - name too long
module "invalid_name" {
  source = "./modules/global"
  
  name     = "thisnameiswaytoolongandwillfailvalidationbecauseitexceedsfiftycharacters"
  location = "East US"
  tags     = {}
  suffix   = "001"
}
# Error: Name must be a non-empty string containing only alphanumeric characters, hyphens, and underscores, and must be 50 characters or less.

# This will fail - invalid suffix characters
module "invalid_suffix" {
  source = "./modules/global"
  
  name     = "myapp"
  location = "East US"
  tags     = {}
  suffix   = "invalid-suffix!"
}
# Error: Suffix must be a non-empty alphanumeric string and must be 10 characters or less.
```

## Generated Resource Names

The module uses the azure/naming (azurecaf) provider to generate consistent names:

| Resource Type | Example Input | Example Output |
|---------------|---------------|----------------|
| Resource Group | name="myapp", suffix="prod" | `rg-myapp-prod` |
| DNS Zone | name="myapp", suffix="prod" | `dns-myapp-prod` |

## Module Composition

This module is designed to be composed with other modules:

```hcl
# Global stamp provides foundation
module "global_stamp" {
  source = "./modules/global"
  
  name     = "myapp"
  location = "East US"
  tags     = local.common_tags
  suffix   = "prod"
}

# Application modules use the foundation
module "web_app" {
  source = "./modules/webapp"
  
  resource_group_name = module.global_stamp.resource_group_name
  location           = "East US"
  name_prefix        = module.global_stamp.name
  tags               = local.common_tags
}
```

## Testing

The module includes comprehensive tests:
- Input validation tests
- Edge case tests  
- Security tests (injection protection)
- Integration tests
- Downstream usage tests

Run tests with:
```bash
tofu test
```

## Contributing

1. Ensure all tests pass
2. Follow the established naming conventions
3. Update documentation for any new inputs/outputs
4. Add appropriate validation for new inputs

## License

This module is provided as-is for organizational use.
