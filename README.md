# SQL Server in Azure VM Deployment Script

This PowerShell script automates the deployment of a SQL Server instance on an Azure Virtual Machine.

## Overview

The script performs the following tasks:
1. Configures essential variables for resource deployment
2. Establishes virtual network and subnet infrastructure
3. Allocates a public IP address for VM accessibility
4. Implements network security group with SQL and RDP access rules
5. Creates and configures network interface for VM connectivity
6. Deploys a virtual machine with SQL Server installation
7. Provides guidance for establishing remote desktop connection
![Architecture Diagram](/Resource-Visualizer.png)
## Prerequisites

- Azure PowerShell module installed
- Azure subscription and appropriate permissions
- PowerShell 5.1 or higher

## Configuration Details

- **Resource Group**: rg_eastus_hub
- **Location**: East US
- **Virtual Network**: 10.0.0.0/16
- **Subnet**: 10.0.0.0/24
- **VM Size**: Standard_B2ms
- **OS Disk Type**: StandardSSD_LRS
- **SQL Server Image**: SQL Server 2022 on Windows Server 2022

## Security

The script configures the following inbound rules:
- RDP access (port 3389)
- SQL Server access (port 1433)

**Note**: Before running in production, consider restricting source IP addresses for security.

## Usage

1. Review and modify the variables at the beginning of the script as needed
2. Replace `<YourStrongPassword123!>` with a secure password
3. Run the script in PowerShell with Azure authentication

```powershell
# Login to Azure first
Connect-AzAccount

# Then run the script
.\sql.ps1
```

## Post-Deployment

After deployment, you can connect to the SQL Server VM using:
- Remote Desktop Protocol (RDP) to the VM's public IP address
- SQL Server Management Studio using the VM's public IP address and port 1433