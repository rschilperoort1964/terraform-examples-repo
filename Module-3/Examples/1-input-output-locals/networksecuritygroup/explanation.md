# Network Security Group Module Demo - Explanation

This document explains the key Terraform concepts demonstrated in the Network Security Group module for your presentation, focusing on the specific points from your slides.

## Demo Flow Overview

Follow this sequence to demonstrate the key Terraform concepts without needing to deploy:

## 1. Briefly Show Module Structure

**Point out the module organization:**
```
networksecuritygroup/
├── networksecuritygroup.tf  # Main resource definitions
├── variables.tf             # Input variables
└── explanation.md          # This demo guide
```

**Key message:** "This is a reusable Terraform module that encapsulates Network Security Group creation logic."

## 2. Location Variable with Default Value and Description

**Show in variables.tf (lines 7-10):**
```hcl
variable "location" {
  type        = string
  default     = "westeurope"
  description = "The Azure region where resources will be created"
}
```

**Demo points to highlight:**
- **Default value:** Users don't have to specify location if "westeurope" works
- **Description:** Makes the variable self-documenting
- **Flexibility:** Can be overridden when needed (`location = "eastus"`)
- **Type safety:** Terraform validates this must be a string

## 3. Show Variables.tf - Different Documentation Approaches

**Point out the contrast in your variables.tf:**

```hcl
# Minimal - just type definition
variable "network_security_group_name" {
  type = string
}

# With useful default
variable "network_watcher_flow_log_retention_policy_days" {
  type    = number
  default = 7
}

# Complex type with detailed description
variable "nsg_diagnostic_setting_logs" {
  type = list(object({
    category_group    = optional(string)
    category          = optional(string)
    retention_enabled = bool
  }))
  default = [{
    category_group    = "allLogs"
    retention_enabled = false
  }]
  description = "Log categories that need to be enabled in the diagnostic settings. Choose category_group or category, but not both."
}
```

**Key teaching points:**
- **Simple variables:** Just need type for obvious ones
- **Add descriptions:** When purpose isn't clear or there are constraints
- **Defaults:** Reduce configuration burden for common values

## 4. Show Optional Variables - Port Range Flexibility

**Highlight this key concept in your nsg_rules variable:**

```hcl
variable "nsg_rules" {
  type = map(object({
    name                         = string
    description                  = optional(string)
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)      # Single port range
    source_port_ranges           = optional(list(string)) # Multiple port ranges
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
}
```

**Critical demo point:** 
> "Notice `source_port_range` vs `source_port_ranges` - Azure requires ONE but not BOTH. This keeps our module flexible while following Azure's API constraints."

**Show practical examples:**

```hcl
# Example 1: Single port range
nsg_rules = {
  "allow_ssh" = {
    name                   = "Allow-SSH"
    priority              = 1000
    direction             = "Inbound"
    access                = "Allow"
    protocol              = "Tcp"
    source_port_range     = "*"           # Single range ✓
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

# Example 2: Multiple port ranges
nsg_rules = {
  "allow_web" = {
    name                    = "Allow-Web"
    priority               = 1100
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_ranges = ["80", "443", "8080"]  # Multiple ranges ✓
    source_address_prefix  = "*"
    destination_address_prefix = "*"
  }
}
```

**Why this matters:**
- Module accommodates different use cases
- Type system prevents invalid configurations
- Users choose the right option for their needs

## 5. Show Output

**Point to the outputs in networksecuritygroup.tf:**

```hcl
#############################################
# Output
#############################################
output "network_security_group_id" {
  value = azurerm_network_security_group.nsg.id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.nsg.name
}
```

**Demo the usage pattern:**
```hcl
# In your main configuration
module "web_nsg" {
  source = "./networksecuritygroup"
  
  network_security_group_name = "web-nsg"
  network_security_group_rg   = "my-rg"
  # ... other variables
}

# Use the module outputs elsewhere
resource "azurerm_virtual_machine" "web_vm" {
  # ...
  network_security_group_id = module.web_nsg.network_security_group_id
}
```

**Key points:**
- Outputs make module resources available to other parts of your infrastructure
- Enables composition and reusability
- Creates dependencies between resources

## 6. Bonus: For Each Loop Demonstration

**Show in networksecuritygroup.tf (lines 15-35):**

```hcl
resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = var.nsg_rules  # Creates one rule per map entry
  
  name        = each.value.name
  priority    = each.value.priority
  # ... other properties use each.value
}
```

**Benefits to highlight:**
- One resource block creates multiple NSG rules
- Each rule is individually tracked in Terraform state
- Adding/removing rules only affects those specific resources
- Map keys become resource identifiers

## Demo Script Summary

1. **"Here's a reusable Terraform module"** → Show file structure
2. **"Variables can have defaults and descriptions"** → Show location variable
3. **"Different documentation approaches"** → Show variables.tf variety
4. **"Optional variables provide flexibility"** → Show port range example
5. **"Outputs enable composition"** → Show output usage
6. **"For each creates multiple resources"** → Show nsg_rules resource

This demonstrates Terraform best practices without requiring deployment!
