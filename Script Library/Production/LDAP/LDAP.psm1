#--------------------------------------------------------
# LDAP.psm1
#
# Functions for LDAP via powershell
#--------------------------------------------------------

Function Get-LDAPQuery {

	[CmdletBinding()] 
    PARAM ( 
        [Parameter(Position=1)] $Query
    ) 
	
	[ADSI]$Query
  
} 


