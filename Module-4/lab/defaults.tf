terraform {
  required_version = ">= 1.9.0"

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
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-advanced"
    storage_account_name = "saterraformadvancedstate"
    container_name       = "tfstate"
    key                  = "terraform-lab-5.tfstate"
  }
}

provider "azurerm" {
  features {}
}
