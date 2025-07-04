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
  subscription_id = "b9f6a816-30ad-441a-81df-b014cf95fdd4"
}
