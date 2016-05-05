import-module "\\vbas0080\VMMLibrary\Script Library\Production\LDAP\LDAP.psm1"

$LDAPQuery = "<LDAP://vbdc1001.vbgov.com/CN=Schema,CN=Configuration,DC=vbgov,DC=com>;(&(objectClass=dMD)(fSMORoleOwner=*));fSMORoleOwner;Subtree"

Get-LDAPQuery $LDAPQuery