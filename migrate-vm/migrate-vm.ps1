function Migrate-VM( $ToPlatform, $VM )
#prepares and migrates a VM from Virtual Server to Hyper-V and vise-versa.

{
    If ( $ToPlatform.tolower() -eq 'hyper-v' ) {
	        #Remove VM Additions
			#Move VHD to Hyper-V server
			#Create new VM with copied VHD
			#Start  ( possibly need to install integrated services )
		}
		else if ( $ToPlatform.tolower() -eq 'virtualserver' ) {
		        #
			}
			Else {
			    "$ToPlatform is not a valid ToPlatform"
	}
}