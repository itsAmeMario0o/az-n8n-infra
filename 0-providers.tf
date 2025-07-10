# =============================================================================
# TERRAFORM CONFIGURATION
# =============================================================================
# This file configures the required Terraform version and providers needed
# for deploying infrastructure on Azure. It includes providers for Azure
# resource management, random ID generation, TLS key creation, and local file
# operations for SSH key management.

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# AZURE PROVIDER CONFIGURATION
# =============================================================================
# Configure the Azure Provider with specific feature flags for resource
# management behavior during creation and deletion operations.

provider "azurerm" {
  features {
    # Allow deletion of resource groups that contain resources
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    # Configure VM deletion behavior
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}