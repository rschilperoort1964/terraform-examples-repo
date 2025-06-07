# Module 3 Lab - Count vs For_Each

This lab demonstrates the differences between using `count` and `for_each` meta-arguments in Terraform.

## Overview

This configuration creates:
- **Storage Accounts** using `for_each` with a set of strings
- **Key Vaults** using `count` with a numeric value

## Key Differences

### Using `for_each` (Storage Accounts)
- Creates resources based on a **set or map of meaningful identifiers**
- Resources are indexed by **string keys** ("logs", "data")
- Access pattern: `module.storage_account_for_each["logs"]`, `module.storage_account_for_each["data"]`
- **Each resource can have different configurations** based on its purpose
- **Advantage**: You can add/remove items without affecting other resources
- **Configuration varies by purpose**:
  - "logs" storage: Standard tier, LRS replication (cheaper for log storage)
  - "data" storage: Premium tier, GRS replication (better performance and redundancy)

### Using `count` (Key Vaults)
- Creates resources based on a **numeric value**
- Resources are indexed by **integers** (0, 1, 2, ...)
- Access pattern: `module.key_vault_count[0]`, `module.key_vault_count[1]`
- **All resources get identical configuration** (limitation of count)
- **Limitation**: If you remove an item from the middle, Terraform will recreate resources to maintain the index order
- **All Key Vaults are identical** - harder to configure them differently

## Example Resources Created

### Development Environment
- **Storage Accounts with different configurations**:
  - `satfadvdevlogs`: Standard tier, LRS replication (for logs)
  - `satfadvdevdata`: Premium tier, GRS replication (for data)
- **Key Vaults with identical configuration**:
  - `kv-tfadv-dev-1`: Standard SKU, basic settings
  - `kv-tfadv-dev-2`: Standard SKU, basic settings (identical to first)

### Production Environment
- **Storage Accounts with different configurations**:
  - `satfadvprodlogs`: Standard tier, LRS replication (for logs)
  - `satfadvproddata`: Premium tier, GRS replication (for data)
- **Key Vaults with identical configuration**:
  - `kv-tfadv-prod-1`, `kv-tfadv-prod-2`, `kv-tfadv-prod-3`: All identical
- Additional storage containers created only in prod

## Usage

```bash
# Initialize Terraform
terraform init

# Plan for development
terraform plan -var-file="dev.tfvars"

# Apply for development
terraform apply -var-file="dev.tfvars"

# Plan for production
terraform plan -var-file="prod.tfvars"

# Apply for production
terraform apply -var-file="prod.tfvars"
```

## When to Use What

### Use `for_each` when:
- You have **meaningful identifiers** for your resources ("logs", "data", "frontend", "backend")
- You want **different configurations** per resource based on purpose
- You want to avoid resource recreation when adding/removing items
- You need to reference resources by meaningful keys
- **Example**: Different storage accounts for different purposes with different performance requirements

### Use `count` when:
- You need a simple number of **identical resources**
- The resources don't need meaningful identifiers beyond numbers
- You're okay with all resources having the same configuration
- You're okay with potential recreation if the count changes
- **Example**: Multiple identical Key Vaults for redundancy in different regions

## Files Structure

```
lab/
├── main.tf              # Main configuration with both count and for_each examples
├── variables.tf         # Variable definitions
├── outputs.tf          # Output definitions showing the differences
├── providers.tf        # Provider configuration
├── dev.tfvars          # Development environment variables
├── prod.tfvars         # Production environment variables
└── modules/
    ├── storage_account/ # Storage account module (used with for_each)
    └── keyvault/       # Key vault module (used with count)
```
