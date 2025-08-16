# Global Ingress Stamp Module

A reusable Terraform module that provisions a resource group and an Azure Front Door CDN Profile, enforcing standard naming conventions and domain validation for consistent, scalable ingress across cloud environments.

## Features

- **Resource Group Creation**: Automatically creates a resource group with consistent naming
- **Azure Front Door CDN Profile**: Provisions Front Door CDN with configurable SKU
- **Naming Conventions**: Uses the `azure/naming` module for consistent resource naming
- **Input Validation**: Validates SKU, custom domain format, and suffix constraints
- **Configurable**: Supports different SKUs, locations, tags, and custom domains

## Usage

```hcl
module "global_ingress" {
  source = "./modules/global-ingress"

  sku           = "Standard_AzureFrontDoor"
  location      = "eastus"
  tags = {
    environment = "production"
    project     = "my-project"
  }
  custom_domain = "example.com"
  suffix        = "prod"
}
```

## Inputs

| Name | Description | Type | Validation | Required |
|------|-------------|------|------------|----------|
| `sku` | The SKU of the Azure Front Door CDN Profile | `string` | Must be `Standard_AzureFrontDoor` or `Premium_AzureFrontDoor` | yes |
| `location` | The Azure region where resources will be created | `string` | Valid Azure region | yes |
| `tags` | A map of tags to assign to the resources | `map(string)` | - | yes |
| `custom_domain` | The custom domain for the CDN profile | `string` | Valid domain format (e.g., example.com) | yes |
| `suffix` | Suffix to append to resource names for uniqueness | `string` | Alphanumeric, max 10 characters | yes |

## Outputs

| Name | Description |
|------|-------------|
| `resource_group_name` | The name of the created resource group |
| `cdn_profile_name` | The name of the created CDN profile |
| `resource_name` | The primary resource name (CDN profile name) |

## Validation

The module includes comprehensive input validation:

### SKU Validation
- **Allowed Values**: `Standard_AzureFrontDoor`, `Premium_AzureFrontDoor`
- **Security**: Rejects empty strings and invalid SKU names

### Location Validation  
- **Required**: Cannot be empty or whitespace-only
- **Format**: Must be a valid Azure region name

### Tags Validation
- **Required**: At least one tag must be provided
- **Key Constraints**: Max 512 characters, cannot start with `ms-` or `azure-` (reserved)
- **Value Constraints**: Max 256 characters, cannot contain `<>%&\?/`
- **Character Set**: Keys must be alphanumeric with `+-.=_:/`

### Custom Domain Validation
- **Format**: Valid ASCII domain name (e.g., example.com, api.example.com)
- **Length**: Maximum 253 characters
- **Security**: No control characters, path traversal sequences, or Unicode
- **Pattern**: Must have valid TLD (minimum 2 characters)

### Suffix Validation
- **Character Set**: Alphanumeric only (a-z, A-Z, 0-9)
- **Length**: 1-10 characters
- **Security**: No control characters, reserved words blocked (microsoft, azure, windows)
- **Required**: Cannot be empty

## Naming Conventions

All resources are named using the `azure/naming` module following Azure best practices:
- Resource Group: Uses `resource_group` naming convention
- CDN Profile: Uses `frontdoor` naming convention

## Examples

### Basic Usage
```hcl
module "basic_ingress" {
  source = "./modules/global-ingress"

  sku           = "Standard_AzureFrontDoor"
  location      = "eastus"
  tags = {
    environment = "dev"
  }
  custom_domain = "dev.example.com"
  suffix        = "dev01"
}
```

### Production Usage
```hcl
module "prod_ingress" {
  source = "./modules/global-ingress"

  sku           = "Premium_AzureFrontDoor"
  location      = "westus2"
  tags = {
    environment = "production"
    project     = "ecommerce"
    team        = "platform"
    cost-center = "12345"
  }
  custom_domain = "www.example.com"
  suffix        = "prod"
}
```

## Requirements

- OpenTofu/Terraform >= 1.0
- `hashicorp/azurerm` provider ~> 3.0
- `azure/naming/azurerm` module ~> 0.4

## Testing

The module includes comprehensive validation tests covering:

### Test Coverage
- **Happy Path**: Valid inputs create resources correctly
- **Sad Path**: Invalid/missing inputs rejected with clear errors  
- **Edge Cases**: Malicious inputs, reserved words, boundary conditions
- **Security**: Script injection, SQL injection, path traversal protection
- **Naming**: Resource naming standards and conventions
- **Configuration**: All inputs properly configurable and applied
- **Outputs**: All module outputs properly exposed

### Test Files
- `happy_path.tftest.hcl` - Basic valid input validation
- `sad_path.tftest.hcl` - Invalid/missing input handling
- `edge_cases.tftest.hcl` - Security and boundary testing
- `naming_standards.tftest.hcl` - Resource naming validation
- `custom_domain_validation.tftest.hcl` - Domain format testing
- `configurable_inputs.tftest.hcl` - Input configuration testing
- `output_validation.tftest.hcl` - Output verification

### Running Tests
```bash
# Run all tests
cd modules/global-ingress
tofu test

# Run specific test file
tofu test tests/happy_path.tftest.hcl

# Run with verbose output
tofu test -verbose
```

**Note**: Full integration tests require Azure authentication. Set up Azure CLI or service principal credentials.

## Resources Created

This module creates the following Azure resources:
1. **Resource Group** (`azurerm_resource_group`)
2. **Azure Front Door CDN Profile** (`azurerm_cdn_frontdoor_profile`)

## License

This module is part of the infrastructure project and follows the same licensing terms.
