# =============================================================================
# SSH KEYS MODULE - OUTPUTS
# =============================================================================
# This file defines output values from the SSH keys module that can be
# consumed by other modules or the root configuration. Outputs provide
# essential information about generated SSH keys and their storage locations.

# -----------------------------------------------------------------------------
# SSH Key Content Outputs
# -----------------------------------------------------------------------------

output "private_key_pem" {
  description = "Private key in PEM format"
  value       = tls_private_key.main.private_key_pem
  sensitive   = true
}

output "public_key_openssh" {
  description = "Public key in OpenSSH format"
  value       = tls_private_key.main.public_key_openssh
}

output "public_key_fingerprint" {
  description = "MD5 fingerprint of the public key"
  value       = tls_private_key.main.public_key_fingerprint_md5
}

output "public_key_fingerprint_sha256" {
  description = "SHA256 fingerprint of the public key"
  value       = tls_private_key.main.public_key_fingerprint_sha256
}

# -----------------------------------------------------------------------------
# File Path Outputs
# -----------------------------------------------------------------------------

output "private_key_path" {
  description = "Local file path to the private key"
  value       = local_file.private_key.filename
}

output "public_key_path" {
  description = "Local file path to the public key"
  value       = local_file.public_key.filename
}

output "ssh_directory_path" {
  description = "Local directory path containing SSH keys"
  value       = local.key_paths.directory
}

# -----------------------------------------------------------------------------
# Key Configuration Outputs
# -----------------------------------------------------------------------------

output "key_algorithm" {
  description = "Algorithm used for key generation"
  value       = var.ssh_config.algorithm
}

output "key_size" {
  description = "Key size in bits (for RSA keys)"
  value       = var.ssh_config.rsa_bits
}

# -----------------------------------------------------------------------------
# Key Management Outputs
# -----------------------------------------------------------------------------

output "key_configuration" {
  description = "Complete SSH key configuration and file information"
  value = {
    algorithm = var.ssh_config.algorithm
    key_size  = var.ssh_config.rsa_bits
    
    files = {
      private_key_path = local_file.private_key.filename
      public_key_path  = local_file.public_key.filename
      directory_path   = local.key_paths.directory
    }
    
    fingerprints = {
      md5    = tls_private_key.main.public_key_fingerprint_md5
      sha256 = tls_private_key.main.public_key_fingerprint_sha256
    }
    
    permissions = {
      private_key = local.key_config.private_key_permissions
      public_key  = local.key_config.public_key_permissions
    }
  }
}

# -----------------------------------------------------------------------------
# Usage Information Outputs
# -----------------------------------------------------------------------------

output "usage_instructions" {
  description = "Instructions for using the generated SSH keys"
  value = {
    ssh_command = "ssh -i ${local_file.private_key.filename} <username>@<hostname>"
    scp_command = "scp -i ${local_file.private_key.filename} <local_file> <username>@<hostname>:<remote_path>"
    
    security_notes = [
      "Private key file permissions: ${local.key_config.private_key_permissions}",
      "Keep private key secure and never share it",
      "Public key can be safely shared and is used for VM configuration",
      "Keys are automatically excluded from git via .gitignore"
    ]
  }
}