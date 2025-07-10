# =============================================================================
# AZURE RESOURCE GROUP
# =============================================================================
# This file creates the main resource group that will contain all resources
# for the N8N deployment. The resource group serves as a logical container
# and provides a scope for applying policies, permissions, and lifecycle management.

resource "azurerm_resource_group" "n8n" {
  name     = "${local.resource_prefix}-rg"
  location = var.location

  # Apply common tags for resource organization and cost tracking
  tags = merge(local.common_tags, {
    Description = "Resource group for platform deployment"
  })

  # Lifecycle management to prevent accidental deletion in production
  lifecycle {
    prevent_destroy = false # Set to true for production environments
  }
}