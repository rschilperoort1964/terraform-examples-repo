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
  subscription_id = "ffbf501f-f220-4b59-8d0a-5068d961cc5f"
}