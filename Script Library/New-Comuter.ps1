#----------------------------------------------------

Function Get-Input( $Question )

{
    $a = new-object -comobject MSScriptControl.ScriptControl
    $a.language = "vbscript"
    $a.addcode("function getInput() getInput = inputbox(`"$Question`",`"$Question`") end function" )
    $b = $a.eval("getInput")

    Return $b

}

#------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------

$Cred = Get-Credential
$NewVM = Get-Input( "Name of the new VM?" )
$Desc = Get-Input ( "Description of the New VM: " )

$NewVM = $NewVM.toupper()
$VMType = $NewVM.substring(2,2)
$VMLevel = $NewVM.substring(4,1)
$VMNum = $NewVM.substring(5)

$NewVM
$VMType
$VMNum

Connect-QADService -Credential $Cred 

$NewOU = $VMType+'0'+$VMNum
New-QADObject -ParentContainer 'OU=Servers,DC=VBGov,DC=com' -Type 'OrganizationalUnit' -Name $NewOU  -Description $Desc

$NewOU = $VMType+'8'+$VMNum
New-QADObject -ParentContainer 'OU=Servers Development,DC=VBGov,DC=com' -Type 'OrganizationalUnit' -Name $NewOU  -Description $Desc

$NewOU = $VMType+'9'+$VMNum
New-QADObject -ParentContainer 'OU=Servers Test,DC=VBGov,DC=com' -Type 'OrganizationalUnit' -Name $NewOU  -Description $Desc



switch ($VMLevel){
	0 { $NewOU = 'OU='+$VMType+'0'+$VMNum+',OU=Servers,DC=VBGov,DC=com'	}
	8 { $NewOU = 'OU='+$VMType+'8'+$VMNum+',OU=Servers Development,DC=VBGov,DC=com' }
	9 { $NewOU = 'OU='+$VMType+'9'+$VMNum+',OU=Servers Test,DC=VBGov,DC=com' }
}

$NewOU

New-QADObject -ParentContainer $NewOU -Type 'Computer' -Name $NewVM