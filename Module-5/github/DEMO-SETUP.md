# Demo Setup Guide: GitHub Actions for Terraform

This guide will walk you through setting up and demonstrating the GitHub Actions Terraform workflows in a live environment.

## Prerequisites

Before starting the demo, ensure you have:

- An Azure subscription with appropriate permissions
- A GitHub repository with this code
- Azure CLI installed and configured
- Terraform CLI installed (version >= 1.1.7)
- Git configured locally

## Step 1: Prepare Azure Resources

### 1.1 Create Azure Service Principals

Create service principals for both environments:

```bash
# Login to Azure
az login

# Get your subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# Create service principal for dev environment
az ad sp create-for-rbac --name "sp-terraform-demo-dev" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth

# Create service principal for production environment  
az ad sp create-for-rbac --name "sp-terraform-demo-prd" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth
```

**Save the JSON output** from both commands - you'll need these for GitHub secrets.

### 1.2 Create Terraform State Storage

Run these commands to create the backend storage for both environments:

```bash
# Variables
PROJECT_NAME="estfdemo"
LOCATION="westeurope"

# Create dev environment resources
DEV_RG="rg-${PROJECT_NAME}-terra-dev"
DEV_STORAGE="st${PROJECT_NAME}terradev"

az group create --name $DEV_RG --location $LOCATION
az storage account create \
  --name $DEV_STORAGE \
  --resource-group $DEV_RG \
  --location $LOCATION \
  --sku Standard_LRS
az storage container create \
  --name terraformstate \
  --account-name $DEV_STORAGE

# Create production environment resources
PRD_RG="rg-${PROJECT_NAME}-terra-prd"
PRD_STORAGE="st${PROJECT_NAME}terraprd"

az group create --name $PRD_RG --location $LOCATION
az storage account create \
  --name $PRD_STORAGE \
  --resource-group $PRD_RG \
  --location $LOCATION \
  --sku Standard_LRS
az storage container create \
  --name terraformstate \
  --account-name $PRD_STORAGE
```

## Step 2: Configure GitHub Repository

### 2.1 Create GitHub Environments

1. Go to your GitHub repository
2. Navigate to **Settings** → **Environments**
3. Create two environments:

#### Dev Environment
- Name: `dev`
- Protection rules:
  - ✅ Required reviewers (add yourself)
  - ✅ Wait timer: 0 minutes
  - ✅ Restrict pushes that create this environment to selected branches: `main`

#### Production Environment  
- Name: `prd`
- Protection rules:
  - ✅ Required reviewers (add yourself)
  - ✅ Wait timer: 5 minutes (optional)
  - ✅ Restrict pushes that create this environment to selected branches: `main`

### 2.2 Configure GitHub Secrets

Navigate to **Settings** → **Secrets and variables** → **Actions**

#### Repository Secrets
Add these secrets with the JSON output from the service principal creation:

1. **`AZURE_CREDENTIALS`**
   ```json
   {
     "clientId": "dev-service-principal-client-id",
     "clientSecret": "dev-service-principal-secret",
     "subscriptionId": "your-subscription-id",
     "tenantId": "your-tenant-id"
   }
   ```

2. **`AZURE_CREDENTIALS_PRD`**
   ```json
   {
     "clientId": "prd-service-principal-client-id", 
     "clientSecret": "prd-service-principal-secret",
     "subscriptionId": "your-subscription-id",
     "tenantId": "your-tenant-id"
   }
   ```

## Step 3: Test the Setup Locally (Optional)

Before running the GitHub Actions, test locally:

```bash
# Navigate to the terraform directory
cd Module-5/github

# Login to Azure
az login

# Test dev environment initialization
terraform init \
  -backend-config="resource_group_name=rg-estfdemo-terra-dev" \
  -backend-config="storage_account_name=stestfdemoterradev" \
  -backend-config="container_name=terraformstate" \
  -backend-config="key=terraform.tfstate"

# Test terraform plan
terraform plan -var-file=./config/dev.tfvars

# Clean up local state
rm -rf .terraform
rm terraform.tfstate*
rm *.plan
```

## Step 4: Demo the GitHub Actions

### 4.1 Demo Pull Request Workflow

1. **Create a feature branch:**
   ```bash
   git checkout -b demo/update-terraform
   ```

2. **Make a small change** to demonstrate the CI pipeline:
   ```bash
   # Edit Module-5/github/main.tf and add a tag to the resource group
   ```

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Add demo tag to resource group"
   git push origin demo/update-terraform
   ```

4. **Create a Pull Request** on GitHub

5. **Show the CI workflow running:**
   - Navigate to **Actions** tab
   - Show the "Terraform CI" workflow running
   - Explain each step as it executes:
     - Pre-commit hooks running
     - Terraform validation
     - Plan generation
     - Artifact upload

### 4.2 Demo Deployment Workflow

1. **Merge the Pull Request** after CI passes

2. **Show the CD workflow starting automatically:**
   - Navigate to **Actions** tab
   - Show "Terraform CD" workflow starting
   - Explain the job progression:
     - Plan Dev → Deploy Dev → Plan Prod → Deploy Prod

3. **Demonstrate Environment Protection:**
   - Show how the workflow pauses at dev deployment
   - Approve the dev deployment
   - Show resources being created in Azure portal
   - Show how it then pauses for production approval

4. **Monitor the deployments:**
   ```bash
   # Watch Azure resources being created
   az resource list --resource-group terraform-example-dev --output table
   az resource list --resource-group terraform-example-prd --output table
   ```

### 4.3 Demo Manual Deployment

1. **Go to Actions** → **Terraform CD** → **Run workflow**

2. **Select environment** (dev or prd) from dropdown

3. **Show manual triggering** and explain use cases:
   - Hotfix deployments
   - Rollback scenarios
   - Selective environment deployments

## Step 5: Demo Features

### 5.1 Show Artifact Management
- Navigate to a completed workflow run
- Show the plan artifacts that are stored
- Explain retention policy (30 days)

### 5.2 Show Environment History
- Go to **Environments** in repository settings
- Show deployment history for each environment
- Show approval logs and timing

### 5.3 Show Security Features
- Explain how secrets are environment-scoped
- Show how production requires different credentials
- Demonstrate pre-commit security scanning

## Demo Talking Points

### Key Benefits to Highlight

1. **Automated Validation**: Every PR gets validated automatically
2. **Environment Isolation**: Separate secrets and approvals per environment
3. **Audit Trail**: Complete history of all deployments
4. **Security**: Pre-commit hooks catch issues before deployment
5. **Flexibility**: Support for both automatic and manual deployments
6. **Visibility**: Clear workflow status and detailed logs

### Comparison with Azure DevOps

| Feature | Azure DevOps | GitHub Actions |
|---------|--------------|----------------|
| Environment Protection | Azure DevOps Environments | GitHub Environments |
| Secret Management | Variable Groups | Environment Secrets |
| Approval Process | Manual Intervention | Environment Protection Rules |
| Artifact Storage | Pipeline Artifacts | Actions Artifacts |
| Integration | Separate platform | Native GitHub integration |

## Troubleshooting Common Demo Issues

### Issue: Service Principal Permissions
**Error**: "Authorization failed"
**Solution**: Ensure service principal has Contributor role on subscription

### Issue: Storage Account Access
**Error**: "Backend initialization failed"
**Solution**: Grant service principal Storage Blob Data Contributor role:
```bash
az role assignment create \
  --assignee <service-principal-client-id> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$DEV_RG/providers/Microsoft.Storage/storageAccounts/$DEV_STORAGE"
```

### Issue: Terraform State Conflicts
**Error**: "Error acquiring the state lock"
**Solution**: Clear any locks manually or wait for timeout

### Issue: Environment Not Found
**Error**: "Environment 'dev' not found"
**Solution**: Ensure environments are created in GitHub repository settings

## Clean Up After Demo

```bash
# Delete Azure resources
az group delete --name rg-estfdemo-terra-dev --yes --no-wait
az group delete --name rg-estfdemo-terra-prd --yes --no-wait

# Delete service principals
az ad sp delete --id $(az ad sp list --display-name "sp-terraform-demo-dev" --query "[0].appId" -o tsv)
az ad sp delete --id $(az ad sp list --display-name "sp-terraform-demo-prd" --query "[0].appId" -o tsv)

# Clean up local git
git checkout main
git branch -D demo/update-terraform
```

## Next Steps

After the demo, participants can:
1. Fork this repository to try it themselves
2. Adapt the workflows for their own Terraform projects
3. Explore advanced GitHub Actions features
4. Integrate with other tools in their DevOps pipeline

---

**Pro Tip**: Practice this demo at least once before presenting to ensure smooth execution and timing!
