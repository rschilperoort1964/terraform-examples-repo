terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.110.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ffbf501f-f220-4b59-8d0a-5068d961cc5f"
}