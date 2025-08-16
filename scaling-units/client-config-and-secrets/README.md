# Client Onboarding and Secrets Stamp

This module provisions Azure Key Vault and Azure App Configuration with private endpoints and DNS integration for secure client onboarding. It is designed for Infrastructure Engineers to securely store secrets and configuration, and is intended to be consumed as a dependency in other OpenTofu projects.

## Features

- **Azure Key Vault** with private endpoint and DNS integration
- **Azure App Configuration** with private endpoint and DNS integration
- **Private DNS zones** for both services with virtual network links
- **Configurable SKUs** for both Key Vault and App Configuration
- **Azure naming conventions** via the azure/naming module
- **Network isolation** with disabled public access
- **Enhanced input validation** with proper Azure resource ID format checking
- **Idempotent operations** with lifecycle management and consistent tagging
- **Automatic common tags** for better resource management

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Key Vault     │    │ App Configuration│
│   (Private)     │    │    (Private)     │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          │ Private Endpoint     │ Private Endpoint
          │                      │
          └──────────┬───────────┘
                     │
              ┌──────▼──────┐
              │   Subnet    │
              │  (User      │
              │  Provided)  │
              └─────────────┘
```

## Important Notes

### Automatic Tagging
This module automatically adds the following tags to all resources:
- `ManagedBy`: "OpenTofu"
- `Module`: "client-config-and-secrets"

These tags are merged with any tags you provide via the `tags` variable.

### Input Validation
The module includes enhanced validation for:
- **Resource IDs**: Must match proper Azure resource ID format
- **Suffix**: Must be alphanumeric, 1-10 characters, and cannot contain reserved words
- **Tags**: Limited to 50 tags per Azure constraints
- **SKUs**: Validated against supported values

### Idempotency
The module is designed for idempotent operations with:
- Lifecycle rules that ignore external tag changes
- Consistent resource naming via the azure/naming module
- Proper defaults for all optional variables

## Usage

### Basic Usage

```hcl
module "client_secrets" {
  source = "./modules/client-config-and-secrets"

  location           = "East US"
  vnet_name          = "my-vnet"
  vnet_resource_id   = azurerm_virtual_network.example.id
  subnet_name        = "private-subnet"
  subnet_resource_id = azurerm_subnet.private.id
  suffix             = "client01"
  
  # Tags are optional and will be merged with automatic tags
  tags = {
    Environment = "production"
    Project     = "client-onboarding"
  }
}
```

### Minimal Usage (with defaults)

```hcl
module "client_secrets" {
  source = "./modules/client-config-and-secrets"

  location           = "East US"
  vnet_name          = "my-vnet"
  vnet_resource_id   = azurerm_virtual_network.example.id
  subnet_name        = "private-subnet"
  subnet_resource_id = azurerm_subnet.private.id
  suffix             = "dev01"
  
  # No tags provided - only automatic tags will be applied
  # Key Vault will use "standard" SKU
  # App Configuration will use "free" SKU
}
```

### Advanced Usage

```hcl
module "client_secrets" {
  source = "./modules/client-config-and-secrets"

  location           = "West Europe"
  vnet_name          = "production-vnet"
  vnet_resource_id   = data.azurerm_virtual_network.existing.id
  subnet_name        = "endpoints-subnet"
  subnet_resource_id = data.azurerm_subnet.endpoints.id
  suffix             = "prod01"
  
  # Premium Key Vault for hardware security modules
  key_vault_sku         = "premium"
  
  # Standard App Configuration for feature flags
  app_configuration_sku = "standard"
  
  tags = {
    Environment   = "production"
    CostCenter    = "infrastructure"
    Owner         = "platform-team"
    SecurityLevel = "high"
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

## Resources

| Name | Type |
|------|------|
| [azurerm_app_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_configuration) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_private_dns_zone.app_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.app_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.app_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | The Azure region where resources will be created | `string` | n/a | yes |
| subnet_name | The name of the subnet | `string` | n/a | yes |
| subnet_resource_id | The resource ID of the subnet (must match Azure format) | `string` | n/a | yes |
| suffix | The suffix to append to resource names for uniqueness (1-10 alphanumeric characters, no reserved words) | `string` | n/a | yes |
| vnet_name | The name of the virtual network | `string` | n/a | yes |
| vnet_resource_id | The resource ID of the virtual network (must match Azure format) | `string` | n/a | yes |
| app_configuration_sku | The SKU name of the App Configuration. Possible values are free and standard | `string` | `"free"` | no |
| key_vault_sku | The SKU name of the Key Vault. Possible values are standard and premium | `string` | `"standard"` | no |
| tags | A map of tags to assign to resources (max 50 tags, merged with automatic tags) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| app_configuration_endpoint | The endpoint of the created App Configuration |
| app_configuration_id | The ID of the created App Configuration |
| app_configuration_name | The name of the created App Configuration |
| app_configuration_primary_read_key | The primary read key of the App Configuration |
| app_configuration_primary_write_key | The primary write key of the App Configuration |
| app_configuration_private_dns_zone_id | The ID of the App Configuration private DNS zone |
| app_configuration_private_dns_zone_name | The name of the App Configuration private DNS zone |
| app_configuration_private_endpoint_id | The ID of the App Configuration private endpoint |
| key_vault_id | The ID of the created Key Vault |
| key_vault_name | The name of the created Key Vault |
| key_vault_private_dns_zone_id | The ID of the Key Vault private DNS zone |
| key_vault_private_dns_zone_name | The name of the Key Vault private DNS zone |
| key_vault_private_endpoint_id | The ID of the Key Vault private endpoint |
| key_vault_uri | The URI of the created Key Vault |
| resource_group_id | The ID of the created resource group |
| resource_group_name | The name of the created resource group |

## Validation and Error Handling

### Input Validation
The module validates:

- **Resource IDs**: Must follow Azure format `/subscriptions/{guid}/resourceGroups/{name}/providers/Microsoft.Network/virtualNetworks/{name}[/subnets/{name}]`
- **Suffix**: Must be 1-10 alphanumeric characters and cannot contain reserved words ('azure', 'microsoft', 'windows')
- **SKUs**: Must be from allowed values only
- **Tags**: Maximum of 50 tags per Azure limits

### Common Validation Errors

```bash
# Invalid resource ID format
Error: Subnet resource ID must be a valid Azure subnet resource ID format.

# Invalid suffix
Error: Suffix must be a non-empty alphanumeric string, 10 characters or less, 
and cannot contain reserved words like 'azure', 'microsoft', or 'windows'.

# Too many tags
Error: Azure supports a maximum of 50 tags per resource.
```

## Security Considerations

- **Network Isolation**: Both Key Vault and App Configuration have public network access disabled
- **Private Endpoints**: All access goes through private endpoints in your specified subnet
- **DNS Integration**: Private DNS zones ensure proper name resolution within your virtual network
- **Access Keys**: App Configuration access keys are marked as sensitive outputs
- **Network ACLs**: Key Vault is configured to deny all public access with Azure services bypass
- **Automatic Tagging**: Resources are automatically tagged for better governance and cost tracking

## Limitations

- **Subnet Requirements**: The specified subnet must have enough IP addresses for the private endpoints (minimum 2)
- **DNS Conflicts**: Ensure no conflicting private DNS zones exist in your subscription
- **Service Limits**: Azure service limits apply (e.g., Key Vault name uniqueness globally)
- **Permissions**: The deploying identity must have sufficient permissions to create all resources
- **Resource ID Format**: VNET and subnet resource IDs must be properly formatted Azure resource IDs

## Examples

### Integration with Existing Infrastructure

```hcl
# Data sources for existing infrastructure
data "azurerm_virtual_network" "existing" {
  name                = "production-vnet"
  resource_group_name = "network-rg"
}

data "azurerm_subnet" "endpoints" {
  name                 = "private-endpoints"
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_virtual_network.existing.resource_group_name
}

# Client secrets module
module "client_secrets" {
  source = "./modules/client-config-and-secrets"

  location           = data.azurerm_virtual_network.existing.location
  vnet_name          = data.azurerm_virtual_network.existing.name
  vnet_resource_id   = data.azurerm_virtual_network.existing.id
  subnet_name        = data.azurerm_subnet.endpoints.name
  subnet_resource_id = data.azurerm_subnet.endpoints.id
  suffix             = "client01"
  
  tags = data.azurerm_virtual_network.existing.tags
}

# Use the outputs
output "client_key_vault_uri" {
  value = module.client_secrets.key_vault_uri
}

output "client_app_config_endpoint" {
  value = module.client_secrets.app_configuration_endpoint
}
```

## Testing

The module includes comprehensive tests covering:
- Happy path scenarios
- Input validation
- Naming standards compliance
- Output validation
- Edge cases and error handling

Run tests with:
```bash
tofu test
```

## Contributing

1. Follow the established patterns in this repository
2. Add tests for any new functionality
3. Update documentation for any changes
4. Ensure all tests pass before submitting changes

## License

This module is part of the internal infrastructure repository and follows the organization's licensing terms.
