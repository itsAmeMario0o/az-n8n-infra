# =============================================================================
# SSH KEYS MODULE - VARIABLES
# =============================================================================
# This file defines input variables for the SSH keys module. These variables
# allow the module to be configured from the root module while maintaining
# flexibility and reusability across different environments.

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "ssh_config" {
  description = "SSH key configuration including algorithm, key size, and file naming"
  type = object({
    algorithm            = string
    rsa_bits            = number
    private_key_filename = string
    public_key_filename  = string
    key_directory       = string
  })
  
  validation {
    condition = contains(["RSA", "ECDSA", "ED25519"], var.ssh_config.algorithm)
    error_message = "SSH algorithm must be RSA, ECDSA, or ED25519."
  }
  
  validation {
    condition = var.ssh_config.algorithm != "RSA" || contains([2048, 3072, 4096], var.ssh_config.rsa_bits)
    error_message = "RSA key size must be 2048, 3072, or 4096 bits."
  }
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._-]+$", var.ssh_config.private_key_filename))
    error_message = "Private key filename must contain only alphanumeric characters, dots, underscores, and hyphens."
  }
  
  validation {
    condition = can(regex("^[a-zA-Z0-9._-]+$", var.ssh_config.public_key_filename))
    error_message = "Public key filename must contain only alphanumeric characters, dots, underscores, and hyphens."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to SSH key resources (for metadata purposes)"
  type        = map(string)
  default     = {}
}