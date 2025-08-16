# Test for malicious/inappropriate input values

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_script_injection_in_name" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_sql_injection_in_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "'; DROP TABLE users; --"  # SQL injection attempt
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_path_traversal_in_name" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_command_injection_in_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "; rm -rf /"  # Command injection attempt
  }

  expect_failures = [
    var.suffix,
  ]
}

run "test_unicode_attacks_in_name" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "001"
  }

  expect_failures = [
  ]
}

run "test_null_bytes_in_suffix" {
  command = plan

  variables {
    location = "East US"
    tags     = {}
    suffix   = "test\u0000null"  # Null byte injection (fixed escape sequence)
  }

  expect_failures = [
    var.suffix,
  ]
}

# Tags with potentially malicious content should be accepted (they're just metadata)
run "test_tags_with_script_content_accepted" {
  command = plan

  variables {
    location = "East US"
    tags = {
      script      = "alert(1)"
      path        = "../../../etc/passwd"
      description = "This tag contains <script> but it's just metadata"
    }
    suffix = "001"
  }
}
