# Storage Account outputs (using for_each) - shows different configurations
output "storage_accounts_for_each" {
  description = "Map of storage account names and their configurations (for_each example)"
  value = {
    for key, sa in module.storage_account_for_each : key => {
      name = sa.storage_account_name
      # Shows how for_each allows different configurations
      purpose = key == "logs" ? "Log storage (Standard/LRS)" : "Data storage (Premium/ZRS)"
    }
  }
}

# Key Vault outputs (using count) - shows identical configurations
output "key_vaults_count" {
  description = "List of Key Vault names (count example) - all identical"
  value = [
    for i, kv in module.key_vault_count : {
      index = i
      name  = kv.key_vault_name
      note  = "All Key Vaults have identical configuration (limitation of count)"
    }
  ]
}

# Demonstration of the difference between count and for_each
output "count_vs_for_each_explanation" {
  description = "Explanation of the differences between count and for_each"
  value = {
    for_each_advantages = {
      "Meaningful keys" = "Access using: module.storage_account_for_each['logs'], module.storage_account_for_each['data']"
      "Different configs" = "Each storage account can have different tier/replication based on purpose"
      "Stable references" = "Adding/removing items doesn't affect other resources"
    }
    count_limitations = {
      "Numeric indexes" = "Access using: module.key_vault_count[0], module.key_vault_count[1]"
      "Identical configs" = "All Key Vaults have the same configuration (hard to vary)"
      "Index dependency" = "Removing middle item causes recreation of subsequent items"
    }
    demonstration = {
      "logs_storage" = "Standard tier, LRS replication (cheaper for logs)"
      "data_storage" = "Premium tier, ZRS replication (better for important data)"
      "all_keyvaults" = "Identical configuration (can't easily differentiate by purpose with count)"
    }
  }
}
