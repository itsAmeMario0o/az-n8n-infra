# =============================================================================
# STORAGE ACCOUNT
# =============================================================================
# This file creates the storage account used for VM boot diagnostics.
# Boot diagnostics provide console output and screenshots for troubleshooting
# VM boot issues and monitoring VM health.

# Random suffix for unique storage account naming
resource "random_id" "storage_suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "main" {
  name                     = local.storage_config.name
  resource_group_name      = var.resource_group_name
  location                = var.location
  account_tier            = local.storage_config.account_tier
  account_replication_type = local.storage_config.account_replication_type
  account_kind            = local.storage_config.account_kind

  # Security configuration
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  
  # Network access rules (restrict to Azure services by default)
  network_rules {
    default_action = "Allow"  # Consider restricting to "Deny" for production
    bypass         = ["AzureServices"]
  }

  # Apply common tags plus storage-specific tags
  tags = merge(var.common_tags, {
    Component   = "Compute"
    Type        = "Storage Account"
    Description = "Storage account for VM boot diagnostics"
    Purpose     = "Boot Diagnostics"
  })

  # Lifecycle management for storage account
  lifecycle {
    prevent_destroy = false # Set to true for production environments
    
    # Ignore changes to access tier as it may be managed by policies
    ignore_changes = [
      access_tier
    ]
  }
}