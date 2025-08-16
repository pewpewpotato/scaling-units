# Test: Sad path - module rejects invalid or missing inputs

run "missing_sku_should_fail" {
  command = plan

  variables {
    # sku is missing
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.sku,
  ]
}

run "missing_location_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    # location is missing
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.location,
  ]
}

run "missing_tags_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    # tags is missing
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.tags,
  ]
}

run "missing_custom_domain_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    # custom_domain is missing
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "missing_suffix_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    # suffix is missing
  }

  expect_failures = [
    var.suffix,
  ]
}

run "empty_sku_should_fail" {
  command = plan

  variables {
    sku           = ""
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.sku,
  ]
}

run "empty_location_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = ""
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.location,
  ]
}

run "empty_custom_domain_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = ""
    suffix        = "test01"
  }

  expect_failures = [
    var.custom_domain,
  ]
}

run "empty_suffix_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags = {
      Environment = "test"
    }
    custom_domain = "example.com"
    suffix        = ""
  }

  expect_failures = [
    var.suffix,
  ]
}

run "empty_tags_should_fail" {
  command = plan

  variables {
    sku           = "Standard_AzureFrontDoor"
    location      = "East US"
    tags          = {}
    custom_domain = "example.com"
    suffix        = "test01"
  }

  expect_failures = [
    var.tags,
  ]
}
