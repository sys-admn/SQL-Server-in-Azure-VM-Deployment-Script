#Task 1: Configuring Essential Variables for Resource Deployment 
$resourceGroupName = "rg_eastus_hub"
$location = "EastUS"
#Task 2: Establish Virtual Network and Subnet Infrastructure 
$virtualNetworkName = "myVnet"
$subnetName = "mySubnet"
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $virtualNetworkName -AddressPrefix "10.0.0.0/16"
$subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
$subnetId = ($vnet.Subnets | Where-Object { $_.Name -eq $subnetName }).Id  
$vnet | Set-AzVirtualNetwork
#Task 3: Allocate a Public IP Address for VM Accessibility 
$publicIpName = "myPublicIP"
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name $publicIpName -AllocationMethod Static

#Task 4: Implement Network Security Group with SQL and RDP Access Rules 
$nsgName = "myNetworkSecurityGroup" 
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $nsgName

# Define RDP rule

$nsgRuleRdp = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" `
    -Protocol Tcp -Direction Inbound -Priority 1000 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389 `
    -Access Allow

# Define SQL Server rule

$nsgRuleSql = New-AzNetworkSecurityRuleConfig -Name "Allow-SQL" `
    -Protocol Tcp -Direction Inbound -Priority 1001 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 1433 `
    -Access Allow

$nsg.SecurityRules.Add($nsgRuleRdp)
$nsg.SecurityRules.Add($nsgRuleSql)

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg

#Task 5: Create and Configure Network Interface for VM Connectivity 
$nicName = "myNIC"  
$subnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName | Get-AzVirtualNetworkSubnetConfig -Name $subnetName
$subnetId = $subnet.Id
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnetId -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id


#Task 6: Deploy Virtual Machine with SQL Server Installation.
$vmName = "mySqlVM"
$vmSize = "Standard_B2ms"
$osDiskType = "StandardSSD_LRS"
$adminUsername = "localadmin"
$adminPassword = ConvertTo-SecureString "<YourStrongPassword123!>" -AsPlainText -Force


$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential (New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword))
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftSQLServer" -Offer "sql2022-ws2022" -Skus "SQLDEV-GEN2" -Version "latest"
$vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -Disable
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -Name "${vmName}_OSDisk" -StorageAccountType $osDiskType -CreateOption FromImage

New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

#Task 7: Establish Remote Desktop Connection to the VM.  