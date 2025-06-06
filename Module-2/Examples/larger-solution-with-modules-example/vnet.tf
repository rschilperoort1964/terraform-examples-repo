resource "azurerm_virtual_network" "vnet" {
  name                = module.naming.virtual_network.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/22"]
}

resource "azurerm_subnet" "webapp_subnet" {
  name                 = "${module.naming.subnet.name_unique}-webapp"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "endpointsubnet" {
  name                 = "${module.naming.subnet.name_unique}-pe"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = module.naming.network_security_group.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.endpointsubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_route_table" "udr" {
  name                = module.naming.route_table.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name                   = "example"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_subnet_route_table_association" "udr_association" {
  subnet_id      = azurerm_subnet.endpointsubnet.id
  route_table_id = azurerm_route_table.udr.id
}

resource "azurerm_storage_account" "flow_log_storage_account" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "null_resource" "flow_log" {
  provisioner "local-exec" {
    command = "az network watcher flow-log create --location westeurope --name myVNetFlowLog --resource-group ${azurerm_resource_group.rg.name} --vnet ${azurerm_virtual_network.vnet.name} --storage-account ${azurerm_storage_account.flow_log_storage_account.name} --workspace ${azurerm_log_analytics_workspace.law.name} --interval 10 --traffic-analytics true"
  }
}
