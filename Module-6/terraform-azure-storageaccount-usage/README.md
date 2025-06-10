# Terraform Azure Storage Account Module Demo

This demo shows how to use the `hiddedesmet/storageaccount/azure` module from the Terraform Registry.

## Prerequisites

- Terraform >= 1.12.1
- Azure CLI installed and configured
- Azure subscription access

## Setup

1. **Configure variables (recommended):**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` and set a globally unique storage account name.

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Validate the configuration:**
   ```bash
   terraform validate
   ```

3. **Plan the deployment:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply -auto-approve
   ```

5. **Clean up resources:**
   ```bash
   terraform destroy
   ```

## What this demo creates

- An Azure Resource Group named `rg-terraform-storageaccount`
- A Storage Account using the public module from the Terraform Registry

## Module Information

- **Source:** `hiddedesmet/storageaccount/azure`
- **Version:** `1.0.0`
- **Registry:** [Terraform Registry](https://registry.terraform.io/modules/hiddedesmet/storageaccount/azure/1.0.0)

## Outputs

After deployment, you'll see outputs including:
- Storage account name
- Storage account ID
- Primary blob endpoint
- Resource group name