# terraform dynamic blocks guide

## what are dynamic blocks?

Dynamic blocks in terraform allow you to dynamically generate repeated nested blocks within a resource configuration. Instead of writing multiple similar blocks manually, you can use a dynamic block to generate them programmatically based on input data like variables, locals, or data sources.

## why use dynamic blocks?

### 1. reduce code duplication
Eliminate repetitive configuration blocks when you need to create multiple similar nested blocks with slight variations.

### 2. make configurations data-driven
Generate configuration blocks based on input variables, making your terraform modules more flexible and reusable.

### 3. handle variable-length configurations
When you don't know in advance how many nested blocks you'll need, dynamic blocks can generate them based on runtime data.

### 4. improve maintainability
Instead of manually maintaining dozens of similar blocks, maintain one dynamic block template that generates them all.

## basic syntax

```hcl
resource "resource_type" "example" {
  # Static configuration
  name = "example"
  
  # Dynamic block
  dynamic "nested_block_name" {
    for_each = var.input_list
    content {
      # Block configuration using iterator
      attribute = nested_block_name.value.some_property
    }
  }
}
```

## practical examples

### example 1: dynamic security group rules

Instead of writing multiple ingress rules manually:

```hcl
# Without dynamic blocks (repetitive)
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
}
```

With dynamic blocks:

```hcl
# Define security rules as variable
variable "security_rules" {
  description = "List of security rules"
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
      name                       = "HTTP"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTPS"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "SSH"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.0.0.0/8"
      destination_address_prefix = "*"
    }
  ]
}

# Using dynamic block
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
```

### example 2: dynamic subnets in virtual network

```hcl
variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
  default = {
    "web" = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "app" = {
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Sql"]
    }
    "data" = {
      address_prefixes = ["10.0.3.0/24"]
      delegation = {
        name = "delegation"
        service_delegation = {
          name    = "Microsoft.Sql/managedInstances"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "subnet" {
    for_each = var.subnets
    content {
      name             = subnet.key
      address_prefix   = subnet.value.address_prefixes[0]
      security_group   = azurerm_network_security_group.subnet_nsg[subnet.key].id
    }
  }
}

# Create NSGs for each subnet dynamically
resource "azurerm_network_security_group" "subnet_nsg" {
  for_each = var.subnets
  
  name                = "${each.key}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

### example 3: dynamic app service configuration

```hcl
variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default = {
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = ""
    "DATABASE_CONNECTION_STRING" = ""
  }
}

variable "connection_strings" {
  description = "Connection strings for the web app"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = [
    {
      name  = "DefaultConnection"
      type  = "SQLAzure"
      value = "Server=tcp:server.database.windows.net,1433;Database=mydb;"
    }
  ]
}

variable "ip_restrictions" {
  description = "IP restrictions for the web app"
  type = list(object({
    ip_address                = optional(string)
    subnet_id                 = optional(string)
    virtual_network_subnet_id = optional(string)
    name                      = string
    priority                  = number
    action                    = string
  }))
  default = [
    {
      ip_address = "203.0.113.0/24"
      name       = "AllowOfficeIP"
      priority   = 100
      action     = "Allow"
    }
  ]
}

resource "azurerm_linux_web_app" "main" {
  name                = "example-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  app_settings = var.app_settings

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        subnet_id                 = ip_restriction.value.subnet_id
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
      }
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }
}
```

### example 4: dynamic key vault access policies

```hcl
variable "access_policies" {
  description = "List of access policies for the key vault"
  type = list(object({
    tenant_id               = string
    object_id               = string
    application_id          = optional(string)
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = [
    {
      tenant_id = "12345678-1234-1234-1234-123456789012"
      object_id = "87654321-4321-4321-4321-210987654321"
      key_permissions = [
        "Get",
        "List",
        "Create",
        "Delete"
      ]
      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete"
      ]
    }
  ]
}

resource "azurerm_key_vault" "main" {
  name                = "example-keyvault"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  dynamic "access_policy" {
    for_each = var.access_policies
    content {
      tenant_id               = access_policy.value.tenant_id
      object_id               = access_policy.value.object_id
      application_id          = access_policy.value.application_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }
}
```

### example 5: dynamic load balancer rules

```hcl
variable "load_balancer_rules" {
  description = "Load balancer rules configuration"
  type = list(object({
    name                           = string
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    idle_timeout_in_minutes        = optional(number, 4)
    enable_floating_ip             = optional(bool, false)
    enable_tcp_reset               = optional(bool, false)
    disable_outbound_snat         = optional(bool, false)
  }))
  default = [
    {
      name          = "HTTP"
      protocol      = "Tcp"
      frontend_port = 80
      backend_port  = 80
    },
    {
      name          = "HTTPS"
      protocol      = "Tcp"
      frontend_port = 443
      backend_port  = 443
    }
  ]
}

variable "health_probes" {
  description = "Health probe configurations"
  type = list(object({
    name                = string
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number, 15)
    number_of_probes    = optional(number, 2)
  }))
  default = [
    {
      name         = "http-probe"
      protocol     = "Http"
      port         = 80
      request_path = "/"
    }
  ]
}

resource "azurerm_lb" "main" {
  name                = "example-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "backend-pool"
}

# Dynamic health probes
resource "azurerm_lb_probe" "main" {
  for_each = { for probe in var.health_probes : probe.name => probe }
  
  loadbalancer_id     = azurerm_lb.main.id
  name                = each.value.name
  protocol            = each.value.protocol
  port                = each.value.port
  request_path        = each.value.request_path
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
}

# Dynamic load balancer rules
resource "azurerm_lb_rule" "main" {
  for_each = { for rule in var.load_balancer_rules : rule.name => rule }
  
  loadbalancer_id                = azurerm_lb.main.id
  name                           = each.value.name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "primary"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main[each.value.name].id
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  enable_floating_ip             = each.value.enable_floating_ip
  enable_tcp_reset              = each.value.enable_tcp_reset
  disable_outbound_snat         = each.value.disable_outbound_snat
}
```

## advanced patterns

### conditional dynamic blocks

```hcl
variable "enable_monitoring" {
  description = "Enable monitoring configuration"
  type        = bool
  default     = true
}

variable "monitoring_settings" {
  description = "Monitoring settings"
  type = object({
    retention_days = number
    categories     = list(string)
  })
  default = {
    retention_days = 30
    categories     = ["Audit", "SignInLogs"]
  }
}

resource "azurerm_storage_account" "main" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Only create monitoring configuration if enabled
  dynamic "blob_properties" {
    for_each = var.enable_monitoring ? [1] : []
    content {
      delete_retention_policy {
        days = var.monitoring_settings.retention_days
      }
      container_delete_retention_policy {
        days = var.monitoring_settings.retention_days
      }
    }
  }
}
```

### nested dynamic blocks

```hcl
variable "virtual_machines" {
  description = "Virtual machine configurations"
  type = map(object({
    size           = string
    admin_username = string
    data_disks = list(object({
      name         = string
      disk_size_gb = number
      caching      = string
      lun          = number
    }))
    network_interfaces = list(object({
      name                          = string
      primary                       = bool
      subnet_id                     = string
      private_ip_address_allocation = string
      private_ip_address            = optional(string)
    }))
  }))
}

resource "azurerm_linux_virtual_machine" "vms" {
  for_each = var.virtual_machines
  
  name                = each.key
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = each.value.size
  admin_username      = each.value.admin_username

  # Nested dynamic blocks for network interfaces
  dynamic "network_interface_ids" {
    for_each = each.value.network_interfaces
    content {
      network_interface_ids = [azurerm_network_interface.vm_nics["${each.key}-${network_interface_ids.value.name}"].id]
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Dynamic data disks
  dynamic "additional_capabilities" {
    for_each = length(each.value.data_disks) > 0 ? [1] : []
    content {
      ultra_ssd_enabled = true
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

# Create network interfaces dynamically
resource "azurerm_network_interface" "vm_nics" {
  for_each = {
    for vm_key, vm in var.virtual_machines : 
    "${vm_key}-${nic.name}" => {
      vm_name = vm_key
      nic     = nic
    }
    for nic in vm.network_interfaces
  }

  name                = each.key
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.nic.subnet_id
    private_ip_address_allocation = each.value.nic.private_ip_address_allocation
    private_ip_address            = each.value.nic.private_ip_address
    primary                       = each.value.nic.primary
  }
}
```

## best practices

### 1. use meaningful iterator names
```hcl
# Good: descriptive iterator name
dynamic "security_rule" {
  for_each = var.security_rules
  content {
    name = security_rule.value.name
    # ...
  }
}

# Avoid: generic iterator name
dynamic "security_rule" {
  for_each = var.security_rules
  iterator = item
  content {
    name = item.value.name
    # ...
  }
}
```

### 2. validate input data
```hcl
variable "security_rules" {
  description = "List of security rules"
  type = list(object({
    name     = string
    priority = number
    # ...
  }))
  
  validation {
    condition = alltrue([
      for rule in var.security_rules : rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Security rule priorities must be between 100 and 4096."
  }
}
```

### 3. use locals for complex transformations
```hcl
locals {
  # Transform input data for easier consumption
  security_rules_by_priority = {
    for rule in var.security_rules : rule.priority => rule
  }
  
  # Create default values
  security_rules_with_defaults = [
    for rule in var.security_rules : merge(rule, {
      source_port_range = coalesce(rule.source_port_range, "*")
      protocol         = upper(coalesce(rule.protocol, "TCP"))
    })
  ]
}

resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "security_rule" {
    for_each = local.security_rules_with_defaults
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      # ...
    }
  }
}
```

### 4. document dynamic block usage
```hcl
# Dynamic security rules allow flexible NSG configuration
# Each rule in var.security_rules will generate a security_rule block
# This enables environment-specific rule sets while maintaining DRY principles
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      # ...existing code...
    }
  }
}
```

### 5. consider performance implications
```hcl
# For large lists, consider using for_each on resources instead
# This is more efficient than dynamic blocks for many items

# Less efficient: dynamic block with 100 items
dynamic "some_block" {
  for_each = var.large_list  # 100 items
  content {
    # ...
  }
}

# More efficient: separate resources with for_each
resource "azurerm_resource_type" "items" {
  for_each = { for item in var.large_list : item.name => item }
  
  name = each.value.name
  # ...
}
```

## when not to use dynamic blocks

### 1. simple static configurations
```hcl
# Don't use dynamic blocks for simple, static configurations
# This is overkill:
dynamic "ip_configuration" {
  for_each = [1]
  content {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Better:
ip_configuration {
  name                          = "internal"
  subnet_id                     = var.subnet_id
  private_ip_address_allocation = "Dynamic"
}
```

### 2. when readability suffers
If dynamic blocks make the configuration harder to understand, consider alternative approaches like separate resources with for_each.

### 3. complex nested logic
Avoid deeply nested dynamic blocks that become difficult to maintain.

## troubleshooting dynamic blocks

### 1. debug with local values
```hcl
locals {
  # Debug: see what data is being processed
  debug_security_rules = {
    for i, rule in var.security_rules : i => {
      name     = rule.name
      priority = rule.priority
      valid    = rule.priority >= 100 && rule.priority <= 4096
    }
  }
}

output "debug_security_rules" {
  value = local.debug_security_rules
}
```

### 2. validate for_each expressions
```hcl
# Ensure for_each expressions return the expected data structure
output "for_each_debug" {
  value = var.security_rules
}
```

### 3. use terraform console
```bash
# Test expressions interactively
terraform console

# Test your for_each expression
> var.security_rules
> [for rule in var.security_rules : rule.name]
```

## conclusion

Dynamic blocks are a powerful feature for creating flexible, data-driven terraform configurations. They help eliminate code duplication and make modules more reusable by allowing the generation of nested blocks based on input data.

Use dynamic blocks when you have repetitive nested blocks that vary based on input data, but avoid them for simple static configurations where they add unnecessary complexity. Always prioritize readability and maintainability when deciding whether to use dynamic blocks.

Remember to validate input data, use meaningful names, and document the purpose of dynamic blocks to ensure your configurations remain maintainable as they grow in complexity.
