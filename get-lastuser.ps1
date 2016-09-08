Function Get-LastUser( $Computer )

{
   dir "\\$Computer\c$\documents and settings" ntuser.dat -rec -force | sort lastwritetime -desc | select lastwritetime,directory 
}
 
#-----------------------------------------------------------------------------------------------------------------------------------------------

Get-VMMServer "vbas0053" | Out-Null

get-vm | where { ( $_.status -eq "Running" ) -and ( $_.hostname -eq "vbvs0002.vbgov.com" ) }| foreach { 

	$length = 0
    $length = ( $_.name ).indexof( " " ) 
    if ( $length -le 0 ) { $length = ($_.name).length }
    $strComputer = ( $_.name ).substring(0,$length)
  
   
	get-lastuser $strComputer
	
}




