Option Explicit
On Error Resume Next

Const ForAppending = 8
Const ADS_SCOPE_SUBTREE = 5

'Declarations

Dim BiasKey 'Active Time Bias from Registry
Dim Bias 'Time Bias

Dim objConnection 'ADO conection
Dim objCommand 'ADO command
Dim objRecordSet 'Object to hold attributes from AD
Dim oWshShell 'Windows shell script 
Dim objFSO 'Scripting File System 
Dim objFile 'Open text file
Dim objLastLogon 'Last Logon Long Integer attribute
Dim strFilePath 'Path to current directory
Dim strComputer 'PC Name
Dim strComputerName 'Output computer name string
Dim strTimeSTMP 'Modify Time Stamp Attribute
Dim strADSPath 'Active Directory container for computer account
Dim strLogon 'String to hold interpreted last logon value
Dim strLogonTime 'Last Logon Time output string
Dim strDate 'Last Logon Date attribute
Dim strValidate
Dim CNameArray(1)
Dim CTimeArray(1)
Dim anzahl 'numbers of computers in the AD

Set oWshShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strFilePath = objFSO.GetAbsolutePathName(".")
Set objFile = objFSO.OpenTextFile (strFilePath & "\PCNAME-n-DATE.log",ForAppending,True)

' Use a dictionary object to track latest LastLogon for each computer
Set objList = CreateObject("Scripting.Dictionary")
objList.CompareMode = vbtextCompare

Set objConnection = CreateObject("ADODB.Connection")
Set objCommand = CreateObject("ADODB.Command")

' Obtain local Time Zone bias from machine registry.
BiasKey = oWshShell.RegRead("HKLM\System\CurrentControlSet\Control\TimeZoneInformation\ActiveTimeBias")
If UCase(TypeName(BiasKey)) = "LONG" Then
Bias = BiasKey
ElseIf UCase(TypeName(BiasKey)) = "VARIANT()" Then
Bias = 0
For k = 0 To UBound(BiasKey)
Bias = Bias + (BiasKey(k) * 256^k)
Next
End If

objFile.WriteLine "Output File opened at " & Now
objFile.WriteLine "============================================================================="

objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"
Set objCommand.ActiveConnection = objConnection

objCommand.CommandText = "Select Name, ADSPath, lastlogon from 'LDAP://dc=domain,dc=com" & " where objectClass='computer'" 

objCommand.Properties("Page Size") = 2000
objCommand.Properties("Timeout") = 30 
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 
objCommand.Properties("Cache Results") = False 

Set objRecordSet = objCommand.Execute
objRecordSet.MoveFirst

Do Until objRecordSet.EOF
strComputer = objRecordSet.Fields("Name").Value
strADSPath = objRecordSet.Fields("ADSPath").Value
set objLastLogon = objRecordSet.Fields("lastlogon").Value

If err.number <> 0 Then
strlogon = "Not set"
Err.Clear

Else

' Convert the LargeInteger object to a string 
strLogon = Hex(objLastLogon.HighPart) & Hex(objLastLogon.LowPart) 

strDate = #1/1/1601# + (objLastLogon.highpart * 2^32 + objLastLogon.lowpart) /864E9 - Bias / 1440 

End If

' Format computer name string

CNameArray(0) = strComputer
CNameArray(1) = " "
strComputerName = Join(CNameArray)
strComputerName = Left (strComputerName, 18)

' Format Last Logon Time string

CTImeArray(0) = strLogon
CTimeArray(1) = " "
strLogonTime = Join(CTimeArray)
strLogonTime = Left (strLogonTime, 18)

' Output in File

objFile.Write "Computername: " & strComputerName & VbCrLf
objFile.Write " " & strLogonTime & VbCrLf
objFile.Write "last Login: " & strDate & VbCrLf
objFile.WriteLine "AD Path: " & strADSPath
objFile.WriteLine "----------------------" & VbCrLf

objRecordSet.MoveNext
Loop

objFile.WriteLine " End of log file for: " & Now
objFile.WriteBlankLines (0)
objFile.WriteLine "============================================================================="
objFile.WriteBlankLines (0)
objFile.Close