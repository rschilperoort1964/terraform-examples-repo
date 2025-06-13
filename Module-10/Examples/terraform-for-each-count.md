# terraform for_each and count guide

## what are for_each and count?

`for_each` and `count` are terraform meta-arguments that allow you to create multiple instances of a resource, data source, or module from a single configuration block. They enable you to avoid duplicating configuration code when you need to create similar resources with slight variations.

## why use for_each and count?

### 1. eliminate code duplication
Create multiple similar resources without writing repetitive configuration blocks.

### 2. dynamic resource creation
Generate resources based on input variables, making your configurations more flexible and data-driven.

### 3. easier maintenance
Update one configuration block instead of maintaining multiple similar blocks.

### 4. scalable infrastructure
Easily scale up or down by modifying variables rather than adding/removing configuration blocks.

## key differences between for_each and count

| aspect | count | for_each |
|--------|-------|----------|
| **input type** | number | set or map |
| **instance reference** | index (0, 1, 2...) | key from set/map |
| **adding/removing** | affects all instances | only affects specific instances |
| **use case** | identical resources | resources with variations |
| **state management** | positional (fragile) | key-based (stable) |
| **recommendation** | avoid in most cases | preferred approach |

## count examples

### example 1: basic count usage

```hcl
variable "storage_account_count" {
  description = "Number of storage accounts to create"
  type        = number
  default     = 3
}

# Create multiple identical storage accounts
resource "azurerm_storage_account" "example" {
  count = var.storage_account_count

  name                     = "storage${count.index + 1}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Development"
    Index       = count.index
  }
}

# Output all storage account names
output "storage_account_names" {
  value = azurerm_storage_account.example[*].name
}
```

### example 2: count with conditional creation

```hcl
variable "create_monitoring" {
  description = "Whether to create monitoring resources"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Create application insights only in non-dev environments
resource "azurerm_application_insights" "main" {
  count = var.environment != "dev" && var.create_monitoring ? 1 : 0

  name                = "app-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"

  tags = {
    Environment = var.environment
  }
}

# Reference the conditionally created resource
resource "azurerm_linux_web_app" "main" {
  name                = "example-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.main.id

  app_settings = {
    # Use try() to handle when application insights doesn't exist
    "APPINSIGHTS_INSTRUMENTATIONKEY" = try(azurerm_application_insights.main[0].instrumentation_key, "")
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
  }
}
```

### problems with count

```hcl
# Problem: Adding a storage account at the beginning affects all indices
variable "storage_accounts" {
  type = list(string)
  # Original: ["app", "logs", "backup"]
  # New: ["temp", "app", "logs", "backup"]  # This will cause recreation!
}

resource "azurerm_storage_account" "example" {
  count = length(var.storage_accounts)

  name                     = "storage${var.storage_accounts[count.index]}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# When you add "temp" at the beginning:
# - storage0: "app" -> "temp" (recreation)
# - storage1: "logs" -> "app" (recreation) 
# - storage2: "backup" -> "logs" (recreation)
# - storage3: new -> "backup" (creation)
```

## for_each examples

### example 1: basic for_each with set

```hcl
variable "environments" {
  description = "Set of environments to create"
  type        = set(string)
  default     = ["dev", "staging", "prod"]
}

# Create resource group for each environment
resource "azurerm_resource_group" "env" {
  for_each = var.environments

  name     = "rg-${each.key}"
  location = "West Europe"

  tags = {
    Environment = each.key
    ManagedBy   = "Terraform"
  }
}

# Reference specific environment
resource "azurerm_storage_account" "app_storage" {
  for_each = var.environments

  name                     = "storage${each.key}app"
  resource_group_name      = azurerm_resource_group.env[each.key].name
  location                 = azurerm_resource_group.env[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = each.key
    Purpose     = "Application Data"
  }
}
```

### example 2: for_each with map of objects

```hcl
variable "storage_accounts" {
  description = "Map of storage accounts to create"
  type = map(object({
    tier                 = string
    replication_type     = string
    enable_https_traffic = bool
    purpose             = string
  }))
  default = {
    "appdata" = {
      tier                 = "Standard"
      replication_type     = "LRS"
      enable_https_traffic = true
      purpose             = "Application Data"
    }
    "logs" = {
      tier                 = "Standard"
      replication_type     = "GRS"
      enable_https_traffic = true
      purpose             = "Log Storage"
    }
    "backup" = {
      tier                 = "Standard"
      replication_type     = "RA-GRS"
      enable_https_traffic = true
      purpose             = "Backup Storage"
    }
  }
}

resource "azurerm_storage_account" "main" {
  for_each = var.storage_accounts

  name                      = "storage${each.key}"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  account_tier              = each.value.tier
  account_replication_type  = each.value.replication_type
  enable_https_traffic_only = each.value.enable_https_traffic

  tags = {
    Purpose     = each.value.purpose
    Environment = "Production"
  }
}

# Create containers for specific storage accounts
resource "azurerm_storage_container" "logs" {
  count                 = contains(keys(var.storage_accounts), "logs") ? 1 : 0
  name                  = "application-logs"
  storage_account_name  = azurerm_storage_account.main["logs"].name
  container_access_type = "private"
}
```

### example 3: for_each with complex networking

```hcl
variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = list(string)
    nsg_rules = list(object({
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
  }))
  default = {
    "web" = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      nsg_rules = [
        {
          name                       = "AllowHTTP"
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
          name                       = "AllowHTTPS"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    "app" = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Sql"]
      nsg_rules = [
        {
          name                       = "AllowAppPort"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.0.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    "data" = {
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = []
      nsg_rules = [
        {
          name                       = "AllowSQL"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.0.2.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
  }
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create network security groups for each subnet
resource "azurerm_network_security_group" "subnet_nsg" {
  for_each = var.subnets

  name                = "${each.key}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  dynamic "security_rule" {
    for_each = each.value.nsg_rules
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

  tags = {
    Subnet = each.key
  }
}

# Create subnets
resource "azurerm_subnet" "main" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}

# Associate NSGs with subnets
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[each.key].id
}
```

### example 4: for_each with virtual machines

```hcl
variable "virtual_machines" {
  description = "Map of virtual machines to create"
  type = map(object({
    size               = string
    admin_username     = string
    subnet_key         = string
    os_disk_size_gb    = number
    enable_public_ip   = bool
    availability_zone  = string
    data_disks = list(object({
      name         = string
      disk_size_gb = number
      caching      = string
      lun          = number
    }))
  }))
  default = {
    "web01" = {
      size               = "Standard_B2s"
      admin_username     = "azureuser"
      subnet_key         = "web"
      os_disk_size_gb    = 30
      enable_public_ip   = true
      availability_zone  = "1"
      data_disks = []
    }
    "app01" = {
      size               = "Standard_D2s_v3"
      admin_username     = "azureuser"
      subnet_key         = "app"
      os_disk_size_gb    = 64
      enable_public_ip   = false
      availability_zone  = "2"
      data_disks = [
        {
          name         = "app-data"
          disk_size_gb = 128
          caching      = "ReadWrite"
          lun          = 0
        }
      ]
    }
    "db01" = {
      size               = "Standard_E4s_v3"
      admin_username     = "azureuser"
      subnet_key         = "data"
      os_disk_size_gb    = 64
      enable_public_ip   = false
      availability_zone  = "3"
      data_disks = [
        {
          name         = "db-data"
          disk_size_gb = 512
          caching      = "None"
          lun          = 0
        },
        {
          name         = "db-logs"
          disk_size_gb = 256
          caching      = "None"
          lun          = 1
        }
      ]
    }
  }
}

# Create public IPs for VMs that need them
resource "azurerm_public_ip" "vm_public_ip" {
  for_each = {
    for vm_name, vm_config in var.virtual_machines : vm_name => vm_config
    if vm_config.enable_public_ip
  }

  name                = "${each.key}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.value.availability_zone]

  tags = {
    VM = each.key
  }
}

# Create network interfaces for VMs
resource "azurerm_network_interface" "vm_nic" {
  for_each = var.virtual_machines

  name                = "${each.key}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.enable_public_ip ? azurerm_public_ip.vm_public_ip[each.key].id : null
  }

  tags = {
    VM = each.key
  }
}

# Create managed disks for data disks
resource "azurerm_managed_disk" "vm_data_disk" {
  for_each = {
    for vm_disk in flatten([
      for vm_name, vm_config in var.virtual_machines : [
        for disk in vm_config.data_disks : {
          vm_name   = vm_name
          disk_name = disk.name
          size_gb   = disk.disk_size_gb
          zone      = vm_config.availability_zone
        }
      ]
    ]) : "${vm_disk.vm_name}-${vm_disk.disk_name}" => vm_disk
  }

  name                 = "${each.value.vm_name}-${each.value.disk_name}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.size_gb
  zones                = [each.value.zone]

  tags = {
    VM   = each.value.vm_name
    Disk = each.value.disk_name
  }
}

# Create virtual machines
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.virtual_machines

  name                = each.key
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = each.value.size
  admin_username      = each.value.admin_username
  zone                = each.value.availability_zone

  # Disable password authentication
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id
  ]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = each.value.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Role = each.key
    Tier = each.value.subnet_key
  }
}

# Attach data disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disk_attachment" {
  for_each = {
    for vm_disk in flatten([
      for vm_name, vm_config in var.virtual_machines : [
        for i, disk in vm_config.data_disks : {
          vm_name   = vm_name
          disk_name = disk.name
          lun       = disk.lun
          caching   = disk.caching
        }
      ]
    ]) : "${vm_disk.vm_name}-${vm_disk.disk_name}" => vm_disk
  }

  managed_disk_id    = azurerm_managed_disk.vm_data_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.value.vm_name].id
  lun                = each.value.lun
  caching            = each.value.caching
}
```

### example 5: for_each with modules

```hcl
variable "applications" {
  description = "Map of applications to deploy"
  type = map(object({
    environment     = string
    app_service_sku = string
    database_sku    = string
    enable_redis    = bool
    custom_domains  = list(string)
    app_settings = map(string)
  }))
  default = {
    "frontend" = {
      environment     = "production"
      app_service_sku = "P1v2"
      database_sku    = "S2"
      enable_redis    = true
      custom_domains  = ["www.example.com", "example.com"]
      app_settings = {
        "NODE_ENV" = "production"
        "API_URL"  = "https://api.example.com"
      }
    }
    "api" = {
      environment     = "production"
      app_service_sku = "P2v2"
      database_sku    = "S3"
      enable_redis    = true
      custom_domains  = ["api.example.com"]
      app_settings = {
        "ASPNETCORE_ENVIRONMENT" = "Production"
        "DATABASE_CONNECTION"    = "encrypted"
      }
    }
    "admin" = {
      environment     = "staging"
      app_service_sku = "B1"
      database_sku    = "Basic"
      enable_redis    = false
      custom_domains  = []
      app_settings = {
        "NODE_ENV" = "staging"
      }
    }
  }
}

# Create application environments using modules
module "application" {
  source = "./modules/web-application"
  
  for_each = var.applications

  application_name = each.key
  environment      = each.value.environment
  app_service_sku  = each.value.app_service_sku
  database_sku     = each.value.database_sku
  enable_redis     = each.value.enable_redis
  custom_domains   = each.value.custom_domains
  app_settings     = each.value.app_settings

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
}

# Output application URLs
output "application_urls" {
  value = {
    for app_name, app in module.application : app_name => app.application_url
  }
}
```

## converting from count to for_each

### step 1: identify the conversion need
```hcl
# Original count-based configuration (problematic)
variable "environments" {
  type = list(string)
  default = ["dev", "staging", "prod"]
}

resource "azurerm_resource_group" "env" {
  count = length(var.environments)
  
  name     = "rg-${var.environments[count.index]}"
  location = "West Europe"
}
```

### step 2: convert to for_each
```hcl
# Converted to for_each (better)
variable "environments" {
  type = set(string)  # Change from list to set
  default = ["dev", "staging", "prod"]
}

resource "azurerm_resource_group" "env" {
  for_each = var.environments
  
  name     = "rg-${each.key}"
  location = "West Europe"
}
```

### step 3: update references
```hcl
# Old count-based reference
resource "azurerm_storage_account" "app" {
  count = length(var.environments)
  
  name                = "storage${var.environments[count.index]}"
  resource_group_name = azurerm_resource_group.env[count.index].name
  # ...
}

# New for_each reference
resource "azurerm_storage_account" "app" {
  for_each = var.environments
  
  name                = "storage${each.key}"
  resource_group_name = azurerm_resource_group.env[each.key].name
  # ...
}
```

## advanced patterns

### conditional for_each
```hcl
variable "environments" {
  type = map(object({
    create_monitoring = bool
    tier              = string
  }))
  default = {
    "dev" = {
      create_monitoring = false
      tier              = "Free"
    }
    "prod" = {
      create_monitoring = true
      tier              = "Standard"
    }
  }
}

# Create monitoring only for environments that need it
resource "azurerm_application_insights" "monitoring" {
  for_each = {
    for env_name, env_config in var.environments : env_name => env_config
    if env_config.create_monitoring
  }

  name                = "${each.key}-appinsights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  
  tags = {
    Environment = each.key
    Tier        = each.value.tier
  }
}
```

### transforming data for for_each
```hcl
locals {
  # Transform list to map for for_each compatibility
  subnet_configs = [
    { name = "web", cidr = "10.0.1.0/24" },
    { name = "app", cidr = "10.0.2.0/24" },
    { name = "db",  cidr = "10.0.3.0/24" }
  ]
  
  # Convert to map for for_each
  subnets = {
    for subnet in local.subnet_configs : subnet.name => subnet
  }
}

resource "azurerm_subnet" "main" {
  for_each = local.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.cidr]
}
```

## best practices

### 1. prefer for_each over count
```hcl
# Preferred: for_each with descriptive keys
resource "azurerm_storage_account" "apps" {
  for_each = toset(["frontend", "backend", "admin"])
  
  name = "storage${each.key}"
  # ...
}

# Avoid: count with positional indices
resource "azurerm_storage_account" "apps" {
  count = 3
  
  name = "storage${count.index}"
  # ...
}
```

### 2. use meaningful keys
```hcl
# Good: descriptive keys
for_each = {
  "web-tier"  = { subnet = "10.0.1.0/24", nsg_rules = [...] }
  "app-tier"  = { subnet = "10.0.2.0/24", nsg_rules = [...] }
  "data-tier" = { subnet = "10.0.3.0/24", nsg_rules = [...] }
}

# Avoid: numeric or non-descriptive keys
for_each = {
  "1" = { subnet = "10.0.1.0/24" }
  "2" = { subnet = "10.0.2.0/24" }
  "3" = { subnet = "10.0.3.0/24" }
}
```

### 3. validate input data
```hcl
variable "environments" {
  description = "Map of environments"
  type = map(object({
    tier = string
    size = string
  }))
  
  validation {
    condition = alltrue([
      for env in values(var.environments) : contains(["Free", "Basic", "Standard"], env.tier)
    ])
    error_message = "Environment tier must be Free, Basic, or Standard."
  }
}
```

### 4. use locals for complex transformations
```hcl
locals {
  # Complex data transformation
  vm_configs = {
    for vm_name, vm_config in var.virtual_machines : vm_name => merge(vm_config, {
      # Add computed values
      full_name = "${var.environment}-${vm_name}"
      subnet_id = azurerm_subnet.main[vm_config.subnet_key].id
      # Normalize values
      size = upper(vm_config.size)
    })
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = local.vm_configs
  
  name = each.value.full_name
  size = each.value.size
  # ...
}
```

### 5. handle empty collections gracefully
```hcl
variable "optional_resources" {
  description = "Optional resources to create"
  type        = map(object({ tier = string }))
  default     = {}  # Empty map as default
}

# This handles empty collections correctly
resource "azurerm_resource" "optional" {
  for_each = var.optional_resources
  
  name = each.key
  tier = each.value.tier
  # ...
}

# No resources created if var.optional_resources is empty
```

## when to use count vs for_each

### use count when:
- Creating identical resources with no variation
- Implementing conditional resource creation (0 or 1 instances)
- Working with simple numeric scaling

```hcl
# Good use of count: conditional creation
resource "azurerm_application_insights" "monitoring" {
  count = var.enable_monitoring ? 1 : 0
  
  name = "app-insights"
  # ...
}

# Good use of count: identical resources
resource "azurerm_availability_set" "vm_as" {
  count = var.vm_count > 1 ? 1 : 0
  
  name = "vm-availability-set"
  # ...
}
```

### use for_each when:
- Resources have different configurations
- You need stable resource addressing
- Adding/removing specific resources shouldn't affect others

```hcl
# Good use of for_each: different configurations
resource "azurerm_storage_account" "apps" {
  for_each = var.applications
  
  name                     = "storage${each.key}"
  account_tier             = each.value.storage_tier
  account_replication_type = each.value.replication_type
  # ...
}
```

## troubleshooting common issues

### 1. converting list to set/map for for_each
```hcl
# Problem: for_each doesn't accept lists
variable "server_names" {
  type = list(string)
  default = ["web1", "web2", "app1"]
}

# Solution: convert to set
resource "azurerm_virtual_machine" "servers" {
  for_each = toset(var.server_names)  # Convert list to set
  
  name = each.key
  # ...
}

# Alternative: convert to map with index
resource "azurerm_virtual_machine" "servers" {
  for_each = {
    for i, name in var.server_names : name => {
      index = i
      name  = name
    }
  }
  
  name = each.value.name
  # ...
}
```

### 2. handling null or undefined values
```hcl
# Problem: null values in for_each
variable "environments" {
  type = map(object({
    size = string
    tier = string
  }))
  default = {
    "dev"  = { size = "small", tier = "free" }
    "prod" = null  # This will cause an error
  }
}

# Solution: filter out null values
resource "azurerm_app_service_plan" "main" {
  for_each = {
    for env_name, env_config in var.environments : env_name => env_config
    if env_config != null
  }
  
  name = "${each.key}-plan"
  # ...
}
```

### 3. debugging for_each expressions
```hcl
# Use locals to debug complex for_each expressions
locals {
  debug_environments = {
    for env_name, env_config in var.environments : env_name => {
      original = env_config
      processed = {
        name = "${var.prefix}-${env_name}"
        tier = upper(env_config.tier)
      }
      valid = env_config != null && env_config.tier != ""
    }
  }
}

# Output for debugging
output "debug_environments" {
  value = local.debug_environments
}
```

## conclusion

Both `for_each` and `count` are powerful tools for creating multiple resources, but `for_each` is generally preferred for most use cases due to its stability and flexibility. Use `count` only for simple scenarios like conditional resource creation or when creating truly identical resources.

Key takeaways:
- **for_each** provides stable resource addressing using keys
- **count** uses positional indices which can be fragile
- **for_each** works with sets and maps, **count** works with numbers
- Always prefer **for_each** when resources have different configurations
- Use **count** for conditional creation (0 or 1 instances)
- Convert lists to sets or maps when using **for_each**
- Validate input data and handle edge cases gracefully

Remember that both meta-arguments make your terraform configurations more maintainable and scalable, eliminating the need for repetitive resource blocks.
