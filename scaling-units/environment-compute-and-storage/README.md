# Environment Compute and Storage Stamp Module

This module provisions an Azure Container Apps Environment and an Azure Cosmos DB Account, including all required networking, security, and private endpoint resources. It is designed for use as a reusable, composable infrastructure building block in larger OpenTofu-based projects.

## Features

- ✅ Azure Container Apps Environment with configurable SKU and subnet assignment
- ✅ Azure Cosmos DB Account with configurable SKU
- ✅ Network Security Groups (NSG) with rules for both ACA Environment and Cosmos DB
- ✅ Private endpoint for Cosmos DB to VNET core subnet
- ✅ Private DNS zone creation and linking for Cosmos DB private endpoint
- ✅ Azure naming standards enforcement via azure/naming module
- ✅ Comprehensive outputs for downstream module composition

## Usage

```hcl
module "environment_compute_and_storage" {
  source = "./modules/environment-compute-and-storage"

  location                  = "East US"
  tags                      = {
    Environment = "Production"
    Project     = "MyProject"
  }
  suffix                    = "prod"
  aca_environment_sku       = "Consumption"
  aca_environment_subnet_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/aca-subnet"
  cosmos_db_sku             = "Standard"
  vnet_core_subnet_id       = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/core-subnet"
  vnet_id                   = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/my-rg/providers/Microsoft.Network/virtualNetworks/my-vnet"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |
| azurerm (naming) | ~> 0.4 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| naming | azure/naming/azurerm | ~> 0.4 |

## Resources

| Name | Type |
|------|------|
| azurerm_resource_group.this | resource |
| azurerm_container_app_environment.this | resource |
| azurerm_cosmosdb_account.this | resource |
| azurerm_private_endpoint.cosmos_db | resource |
| azurerm_private_dns_zone.cosmos_db | resource |
| azurerm_private_dns_zone_virtual_network_link.cosmos_db | resource |
| azurerm_network_security_group.aca_environment | resource |
| azurerm_network_security_group.cosmos_db | resource |
| azurerm_subnet_network_security_group_association.aca_environment | resource |
| azurerm_subnet_network_security_group_association.cosmos_db | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | The Azure region where resources will be created | `string` | n/a | yes |
| tags | A map of tags to assign to all resources | `map(string)` | n/a | yes |
| suffix | Suffix to be used in resource naming | `string` | n/a | yes |
| aca_environment_sku | The SKU for the Azure Container Apps Environment | `string` | n/a | yes |
| aca_environment_subnet_id | The subnet ID where the ACA Environment will be deployed | `string` | n/a | yes |
| cosmos_db_sku | The SKU for the Azure Cosmos DB Account | `string` | n/a | yes |
| vnet_core_subnet_id | The core subnet ID where the Cosmos DB private endpoint will be created | `string` | n/a | yes |
| vnet_id | The virtual network ID for DNS zone linking | `string` | n/a | yes |

### Valid SKU Values

#### ACA Environment SKU
- `Consumption` - Serverless container apps environment
- `Dedicated` - Dedicated container apps environment

#### Cosmos DB SKU  
- `Free` - Free tier with limited throughput
- `Standard` - Standard provisioned throughput

## Outputs

### Resource Group Outputs
| Name | Description |
|------|-------------|
| resource_group_name | The name of the resource group |
| resource_group_id | The ID of the resource group |

### Azure Container Apps Environment Outputs
| Name | Description |
|------|-------------|
| aca_environment_id | The ID of the Azure Container Apps Environment |
| aca_environment_name | The name of the Azure Container Apps Environment |

### Azure Cosmos DB Outputs
| Name | Description |
|------|-------------|
| cosmos_db_account_id | The ID of the Azure Cosmos DB Account |
| cosmos_db_account_name | The name of the Azure Cosmos DB Account |
| cosmos_db_account_endpoint | The endpoint of the Azure Cosmos DB Account |
| cosmos_db_primary_key | The primary key for the Azure Cosmos DB Account (sensitive) |
| cosmos_db_secondary_key | The secondary key for the Azure Cosmos DB Account (sensitive) |
| cosmos_db_connection_strings | Connection strings for the Azure Cosmos DB Account (sensitive) |

### Private Endpoint Outputs
| Name | Description |
|------|-------------|
| cosmos_db_private_endpoint_id | The ID of the Cosmos DB private endpoint |
| cosmos_db_private_endpoint_name | The name of the Cosmos DB private endpoint |

### Private DNS Zone Outputs
| Name | Description |
|------|-------------|
| cosmos_db_private_dns_zone_id | The ID of the Cosmos DB private DNS zone |
| cosmos_db_private_dns_zone_name | The name of the Cosmos DB private DNS zone |

### Network Security Group Outputs
| Name | Description |
|------|-------------|
| aca_nsg_id | The ID of the ACA Environment NSG |
| aca_nsg_name | The name of the ACA Environment NSG |
| cosmos_nsg_id | The ID of the Cosmos DB NSG |
| cosmos_nsg_name | The name of the Cosmos DB NSG |
| aca_nsg_subnet_association_id | The ID of the ACA NSG subnet association |
| cosmos_nsg_subnet_association_id | The ID of the Cosmos DB NSG subnet association |

### Network Security Rules Documentation
| Name | Description |
|------|-------------|
| aca_nsg_inbound_rules | All inbound rules configured in the ACA Environment NSG with detailed properties |
| cosmos_nsg_inbound_rules | All inbound rules configured in the Cosmos DB NSG with detailed properties |

#### ACA Environment NSG Rules
- **AllowContainerAppsHTTP**: Allow HTTP traffic on port 80 (Priority: 100)
- **AllowContainerAppsHTTPS**: Allow HTTPS traffic on port 443 (Priority: 110)

#### Cosmos DB NSG Rules  
- **AllowCosmosDBHTTPS**: Allow HTTPS traffic on port 443 for private endpoint access (Priority: 100)

## Security

This module implements the following security measures:

1. **Network Isolation**: Cosmos DB is accessible only through a private endpoint
2. **Public Access Disabled**: Cosmos DB public network access is disabled
3. **Network Security Groups**: Both ACA Environment and Cosmos DB subnets have NSG rules
4. **Minimal Port Exposure**: Only required ports (80, 443) are opened
5. **Sensitive Data Handling**: Connection strings and keys are marked as sensitive
6. **Private DNS Resolution**: Private DNS zone ensures secure name resolution

## Testing

This module includes comprehensive OpenTofu native tests:

- **Happy Path Tests**: Standard deployment scenarios
- **Input Validation Tests**: Invalid input handling
- **Naming Standards Tests**: Azure naming compliance
- **Dependency Validation Tests**: Missing dependency handling  
- **Private DNS Zone Tests**: DNS configuration validation
- **VNET Validation Tests**: Network configuration validation
- **NSG Rules Tests**: Security group validation
- **NSG Security Validation Tests**: Port restriction validation
- **NSG Input Validation Tests**: NSG input handling
- **Output Validation Tests**: Comprehensive output testing
- **README Documentation Tests**: Documentation validation

Run tests with:
```bash
tofu test
```

## Examples

See the `examples/` directory for usage examples.

## Contributing

1. Ensure all tests pass: `tofu test`
2. Validate configuration: `tofu validate`
3. Follow Azure naming standards
4. Update documentation for any changes

## License

This module is licensed under the MIT License.
