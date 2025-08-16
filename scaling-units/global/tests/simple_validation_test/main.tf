# Minimal validation test without Azure authentication
variable "test_name" {
  type    = string
  default = "testapp"
}

variable "test_location" {
  type    = string
  default = "East US"
}

variable "test_tags" {
  type    = map(string)
  default = {}
}

variable "test_suffix" {
  type    = string
  default = "001"
}

# Use module to test validation
module "test_validation" {
  source = "../../"

  name     = var.test_name
  location = var.test_location
  tags     = var.test_tags
  suffix   = var.test_suffix
}

output "test_result" {
  value = "Validation passed"
}
