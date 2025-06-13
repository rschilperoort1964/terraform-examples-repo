terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }
}

terraform {
  required_version = "~> 1.5.0" # Compatible with Terraform versions >=1.5.0 and <2.0.0

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0" # Compatible with azurerm versions >=2.99.0 and <3.0.0
    }
  }
}

provider "azurerm" {
  features {}
}



provider "azurerm" {
  features {}
  subscription_id = "ac11db83-f151-4656-8be6-20991bf18e3a"
}

variable "nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "allow-ssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "allow-http"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = "East US"
  resource_group_name = "example-resources"
}

resource "azurerm_network_security_rule" "example" {
  for_each = { for idx, rule in var.nsg_rules : rule.name => rule }

  name                        = each.value.name
  resource_group_name         = resource.azurerm_resource_group.rg.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  network_security_group_name = azurerm_network_security_group.example.name
}


resource "azurerm_resource_group" "rg" {
  name     = "rg-tf-advanced-module-5"
  location = "East US"
}


resource "azurerm_network_security_group" "example" {
  count               = 2
  name                = "nsg-${count.index}"
  location            = "East US"
  resource_group_name = "example-resources"
}

output "nsg_names" {
  value = azurerm_network_security_group.example.name
}

output "nsg_names" {
  value = azurerm_network_security_group.example[*].name
}

output "nsg_names" {
  value = [for nsg in azurerm_network_security_group.example : nsg.name]
}


resource "azurerm_storage_account" "example" {
  name                     = "myuniquestorage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "random_string" "unique_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "example" {
  name                     = "myuniquestorage${random_string.unique_suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}

resource "azurerm_storage_account" "example" {
  name                     = "${var.resource_group_name}storage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

variable "environment" {
  
}


resource "azurerm_storage_account" "my_storage" {
  count                    = 4
  name                     = "mystorageaccount${count.index}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "my_storage_prd_only" {
  count                    = var.environment == "prd" ? 1 : 0
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


module "storage" {
  source = "./modules/storage"
}

module "storage" {
  source = "app.terraform.io/example-corp/storage/azurerm"
  version = "1.1.0"
}

module "storage" {
  source = "github.com/hashicorp/storage"
}

module "storage" {
  source = "git::https://example.com/storage.git"
}

module "storage" {
  source = "git::ssh://username@example.com/storage.git"
}

module "storage" {
  source = "https://example.com/storage-module.zip"
}