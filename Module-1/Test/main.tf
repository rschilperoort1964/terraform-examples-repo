terraform {
  required_version = ">= 1.12.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.110.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "b9f6a816-30ad-441a-81df-b014cf95fdd4"
}

resource "azurerm_resource_group" "re" {
  name     = "rg-rschilpstoragelab6"
  location = "westeurope" // Change to your actual location if needed
}