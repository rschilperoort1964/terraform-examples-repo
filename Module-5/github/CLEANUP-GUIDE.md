# Cleanup Guide: Removing Azure DevOps Files

Now that we have fully migrated to GitHub Actions, several files from the Azure DevOps setup are no longer needed.

## 🗑️ **Files/Folders to Remove**

### **Entire `pipelines/` folder**
```bash
rm -rf Module-5/devops/pipelines/
```

**What this removes:**
- `azure-pipelines.yml` - Main DevOps pipeline ❌
- `pr-pipeline.yml` - PR validation pipeline ❌  
- `release-stage.yml` - Release stage template ❌
- `task/init.yml` - Init task template ❌
- `task/plan.yml` - Plan task template ❌

**Why safe to remove:** All functionality has been migrated to GitHub Actions workflows.

### **Azure DevOps Scripts** (Optional)
```bash
rm Module-5/devops/apply-tf.sh
rm Module-5/devops/init-tf.sh  
rm Module-5/devops/plan-tf.sh
```

**Why remove:** These were specific to the DevOps pipeline workflow. Our GitHub Actions use integrated Terraform commands.

## ✅ **Files to Keep**

### **Infrastructure Files** (Keep)
- `main.tf` - Infrastructure definition
- `variables.tf` - Variable definitions
- `locals.tf` - Local values
- `setup.tf` - Provider configuration
- `backend.tf` - Backend configuration
- `config/dev.tfvars` - Environment variables
- `config/prd.tfvars` - Environment variables

### **Pre-commit Configuration**
**Decision needed:** The `.pre-commit-config.yaml` exists in BOTH locations:

- `/Module-5/devops/.pre-commit-config.yaml` ❌ Remove
- `/Module-5/github/.pre-commit-config.yaml` ✅ Keep

**Action:** Remove the devops version since we're using the github version:
```bash
rm Module-5/devops/.pre-commit-config.yaml
```

### **Git Ignore**
**Decision needed:** The `.gitignore` exists in BOTH locations:

- `/Module-5/devops/.gitignore` ❌ Remove  
- `/Module-5/github/.gitignore` ✅ Keep (enhanced version)

**Action:** Remove the devops version:
```bash
rm Module-5/devops/.gitignore
```

## 🧹 **Complete Cleanup Script**

Here's a single script to clean up all unnecessary Azure DevOps files:

```bash
#!/bin/bash
# Cleanup Azure DevOps migration artifacts

echo "🧹 Cleaning up Azure DevOps files after GitHub Actions migration..."

# Remove entire pipelines directory
if [ -d "Module-5/devops/pipelines" ]; then
    echo "Removing pipelines directory..."
    rm -rf Module-5/devops/pipelines/
fi

# Remove DevOps-specific scripts  
echo "Removing DevOps-specific scripts..."
rm -f Module-5/devops/apply-tf.sh
rm -f Module-5/devops/init-tf.sh
rm -f Module-5/devops/plan-tf.sh

# Remove duplicate config files
echo "Removing duplicate configuration files..."
rm -f Module-5/devops/.pre-commit-config.yaml
rm -f Module-5/devops/.gitignore

echo "✅ Cleanup complete!"
echo ""
echo "📁 Remaining devops files (infrastructure only):"
ls -la Module-5/devops/
echo ""
echo "📁 GitHub Actions files (migration target):"
ls -la Module-5/github/
```

## 📊 **Before vs After Structure**

### **Before Cleanup:**
```
Module-5/
├── devops/
│   ├── pipelines/ ❌ (remove entire folder)
│   ├── .pre-commit-config.yaml ❌ (duplicate)
│   ├── .gitignore ❌ (duplicate)  
│   ├── apply-tf.sh ❌ (DevOps-specific)
│   ├── init-tf.sh ❌ (DevOps-specific)
│   ├── plan-tf.sh ❌ (DevOps-specific)
│   ├── main.tf ✅ (keep - infrastructure)
│   ├── variables.tf ✅ (keep - infrastructure)
│   └── config/ ✅ (keep - environment configs)
└── github/
    ├── .github/workflows/ ✅ (our new workflows)
    ├── .pre-commit-config.yaml ✅ (keep - enhanced)
    ├── .gitignore ✅ (keep - enhanced)
    ├── common-tf.sh ✅ (keep - enhanced)
    └── [all terraform files] ✅ (keep)
```

### **After Cleanup:**
```
Module-5/
├── devops/
│   ├── main.tf ✅ (infrastructure only)
│   ├── variables.tf ✅
│   ├── locals.tf ✅
│   ├── setup.tf ✅
│   ├── backend.tf ✅
│   └── config/ ✅ (dev.tfvars, prd.tfvars)
└── github/
    ├── .github/workflows/ ✅ (complete GitHub Actions)
    ├── .pre-commit-config.yaml ✅ (single source of truth)
    ├── .gitignore ✅ (single source of truth)
    ├── common-tf.sh ✅ (enhanced utilities)
    ├── README.md ✅ (setup guide)
    ├── DEMO-SETUP.md ✅ (demo guide)
    ├── MIGRATION-COVERAGE.md ✅ (coverage analysis)
    └── [all terraform files] ✅ (complete infrastructure)
```

## 🎯 **Benefits of Cleanup**

1. **Reduced Confusion** - Single source of truth for workflows
2. **Cleaner Repository** - No duplicate or obsolete files
3. **Easier Maintenance** - Only GitHub Actions to maintain
4. **Clear Migration** - Obvious that DevOps → GitHub Actions is complete

## ⚠️ **Before You Delete**

1. **Backup** - Consider backing up the pipelines folder if you might need reference later
2. **Team Communication** - Inform team that Azure DevOps pipelines are deprecated
3. **Documentation Update** - Update any documentation referencing the old pipelines

## 🔄 **Alternative: Archive Instead of Delete**

If you prefer to archive instead of delete:

```bash
# Create archive folder
mkdir -p Module-5/archive/devops-migration-$(date +%Y%m%d)

# Move instead of delete
mv Module-5/devops/pipelines/ Module-5/archive/devops-migration-$(date +%Y%m%d)/
mv Module-5/devops/.pre-commit-config.yaml Module-5/archive/devops-migration-$(date +%Y%m%d)/
mv Module-5/devops/*.sh Module-5/archive/devops-migration-$(date +%Y%m%d)/
```

This keeps the files for reference but removes them from active use.
