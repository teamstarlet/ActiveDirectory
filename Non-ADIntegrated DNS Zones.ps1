#_______________________________________________________________________#
#																		#
#	Powershell script to check for non AD-Intergrated DNS Zones on		#
#	all domain controllers contained within a forest...					#
#																		#
#	Author:		Aidan McCarthy											#
#	Date:		November 15, 2013										#
#	Version:	1.0														#
#_______________________________________________________________________#

#--	Error Preferences..	--#
#-------------------------#

	$ErrorActionPreference = "SilentlyContinue"

#--	Start Logging	--#
#---------------------#

	Start-Transcript -Path Non_AD-Integrated_DNS_Zones.txt -Append

#--	 List all DC's in target forest...	--#
#-----------------------------------------#

	$myForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
	$dc_list = $myforest.Sites | ForEach-Object { $_.Servers } | Select-Object Name


#--	Search for zones...	--#
#-------------------------#
	ForEach ($dc in $dc_list) {
	    $DCName = $dc.Name
		Write-Host ======================
		Write-Host $dc.Name
		Get-WMIObject -ComputerName $DCName -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -Filter "ZoneType = 4" `
		| Where-Object {$_.DsIntegrated -ne "True"} `
		| Select-Object -Property @{n='Name';e={$_.ContainerName}}, @{n='DsIntegrated';e={$_.DsIntegrated}}, @{n='MasterServers';e={([string]::Join(',', $_.MasterServers))}}, @{n='AllowUpdate';e={$_.AllowUpdate}} `
		| Format-Table -AutoSize
		Write-Host
		Write-Host
		}

#--	Stop Logging	--#
#---------------------#

	Stop-Transcript