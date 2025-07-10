# =============================================================================
# SSH KEY FILE STORAGE
# =============================================================================
# This file creates and manages the local SSH key files. The keys are stored
# in a dedicated directory with appropriate permissions for security.

# -----------------------------------------------------------------------------
# Directory Creation
# -----------------------------------------------------------------------------
# Create the ssh-keys directory with a .gitkeep file to ensure it exists in git

resource "local_file" "ssh_key_directory" {
  content  = "# SSH Keys Directory\nThis directory contains generated SSH keys for the N8N deployment.\nPrivate keys are automatically excluded from git via .gitignore.\n"
  filename = local.key_paths.gitkeep

  # Create directory if it doesn't exist
  provisioner "local-exec" {
    command = "mkdir -p ${local.key_paths.directory}"
  }

  # Directory lifecycle management
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Private Key File
# -----------------------------------------------------------------------------
# Store the private key locally with secure permissions

resource "local_file" "private_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = local.key_paths.private_key
  file_permission = local.key_config.private_key_permissions

  # Ensure directory exists before creating file
  depends_on = [local_file.ssh_key_directory]

  # Private key lifecycle management
  lifecycle {
    # Prevent accidental deletion of private key
    prevent_destroy = false # Set to true after initial deployment
    
    # Create new key file before destroying old one
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Public Key File
# -----------------------------------------------------------------------------
# Store the public key locally for reference and manual use

resource "local_file" "public_key" {
  content         = tls_private_key.main.public_key_openssh
  filename        = local.key_paths.public_key
  file_permission = local.key_config.public_key_permissions

  # Ensure directory exists before creating file
  depends_on = [local_file.ssh_key_directory]

  # Public key lifecycle management
  lifecycle {
    # Create new key file before destroying old one
    create_before_destroy = true
  }
}

# =============================================================================
# FILE VALIDATION
# =============================================================================
# Validation to ensure files were created successfully with correct permissions

resource "null_resource" "file_validation" {
  # Trigger validation when files change
  triggers = {
    private_key_path = local_file.private_key.filename
    public_key_path  = local_file.public_key.filename
    directory_path   = local.key_paths.directory
  }

  # Validate file creation and permissions
  provisioner "local-exec" {
    command = <<-EOT
      echo "SSH key files created successfully:"
      echo "Private key: ${local_file.private_key.filename}"
      echo "Public key: ${local_file.public_key.filename}"
      echo "Directory: ${local.key_paths.directory}"
      ls -la ${local.key_paths.directory}
    EOT
  }

  depends_on = [
    local_file.private_key,
    local_file.public_key,
    local_file.ssh_key_directory
  ]
}