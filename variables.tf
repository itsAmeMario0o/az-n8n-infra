variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "n8n"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "os_disk_type" {
  description = "OS disk type"
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 64
}

variable "enable_dynamic_ip_security" {
  description = "Enable dynamic IP security"
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr_blocks" {
  description = "Allowed SSH CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_web_cidr_blocks" {
  description = "Allowed web CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}