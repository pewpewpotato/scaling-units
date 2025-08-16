# Test Coverage Documentation

## Overview
This document outlines the test coverage for the Environment Network Stamp Module.

## Test Files

### 1. input_validation.tftest.hcl
Tests variable validation logic and input constraints.

**Test Cases:**
- `test_variable_validation` - Valid inputs pass validation
- `test_invalid_vnet_cidr` - Invalid VNet CIDR format fails
- `test_invalid_subnet_cidr` - Invalid subnet CIDR format fails  
- `test_empty_location` - Empty location string fails
- `test_invalid_suffix` - Invalid suffix format fails

**Coverage:** Variable validation rules

### 2. happy_path.tftest.hcl
Tests successful resource creation scenarios.

**Test Cases:**
- `test_resource_group_creation` - Resource group creation
- `test_resource_group_naming` - Resource group naming validation

**Coverage:** Basic resource creation

### 3. vnet_validation.tftest.hcl
Tests virtual network creation and configuration.

**Test Cases:**
- `test_vnet_creation` - VNet address space and configuration

**Coverage:** Virtual network provisioning

### 4. nsg_validation.tftest.hcl
Tests network security group creation.

**Test Cases:**
- `test_nsg_creation` - NSG location and tagging

**Coverage:** Network security group provisioning

### 5. association_validation.tftest.hcl
Tests NSG-subnet association.

**Test Cases:**
- `test_subnet_nsg_association` - NSG associated with core subnet

**Coverage:** Resource associations

### 6. output_validation.tftest.hcl
Tests module outputs.

**Test Cases:**
- `test_module_outputs` - All required outputs present

**Coverage:** Module interface outputs

### 7. configurable_inputs.tftest.hcl
Tests input configuration scenarios.

**Test Cases:**
- `test_configurable_vnet_large` - Large VNet configuration
- `test_configurable_vnet_small` - Small VNet configuration
- `test_configurable_different_regions` - Different Azure regions

**Coverage:** Input flexibility and configuration options

### 8. edge_cases.tftest.hcl
Tests boundary conditions and edge cases.

**Test Cases:**
- `test_edge_case_minimal_vnet` - Minimal VNet size
- `test_edge_case_maximum_vnet` - Maximum VNet size
- `test_edge_case_overlapping_subnets_should_fail` - Invalid subnet configuration
- `test_edge_case_very_long_suffix` - Suffix length validation

**Coverage:** Boundary conditions and limits

### 9. sad_path.tftest.hcl
Tests failure scenarios with missing inputs.

**Test Cases:**
- `test_missing_location` - Missing location variable
- `test_missing_vnet_address_space` - Missing VNet address space
- `test_missing_core_subnet_prefix` - Missing subnet prefix
- `test_missing_tags` - Missing tags variable
- `test_missing_suffix` - Missing suffix variable

**Coverage:** Required variable validation

### 10. naming_standards.tftest.hcl
Tests Azure naming convention compliance.

**Test Cases:**
- `test_naming_standards_compliance` - Standard naming validation
- `test_naming_different_suffix` - Different suffix formats
- `test_naming_numeric_suffix` - Numeric suffix validation

**Coverage:** Azure naming conventions

## User Stories Coverage

### US-001: Provision Network Resources
- **Covered by:** happy_path.tftest.hcl, vnet_validation.tftest.hcl, nsg_validation.tftest.hcl
- **Status:** ✅ Complete

### US-002: Configurable Subnet
- **Covered by:** association_validation.tftest.hcl, configurable_inputs.tftest.hcl
- **Status:** ✅ Complete

### US-003: Expose Outputs
- **Covered by:** output_validation.tftest.hcl
- **Status:** ✅ Complete

### US-004: Enforce Naming Standards
- **Covered by:** naming_standards.tftest.hcl
- **Status:** ✅ Complete

### US-005: Input Validation
- **Covered by:** input_validation.tftest.hcl, sad_path.tftest.hcl, edge_cases.tftest.hcl
- **Status:** ✅ Complete

## Test Execution

All tests are designed to use the `plan` command to validate configuration without requiring Azure authentication during development.

To run all tests:
```bash
tofu test
```

To run specific test files:
```bash
tofu test tests/input_validation.tftest.hcl
```

## Notes

- Tests currently require Azure authentication for full execution
- Variable validation tests work without authentication
- All syntax validation passes successfully
- Tests follow OpenTofu native test framework standards
