# -------------------------------------------------------------
# Add-ClusterResource.ps1
# Mounts ISCSI volumes on each node in a cluster
#--------------------------------------------------------------

Import-Module FailoverClusters



#--------- Get Cluster Name
$Cluster = Read-Host "Which cluster do you want to place the VM on?"

$ISCSINumber = Read-Host "What is the ISCSI Number after iqn.2003-10.com.lefhandnetworks:covb2:"
$VMName = Read-Host "What is the VM Name? "

$ISCIVol = "iqn.2003-10.com.lefthandnetworks:covb2:"+$ISCSINumber+":"+$VMName

#--------- Get Node names

$HVCluster = Get-ClusterNode -Cluster $Cluster

# -- Do this on all Nodes

foreach ( $Node in $HVCluster ) {

    $session = New-PSSession -ComputerName $Node.name

	$ChapName = $Node.name
	$ChapPWD = ("1$Node!target")
	$ChapPWD = $ChapPWD.tolower()
	$ISCIVol 
	
	#--------- Connect to ISCSI Target
	Invoke-Command -Session $session -scriptblock { param ($IV,$CN,$CP) iscsicli qlogintarget $IV $CN $CP } -ArgumentList $ISCIVol,$ChapName,$ChapPWD
	#--------- Make Persistent
	Invoke-Command -Session $session -ScriptBlock { param ($IV,$CN,$CP) iscsicli persistentlogintarget $IV T * * * * * * * * * * * $CN $CP 1 * 0  } -ArgumentList $ISCIVol,$ChapName,$ChapPWD
	
    Remove-PSSession -Session $Session
	
	$NodeName = $Node.Name
}

$session = New-PSSession -ComputerName $NodeName
#----- Bring online and Initialize
Copy-Item "\\vbas0080\VMMLibrary\Script Library\Production\Add-ClusterResource\ListDisks.txt" "\\$Nodename\c$"
Invoke-Command -Session $session -ScriptBlock { diskpart /s "c:\listdisks.txt"  }
$DiskNum = Read-Host "Which disk do you want to bring online? "
$File = New-Item -ItemType file "\\$NodeName\c$\SelectDisk.txt"
Add-Content $File "Select Disk $DiskNum"
Add-Content $File "List Disk"
Invoke-Command -Session $session -ScriptBlock { diskpart /s "c:\SelectDisk.txt"  }
$YN = "N"
$YN = Read-Host "Continue Y/N ? "
if ( $YN -ne "Y" ) {
 	#Quit
	Write-Host "Exiting Script"
	
}
Add-Content $File "Online Disk"
Add-Content $File "List Disk"
Invoke-Command -Session $session -ScriptBlock { diskpart /s "c:\SelectDisk.txt"  }
$YN = "N"
$YN = Read-Host "Continue Y/N ? "
if ( $YN -ne "Y" ) {
 	#Quit
}
Remove-Item "\\$NodeName\c$\SelectDisk.txt"
$File = New-Item -ItemType file "\\$NodeName\c$\SelectDisk.txt"
Add-Content $File "Select Disk $DiskNum"
Add-Content $File "List Disk"
Add-Content $File "Attributes disk clear readonly"
add-content $File "convert gpt"
Add-Content $File "List Disk"
Add-Content $File "Create partition primary"
Add-content $File "List Volume"
Invoke-Command -Session $session -ScriptBlock { diskpart /s "c:\SelectDisk.txt"  }
$VOLNum = Read-Host "Which Volume do you want to format? "

# ----- Format LUN
Remove-Item "\\$NodeName\c$\SelectDisk.txt"
$File = New-Item -ItemType file "\\$NodeName\c$\SelectDisk.txt"
Add-Content $File "Select Disk $DiskNum"
Add-Content $File "List Disk"
Add-Content $File "Attributes disk clear readonly"
Add-Content $File "select Volume $VolNum"
Add-Content $File "List Volume"
Invoke-Command -Session $session -ScriptBlock { diskpart /s "c:\SelectDisk.txt"  }
$YN = "N"
$YN = Read-Host "Continue Y/N ? "
if ( $YN -ne "Y" ) {
 	#Quit
}
Add-Content $File "format fs=ntfs label='$VMName' quick"

#----- Add Storage to cluster and Add storage to CSV
get-clusteravailabledisk $Cluster | Add-ClusterDisk $Cluster | Add-ClusterSharedVolume $Cluster


# ----- Clean up
Remove-Item "\\$NodeName\c$\SelectDisk.txt"
Remove-Item "\\$NodeName\c$\ListDisks.txt"
Remove-PSSession -Session $Session