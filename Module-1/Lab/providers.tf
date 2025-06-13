terraform {
  required_version = ">= 1.12.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.32.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "dcdf4a3d-d0c0-4a63-94cf-781981249be5"
}
