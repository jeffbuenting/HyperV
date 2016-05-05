Dim ObjGlobalSetting
Dim ObjWbem
Dim DominList
Dim I

set ObjWbem = creatobject("wbemscripting.swbemlocator").connectserver(".","root\cimv2")
for each objGlobalSetting in objWbem.ExecQuery( "select * from MSFT_SIPESGlobalRegistrarSetting")
DomainList = objGlobalSetting.UserDomainList
Next

Wscript.echo "Verifying the Value Set for MSFT_SIPESGlobalRegistrarSetting::UserDomainList"
Wscript.echo "--------------------------------------------------------"

I = 1
for each domain in DomainList
wscript.echo "Domain" & I &":"& domain
I = I +1
Next