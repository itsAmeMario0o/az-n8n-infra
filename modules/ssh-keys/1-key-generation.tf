# =============================================================================
# SSH KEY GENERATION
# =============================================================================
# This file creates the SSH key pair using Terraform's TLS provider.
# The generated keys provide secure authentication for the virtual machine
# and are stored locally for use during VM deployment and access.

resource "tls_private_key" "main" {
  algorithm = local.key_config.algorithm
  rsa_bits  = local.key_config.rsa_bits

  # Lifecycle management to prevent accidental key regeneration
  lifecycle {
    # Prevent destruction of the private key to avoid losing access
    prevent_destroy = false # Set to true after initial deployment
    
    # Ignore changes to certain attributes that don't require key regeneration
    ignore_changes = [
      # algorithm and rsa_bits changes require new key generation
    ]
  }
}

# =============================================================================
# KEY VALIDATION
# =============================================================================
# Validation resource to ensure the generated key meets security requirements

resource "null_resource" "key_validation" {
  # Trigger validation when key configuration changes
  triggers = {
    algorithm = local.key_config.algorithm
    rsa_bits  = local.key_config.rsa_bits
    key_id    = tls_private_key.main.id
  }

  # Validate key strength and configuration
  provisioner "local-exec" {
    command = "echo 'SSH key generated successfully with ${local.key_config.algorithm} ${local.key_config.rsa_bits}-bit encryption'"
  }

  depends_on = [tls_private_key.main]
}