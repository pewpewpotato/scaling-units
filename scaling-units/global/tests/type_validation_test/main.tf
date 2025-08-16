# Test data type validation with OpenTofu's type system
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

# Test with list instead of map for tags
module "test_invalid_tags_type" {
  source = "../../"

  name     = var.test_name
  location = var.test_location
  tags     = ["invalid", "list"]  # Should fail - list instead of map(string)
  suffix   = var.test_suffix
}
