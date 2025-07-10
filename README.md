# N8N Azure Terraform Deployment

A production-ready, enterprise-grade modular Terraform configuration for deploying N8N automation platform on Microsoft Azure. This project follows best practices for infrastructure as code, security, and operational excellence.

## 🏗️ Project Hierarchy

```
n8n-azure-terraform/
├── 📁 Root Configuration Files (Ordered by Creation Sequence)
│   ├── 0-provider.tf              # Terraform & Azure provider configuration
│   ├── 1-data-sources.tf          # External data sources (IP discovery, Azure client)
│   ├── 2-locals.tf                # Complex logic & computed values
│   ├── 3-resource-group.tf        # Main resource group creation
│   ├── 4-modules.tf               # Module instantiation & dependencies
│   ├── 5-outputs.tf               # Organized outputs by functional area
│   ├── variables.tf               # Root module input variables
│   ├── terraform.tfvars.example   # Example configuration file
│   └── .gitignore                 # Git ignore rules (excludes sensitive files)
│
├── 📁 modules/                    # Reusable Terraform modules
│   ├── 📁 networking/             # Network infrastructure module
│   │   ├── 0-data-sources.tf      # Network-specific data sources
│   │   ├── 1-locals.tf            # Network local values & validation
│   │   ├── 2-virtual-network.tf   # Azure VNet creation
│   │   ├── 3-subnet.tf            # Subnet configuration
│   │   ├── 4-network-interface.tf # Network interface for VM
│   │   ├── variables.tf           # Module input variables
│   │   └── outputs.tf             # Module output values
│   │
│   ├── 📁 security/               # Security configuration module  
│   │   ├── 0-data-sources.tf      # Security-specific data sources
│   │   ├── 1-locals.tf            # Security local values & processing
│   │   ├── 2-network-security-group.tf # NSG & dynamic rules creation
│   │   ├── 3-security-associations.tf  # NSG to NIC associations
│   │   ├── variables.tf           # Module input variables
│   │   └── outputs.tf             # Module output values
│   │
│   ├── 📁 compute/                # Virtual machine & compute module
│   │   ├── 0-data-sources.tf      # VM image & compute data sources
│   │   ├── 1-locals.tf            # Compute local values & config
│   │   ├── 2-public-ip.tf         # Public IP address creation
│   │   ├── 3-storage-account.tf   # Storage for boot diagnostics
│   │   ├── 4-virtual-machine.tf   # Main VM resource creation
│   │   ├── 5-vm-extensions.tf     # VM extensions for N8N setup
│   │   ├── variables.tf           # Module input variables
│   │   └── outputs.tf             # Module output values
│   │
│   └── 📁 ssh-keys/               # SSH key management module
│       ├── 0-locals.tf            # SSH key local values & paths
│       ├── 1-key-generation.tf    # TLS private key generation
│       ├── 2-key-files.tf         # Local file storage for keys
│       ├── variables.tf           # Module input variables
│       └── outputs.tf             # Module output values
│
├── 📁 ssh-keys/                   # Generated SSH keys (git ignored)
│   ├── .gitkeep                   # Ensures directory exists
│   ├── n8n-dev-private-key.pem    # Generated private key (git ignored)
│   └── n8n-dev-public-key.pub     # Generated public key (git ignored)
│
└── 📄 README.md                   # This documentation file
```

## 🎯 Design Philosophy

### **1. Modular Architecture**
- **Separation of Concerns**: Each module handles a specific infrastructure domain
- **Reusability**: Modules can be used across different environments and projects  
- **Maintainability**: Clear boundaries make debugging and updates straightforward
- **Scalability**: Easy to add new modules or extend existing functionality

### **2. Enterprise Best Practices**
- **Numbered File Convention**: Files numbered by creation order (0-9) for clarity
- **Explicit Dependencies**: Clear dependency chains prevent circular references
- **Resource Lifecycle Management**: Proper creation/destruction ordering
- **Input Validation**: Comprehensive validation rules with helpful error messages

### **3. Security-First Design**
- **Dynamic IP Discovery**: Automatically restricts access to deployer's public IP
- **SSH Key Automation**: Generates and manages SSH keys with proper permissions
- **Network Isolation**: Dedicated VNet with controlled ingress/egress
- **Least Privilege**: Minimal required ports and access controls

### **4. Infrastructure as Code Principles**
- **Declarative Configuration**: Infrastructure defined as immutable code
- **Version Control**: All changes tracked and reproducible
- **Documentation as Code**: Comprehensive inline documentation
- **State Management**: Local state for simplicity, easily migrated to remote

### **5. Operational Excellence**
- **Comprehensive Outputs**: All necessary information for operations
- **Tagged Resources**: Consistent tagging for cost tracking and management
- **Boot Diagnostics**: VM troubleshooting capabilities built-in
- **Extension Automation**: N8N repository automatically cloned and prepared

## 🚀 Quick Start Guide

### **Prerequisites**
```bash
# Required tools
- Azure CLI (authenticated)
- Terraform >= 1.0
- Git (for repository operations)

# Verify installations
az --version
terraform --version
git --version

# Azure authentication
az login
az account show  # Verify correct subscription
```

### **Deployment Steps**

#### **1. Clone and Configure**
```bash
# Create configuration from example
cp terraform.tfvars.example terraform.tfvars

# Edit configuration (see Configuration section below)
vim terraform.tfvars  # or your preferred editor
```

#### **2. Deploy Infrastructure**
```bash
# Initialize Terraform (downloads providers and modules)
terraform init

# Review deployment plan
terraform plan

# Deploy infrastructure
terraform apply
# Type 'yes' when prompted to confirm deployment
```

#### **3. Access and Complete Setup**
```bash
# Get connection information (from terraform output)
terraform output

# SSH to the VM using generated key
ssh -i ssh-keys/n8n-dev-private-key.pem azureuser@<PUBLIC_IP>

# Navigate to installer directory
cd /opt/n8n-installer

# Review installation options
cat README.md

# Complete N8N installation
sudo bash ./scripts/install.sh
```

#### **4. Access N8N Web Interface**
```bash
# After installation completes, access N8N at:
https://n8n.<YOUR_DOMAIN>       # HTTPS (if SSL configured)
```

## ⚙️ Configuration Reference

### **Core Configuration (terraform.tfvars)**
```hcl
# Project & Environment
project_name = "n8n"                    # Project identifier
environment  = "dev"                    # Environment (dev/staging/prod)
location     = "East US"                # Azure region

# Virtual Machine Configuration  
vm_size         = "Standard_B2s"        # VM size (see sizing guide below)
admin_username  = "azureuser"           # VM admin username
os_disk_type    = "Standard_LRS"        # Disk type (Standard_LRS/Premium_LRS)
os_disk_size_gb = 30                    # OS disk size in GB

# Security Configuration
enable_dynamic_ip_security = true       # Auto-discover public IP (recommended)
# If dynamic IP disabled, manually specify:
# allowed_ssh_cidr_blocks = ["YOUR_IP/32"]
# allowed_web_cidr_blocks = ["YOUR_IP/32"]
```

### **Advanced Configuration**
```hcl
# Network Customization
custom_dns_servers = ["8.8.8.8", "8.8.4.4"]  # Custom DNS servers

# Resource Tagging
additional_tags = {
  "CostCenter" = "IT"
  "Owner"      = "Platform Team"
  "Compliance" = "SOC2"
}
```

## 🔧 Module Architecture Deep Dive

### **1. SSH Keys Module (`modules/ssh-keys/`)**
**Purpose**: Automated SSH key generation and management
- Generates RSA 4096-bit key pairs using TLS provider
- Stores keys locally with appropriate permissions (0600/0644)
- Provides key paths and metadata for other modules
- Automatically excluded from Git via .gitignore

### **2. Networking Module (`modules/networking/`)**
**Purpose**: Network infrastructure foundation
- Creates isolated Azure VNet (10.0.0.0/16)
- Configures subnet for VM deployment (10.0.1.0/24)
- Creates network interface with dynamic private IP
- DNS configuration support for custom resolvers

### **3. Security Module (`modules/security/`)**
**Purpose**: Network security and access control
- Dynamic security rule creation using `for_each`
- Supports SSH (22), HTTP (80), and HTTPS (443) access
- CIDR-based access control with dynamic IP discovery
- NSG association with network interfaces

### **4. Compute Module (`modules/compute/`)**
**Purpose**: Virtual machine and compute resources
- Ubuntu 22.04 LTS virtual machine
- Storage account for boot diagnostics
- Public IP with DNS label for external access
- VM extension for automated N8N repository setup

## 🔒 Security Considerations

### **Network Security**
- **NSG Rules**: Only essential ports (22, 80, 443) are opened
- **Dynamic IP Restriction**: Access automatically limited to deployer's IP
- **VNet Isolation**: Dedicated virtual network with controlled ingress/egress
- **No Password Authentication**: SSH key-only access to VM

### **Key Management**
- **Automatic Generation**: SSH keys generated with strong encryption (RSA 4096)
- **Secure Storage**: Private keys stored with 0600 permissions
- **Git Exclusion**: Private keys automatically excluded from version control
- **Lifecycle Management**: Keys removed when infrastructure is destroyed

### **Azure Security**
- **Boot Diagnostics**: Enabled for troubleshooting with dedicated storage
- **Resource Tagging**: Comprehensive tagging for compliance and tracking
- **Least Privilege**: Minimal required Azure permissions
- **Storage Encryption**: Default encryption for all storage resources

## 🚨 Important Notes

### **Cost Management**
- **Auto-Shutdown**: Enable for development environments
- **VM Sizing**: Choose appropriate size for workload
- **Storage Types**: Standard_LRS for dev, Premium_LRS for production
- **Resource Cleanup**: Always run `terraform destroy` when done

### **Production Considerations**
- **Remote State**: Configure Azure Storage backend for team collaboration
- **Resource Locks**: Enable resource locks to prevent accidental deletion
- **Backup Strategy**: Enable VM backup and configure retention policies
- **Monitoring**: Enable Azure Monitor for operational visibility
- **SSL/TLS**: Configure proper certificates for HTTPS access

### **Troubleshooting Common Issues**
1. **SSH Access Denied**: Check NSG rules and verify key permissions
2. **N8N Not Accessible**: Verify VM extension completed successfully
3. **Terraform Errors**: Run `terraform validate` and check Azure authentication
4. **Circular Dependencies**: Follow module execution order in error messages

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

---

**Built with ❤️ by a Cacanaka**