variables {
  storage_account_name = "satest101"
  environment          = "dev"
}

run "correct" {

  command = plan

  variables {
    port = 443
  }
}

run "incorrect" {

  command = plan
  
  variables {
    port = 8080
  }

  expect_failures = [
    var.port,
  ]
}
