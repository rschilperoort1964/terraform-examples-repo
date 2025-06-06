# Module 3 Lab - Count vs For_Each

This lab demonstrates the differences between using `count` and `for_each` meta-arguments in Terraform.

## Overview

This configuration creates:
- **Storage Accounts** using `for_each` with a set of strings
- **Key Vaults** using `count` with a numeric value

## Key Differences

### Using `count`
- Creates resources based on a **numeric value**
- Resources are indexed by **integers** (0, 1, 2, ...)
- Access pattern: `module.key_vault_count[0]`, `module.key_vault_count[1]`
- Good for creating a simple number of identical resources
- **Limitation**: If you remove an item from the middle, Terraform will recreate resources to maintain the index order

### Using `for_each`
- Creates resources based on a **set or map**
- Resources are indexed by **string keys**
- Access pattern: `module.storage_account_for_each["one"]`, `module.storage_account_for_each["two"]`
- Good for creating resources with meaningful identifiers
- **Advantage**: You can add/remove items without affecting other resources

## Example Resources Created

### Development Environment
- Storage Accounts: `satfadvdevone`, `satfadvdevtwo`
- Key Vaults: `kv-tfadv-dev-1`, `kv-tfadv-dev-2`

### Production Environment
- Storage Accounts: `satfadvprodone`, `satfadvprodtwo`
- Key Vaults: `kv-tfadv-prod-1`, `kv-tfadv-prod-2`, `kv-tfadv-prod-3`
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

### Use `count` when:
- You need a simple number of identical resources
- The resources don't need meaningful identifiers
- You're okay with potential recreation if the count changes

### Use `for_each` when:
- You have a known set of resource identifiers
- You want to avoid resource recreation when adding/removing items
- You need to reference resources by meaningful keys
- You're working with complex resource configurations that vary per instance

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
