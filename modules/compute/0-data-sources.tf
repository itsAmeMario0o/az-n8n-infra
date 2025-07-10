# =============================================================================
# COMPUTE MODULE - DATA SOURCES
# =============================================================================
# This file contains data sources specific to compute resources that fetch
# information about VM images, sizes, and other compute-related configurations
# from Azure APIs.

# -----------------------------------------------------------------------------
# Ubuntu Image Information
# -----------------------------------------------------------------------------
# Get the latest Ubuntu 22.04 LTS image information to ensure we're using
# the most recent and secure image version available.

data "azurerm_platform_image" "ubuntu" {
  location  = var.location
  publisher = var.vm_config.source_image.publisher
  offer     = var.vm_config.source_image.offer
  sku       = var.vm_config.source_image.sku
}

# -----------------------------------------------------------------------------
# Available VM Sizes
# -----------------------------------------------------------------------------
# Get information about available VM sizes in the specified location to
# validate that the requested VM size is available in the target region.

data "azurerm_virtual_machine_sizes" "available" {
  location = var.location
}