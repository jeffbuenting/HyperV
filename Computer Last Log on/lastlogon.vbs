' LastLogon.vbs
' VBScript program to determine when each computer in the domain lastlogged
' on.
'
' ----------------------------------------------------------------------
' Copyright (c) 2002 Richard L. Mueller
' Version 1.2 - January 23, 2003
' Modified - March 4, 2003 Kevin Buley
' 	- Added output lines to show that the script is processing (DC name, # x of y)
'	- Modified output to be pipe-delimited "|" for import into spreadsheet
'
' Because the LastLogon attribute is not replicated, every Domain Controller
' in the domain must be queried to find the latest LastLogon date for each
' computer. The lastest date found is kept in a dictionary object. The
' program first uses ADO to search the domain for all Domain Controllers.
' The AdsPath of each Domain Controller is saved in an array. Then, for each
' Domain Controller, ADO is used to search the copy of Active Directory on
' that Domain Controller for all computer objects and return the LastLogon
' attribute. The LastLogon attribute is a 64-bit number representing the
' number of 100 nanosecond intervals since 12:00 am January 1, 1601. This
' value is converted to a date. The last logon date is in UTC (Coordinated
' Univeral Time). It must be adjusted by the Time Zone bias in the machine
' registry to convert to local time.
'
' You have a royalty-free right to use, modify, reproduce, and distribute
' this script file in any way you find useful, provided that you agree
' that the copyright owner above has no warranty, obligations, or liability
' for such use.

Option Explicit

Const ForAppending 	= 8

Dim k, sDCs()

Dim BiasKey		'Active Time Bias from Registry
Dim Bias		'Time Bias
Dim strAdsPath, strDate, lngDate, nDate 

Dim objList		'Dictionary object to track latest LastLogon for each computer
Dim objRoot		'RootDSE object
Dim strConfig		'Configuration Naming Context
Dim objDC		'Domain Controller
Dim strDNSDomain	'
Dim strComputer		'Computer object Name
Dim objConnection       'ADO conection
Dim objCommand          'ADO command
Dim objRecordSet        'Object to hold attributes from AD
Dim oWshShell		'Windows shell script 
Dim objFSO		'File System object
Dim objFile		'File object used to open text file for output
Dim objLastLogon	'Last Logon Long Integer attribute
Dim strFilePath		'Path to current directory

Set oWshShell = CreateObject("Wscript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strFilePath = objFSO.GetAbsolutePathName(".")
Set objFile = objFSO.OpenTextFile (strFilePath & "\PCNAME-n-DATE.log",ForAppending,True)

' Use a dictionary object to track latest LastLogon for each computer.
Set objList = CreateObject("Scripting.Dictionary")
objList.CompareMode = vbTextCompare

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

' Determine configuration context and DNS domain from RootDSE object.
Set objRoot = GetObject("LDAP://RootDSE")
strConfig = objRoot.Get("ConfigurationNamingContext")
strDNSDomain = objRoot.Get("DefaultNamingContext")

' Use ADO to search Active Directory for ObjectClass nTDSDSA.
' This will identify all Domain Controllers.
Set objCommand = CreateObject("ADODB.Command")
Set objConnection = CreateObject("ADODB.Connection")
objConnection.Provider = "ADsDSOObject"
objConnection.Open = "Active Directory Provider"
objCommand.ActiveConnection = objConnection

 
objCommand.CommandText = "<LDAP://" & strConfig & ">;(ObjectClass=nTDSDSA);AdsPath;subtree"
objCommand.Properties("Page Size") = 100
objCommand.Properties("Timeout") = 30
objCommand.Properties("Searchscope") = 2
objCommand.Properties("Cache Results") = False

Set objRecordSet = objCommand.Execute

' Enumerate parent objects of class nTDSDSA. Save Domain Controller
' AdsPaths in dynamic array sDCs.
k = 0
'Do Until objRecordSet.EOF
'  Set objDC = GetObject(GetObject(objRecordSet.Fields("AdsPath")).Parent)
'  ReDim Preserve sDCs(k)
'  sDCs(k) = objDC.DNSHostName
'  k = k + 1
'  objRecordSet.MoveNext
'Loop

' Retrieve LastLogon attribute for each computer on each Domain Controller.
'For k = 0 To Ubound(sDCs)
'  oWshShell.Popup "Checking 'lastlogon' at domain controller " & sDCs(k) & ". Controller " & k & " of " & Ubound(sDCs),2,"Checking",64
  
'  objCommand.CommandText = "<LDAP://" & sDCs(k) & "/OU=Corporate,OU=Workstations," & strDNSDomain & ">;(ObjectCategory=computer);Name,LastLogon;subtree"
'  On Error Resume Next
'  Err.Clear
'  Set objRecordSet = objCommand.Execute
'  If Err.Number <> 0 Then
'    Err.Clear
'    On Error GoTo 0
'    oWshShell.Popup "Domain Controller not available: " & sDCs(k),2,"Notice",48
'  Else
'    On Error GoTo 0
'    Do Until objRecordSet.EOF
'      strAdsPath = objRecordSet.Fields("Name")
'      strDate = objRecordSet.Fields("LastLogon")
'      On Error Resume Next
'      Err.Clear
'      Set lngDate = strDate
'      If Err.Number <> 0 Then
'        Err.Clear
'        nDate = #1/1/1601#
	
'      Else
'        If (lngDate.HighPart = 0) And (lngDate.LowPart = 0 ) Then
'          nDate = #1/1/1601#
'        Else
'          nDate = #1/1/1601# + (lngDate.highpart * 2^32 + lngDate.lowpart) / 864E9 - Bias / 1440 '#1/1/1601# + (((lngDate.HighPart * (2 ^ 32)) + lngDate.LowPart)/600000000 - Bias)/1440
'        End If
'      End If
'      On Error GoTo 0
'      If objList.Exists(strAdsPath) Then
'        If nDate > objList(strAdsPath) Then
'          objList(strAdsPath) = nDate
'        End If
'      Else
'        objList.Add strAdsPath, nDate
'      End If
'      objRecordSet.MoveNext
'    Loop
'  End If
'Next



Call GetDate("vbdc004.vbgov.com")
'Call GetDate(server2.abc3.abc.company.com)

' Output latest LastLogon date for each computer.


objFile.WriteLine "Output File opened at " & Now

For Each strComputer In objList
Call  VBOut(strComputer,objList(strComputer))
Next

objFile.WriteLine " End of log file for: " & Now
objFile.WriteBlankLines (1)
objFile.WriteLine "============================================================================="
objFile.WriteBlankLines (3)
objFile.Close


' Clean up.
Set objRoot = Nothing
Set objConnection = Nothing
Set objCommand = Nothing
Set objRecordSet = Nothing
Set objDC = Nothing
Set lngDate = Nothing
Set objList = Nothing
Set oWshShell = Nothing


'************************************************************************************************
'* Function VBOut 
'* 
'* Format data and write to output file
'*
'************************************************************************************************

Function VBOut(strPC,strTime)

Dim strComputerName	'Formatted computer name output string
Dim strLogonTime	'Formatted Last Logon Time output string

Dim CNameArray(1)	'This array is used to format the output strings

'Format computer name string

   CNameArray(0) = strPC
   CNameArray(1) = "                    "
   strComputerName = Join(CNameArray)
   strComputerName = Left (strComputerName, 18)

'Format Last Logon Time string

   CNameArray(0) = strTime
   CNameArray(1) = "                          "
   strLogonTime = Join(CNameArray)
   strLogonTime = Left (strLogonTime, 24)


   objFile.Write strComputerName
   objFile.WriteLine "  " & strLogonTime



End Function

Function GetDate(sDC)

  objCommand.CommandText = "<LDAP://" & sDC & "/OU=Corporate,OU=Workstations," & strDNSDomain & ">;(ObjectCategory=computer);Name,LastLogon;subtree"
  On Error Resume Next
  Err.Clear
  Set objRecordSet = objCommand.Execute
  If Err.Number <> 0 Then
    Err.Clear
    On Error GoTo 0
    oWshShell.Popup "Domain Controller not available: " & sDC,2,"Notice",48
  Else
    On Error GoTo 0
    Do Until objRecordSet.EOF
      strAdsPath = objRecordSet.Fields("Name")
      strDate = objRecordSet.Fields("LastLogon")
      On Error Resume Next
      Err.Clear
      Set lngDate = strDate
      If Err.Number <> 0 Then
        Err.Clear
        nDate = #1/1/1601#
	
      Else
        If (lngDate.HighPart = 0) And (lngDate.LowPart = 0 ) Then
          nDate = #1/1/1601#
        Else
          nDate = #1/1/1601# + (lngDate.highpart * 2^32 + lngDate.lowpart) / 864E9 - Bias / 1440 
        End If
      End If
      On Error GoTo 0
      If objList.Exists(strAdsPath) Then
        If nDate > objList(strAdsPath) Then
          objList(strAdsPath) = nDate
        End If
      Else
        objList.Add strAdsPath, nDate
      End If
      objRecordSet.MoveNext
    Loop
  End If
  
End Function
