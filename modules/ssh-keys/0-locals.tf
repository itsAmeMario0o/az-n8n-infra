# =============================================================================
# SSH KEYS MODULE - LOCAL VALUES
# =============================================================================
# This file contains local values and computed logic specific to SSH key
# generation and management. These locals help maintain consistency and
# provide computed values for key generation and storage.

locals {
  # ---------------------------------------------------------------------------
  # SSH Key File Paths
  # ---------------------------------------------------------------------------
  # Complete file paths for SSH key storage including directory creation
  
  key_paths = {
    directory   = "${path.root}/${var.ssh_config.key_directory}"
    private_key = "${path.root}/${var.ssh_config.key_directory}/${var.ssh_config.private_key_filename}"
    public_key  = "${path.root}/${var.ssh_config.key_directory}/${var.ssh_config.public_key_filename}"
    gitkeep     = "${path.root}/${var.ssh_config.key_directory}/.gitkeep"
  }
  
  # ---------------------------------------------------------------------------
  # SSH Key Configuration
  # ---------------------------------------------------------------------------
  # SSH key generation configuration with validation
  
  key_config = {
    algorithm = var.ssh_config.algorithm
    rsa_bits  = var.ssh_config.rsa_bits
    
    # File permissions (octal format)
    private_key_permissions = "0600"  # Read/write for owner only
    public_key_permissions  = "0644"  # Read for all, write for owner
    directory_permissions   = "0755"  # Standard directory permissions
  }
  
  # ---------------------------------------------------------------------------
  # Key Validation
  # ---------------------------------------------------------------------------
  # Validate that the SSH key configuration is correct
  
  valid_algorithms = ["RSA", "ECDSA", "ED25519"]
  algorithm_valid = contains(local.valid_algorithms, var.ssh_config.algorithm)
  
  valid_rsa_bits = [2048, 3072, 4096]
  rsa_bits_valid = var.ssh_config.algorithm == "RSA" ? contains(local.valid_rsa_bits, var.ssh_config.rsa_bits) : true
}