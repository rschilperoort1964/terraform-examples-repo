# GitHub Actions for Terraform

This directory contains GitHub Actions workflows that replace the Azure DevOps pipelines for Terraform deployments.

## Workflows

### 1. Terraform CI (`terraform-ci.yml`)
- **Trigger**: Pull requests to main branch that modify files in `Module-5/github/**`
- **Purpose**: Validates Terraform code, runs pre-commit hooks, and creates a plan
- **Jobs**:
  - Runs pre-commit hooks (formatting, linting, security checks)
  - Validates Terraform syntax
  - Creates a Terraform plan for the dev environment

### 2. Terraform CD (`terraform-cd.yml`)
- **Trigger**: 
  - Pushes to main branch that modify files in `Module-5/github/**`
  - Manual workflow dispatch with environment selection
- **Purpose**: Deploys infrastructure to dev and production environments
- **Jobs**:
  - **plan-dev**: Creates a plan for the dev environment
  - **deploy-dev**: Applies the plan to dev environment (requires approval)
  - **plan-prd**: Creates a plan for production (only on main branch)
  - **deploy-prd**: Applies the plan to production (requires approval)

## Setup Requirements

### 1. GitHub Environments
Create the following environments in your GitHub repository settings:
- `dev` - Development environment
- `prd` - Production environment

For each environment, configure:
- Protection rules requiring manual approval before deployment
- Environment-specific secrets

### 2. GitHub Secrets
Configure the following secrets in your repository:

#### Repository Secrets
- `AZURE_CREDENTIALS` - Azure service principal credentials for dev environment
- `AZURE_CREDENTIALS_PRD` - Azure service principal credentials for production environment

#### Azure Service Principal Format
The Azure credentials should be in JSON format:
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

### 3. Azure Service Principal Setup
Create service principals for each environment with the following permissions:
- Contributor role on the subscription or resource group
- Storage Blob Data Contributor on the Terraform state storage account

```bash
# For dev environment
az ad sp create-for-rbac --name "sp-terraform-dev" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-estfdemo-terra-dev

# For production environment
az ad sp create-for-rbac --name "sp-terraform-prd" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-estfdemo-terra-prd
```

### 4. Terraform Backend
Ensure the following Azure resources exist for Terraform state storage:

#### Dev Environment
- Resource Group: `rg-estfdemo-terra-dev`
- Storage Account: `stestfdemosterradev`
- Container: `terraformstate`

#### Production Environment
- Resource Group: `rg-estfdemo-terra-prd`
- Storage Account: `stestfdemosterraprd`
- Container: `terraformstate`

### 5. Pre-commit Setup
The repository includes a `.pre-commit-config.yaml` file that:
- Formats Terraform code
- Validates Terraform syntax
- Runs TFLint for best practices
- Runs TFSec for security scanning
- Checks for common issues (trailing whitespace, large files, etc.)

## Key Differences from Azure DevOps

1. **Environment Protection**: GitHub environments provide deployment protection rules similar to Azure DevOps environments
2. **Artifacts**: GitHub Actions uses `upload-artifact` and `download-artifact` actions instead of Azure DevOps pipeline artifacts
3. **Service Connections**: Azure login is handled via the `azure/login` action with service principal credentials
4. **Conditional Deployment**: Production deployment only occurs when pushing to the main branch
5. **Manual Triggers**: The CD workflow supports manual triggering with environment selection

## Monitoring and Troubleshooting

- Check the Actions tab in your GitHub repository for workflow runs
- Environment deployments require manual approval before proceeding
- Plan artifacts are retained for 30 days for debugging purposes
- All Terraform operations include detailed logging for troubleshooting

## Security Considerations

- Service principal credentials are stored as GitHub secrets
- Environment-specific secrets prevent cross-environment access
- Pre-commit hooks include security scanning with TFSec
- Terraform plans are validated before apply operations
- Manual approval is required for all deployments
