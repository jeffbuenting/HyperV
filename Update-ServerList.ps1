#------------------------------------------------------------------------------
# Function Get-SPWebService
#
## Usage: 
#   $proxy = .\get-webservice2.ps1 [-Url] http://site/service.asmx?wsdl [-Anonymous] [[-SoapProtocol] <Soap | Soap12>]
#------------------------------------------------------------------------------

Function Get-SPWebService

{	
	param ( $url = $(throw "need `$url"), 
			[switch]$Anonymous, 
			[string]$protocol = "Soap" )
			
	[void][system.Reflection.Assembly]::LoadWithPartialName("system.web.services")
 
	trap {
	        "Error:`n`n $error";
	        break; 
	}
	
	$dcp = new-object system.web.services.discovery.discoveryclientprotocol
 
 	# ----- Get Username/Password if not using Anonymouse access
	if (! $Anonymous) {
	    Write-Progress "Network Credentials" "Awaiting input..."
	    $dcp.Credentials = (Get-Credential).GetNetworkCredential()
	}

	Write-Progress "Discovery" "Searching..."
	$dcp.AllowAutoRedirect = $true
	[void]$dcp.DiscoverAny($url)
	$dcp.ResolveAll()

	# ----- get service name
	foreach ($entry in $dcp.Documents.GetEnumerator()) { # needed for Dictionary
	    if ($entry.Value -is [System.Web.Services.Description.ServiceDescription]) {
	        $script:serviceName = $entry.Value.Services[0].Name
	        Write-Verbose "Service: $serviceName"
	    }
	}

	Write-Progress "WS-I Basic Profile 1.1" "Validating..."
	$ns = new-Object System.CodeDom.CodeNamespace # "WebServices"

	$wref = new-object System.Web.Services.Description.WebReference $dcp.Documents, $ns
	$wrefs = new-object system.web.services.description.webreferencecollection
	[void]$wrefs.Add($wref)

	$ccUnit = new-object System.CodeDom.CodeCompileUnit
	[void]$ccUnit.Namespaces.Add($ns)

	$violations = new-object system.web.Services.Description.BasicProfileViolationCollection
	$wsi11 = [system.web.services.WsiProfiles]::BasicProfile1_1

	if ([system.web.Services.Description.WebServicesInteroperability]::CheckConformance($wsi11, $wref, $violations)) {
	    Write-Progress "Proxy Generation" "Compiling..."
	    
	    $webRefOpts = new-object System.Web.Services.Description.WebReferenceOptions
		$webRefOpts.CodeGenerationOptions = "GenerateNewAsync","GenerateProperties" #,"GenerateOldAsync"

		#StringCollection strings = ServiceDescriptionImporter.GenerateWebReferences(
		#	webReferences, codeProvider, codeCompileUnit, parameters.GetWebReferenceOptions());

	    $csprovider = new-object Microsoft.CSharp.CSharpCodeProvider
		$warnings = [System.Web.Services.Description.ServiceDescriptionImporter]::GenerateWebReferences(
			$wrefs, $csprovider, $ccunit, $webRefOpts)
	        
	    if ($warnings.Count -eq 0) {
	        $param = new-object system.CodeDom.Compiler.CompilerParameters
	        [void]$param.ReferencedAssemblies.Add("System.Xml.dll")
	        [void]$param.ReferencedAssemblies.Add("System.Web.Services.dll")        
	        $param.GenerateInMemory = $true;
	        #$param.TempFiles = (new-object System.CodeDom.Compiler.TempFileCollection "c:\temp", $true)
	        $param.GenerateExecutable = $false;
	        #$param.OutputAssembly = "$($ns.Name)_$($sdname).dll"
	        $param.TreatWarningsAsErrors = $false;
	        $param.WarningLevel = 4;
	        
	        # do it
	        $compileResults = $csprovider.CompileAssemblyFromDom($param, $ccUnit);
	 
	        if ($compileResults.Errors.Count -gt 0) {
	            Write-Progress "Proxy Generation" "Failed."
	            foreach ($output in $compileResults.Output) { write-host $output }
	            foreach ($err in $compileResults.Errors) { write-warning $err }            
	        } else {            
	            $assembly = $compileResults.CompiledAssembly

	            if ($assembly) {
	                $serviceType = $assembly.GetType($serviceName)                
	                $assembly.GetTypes() | % { Write-Verbose $_.FullName }
	            } else {
	                Write-Warning "Failed: `$assembly is null"
					return
	            }
	            
	            # return proxy instance
	            $proxy = new-object $serviceType.FullName
	            if (! $Anonymous) {
	                $proxy.Credentials = $dcp.Credentials
	            }
	            $proxy # dump instance to pipeline
	        }
	    } else {
	        Write-Progress "Proxy Generation" "Failed."        
	        Write-Warning $warnings
	    }
	    #Write-Progress -Completed
	}
}

#----------------------------------------------------------------------------
# Function Get-SPListInfo
#
# Get the info from a SharePoint List
#http://msdn.microsoft.com/en-us/library/lists.lists.getlistcollection(v=office.12).aspx
#----------------------------------------------------------------------------

Function Get-SPListInfo

{
	Param ( $SPService,
			$ListName = $Null )
	
	$Lists = $SPService.GetListcollection()

	if ( $ListName -eq $null ) { # ----- Get all lists
			return $lists.Childnodes
		}
		else {	# ----- Get specific list
			foreach ( $List in $Lists.childnodes ) {
				if ( $list.Title -eq $ListName ) { return $List }
			}
	}
}


#----------------------------------------------------------------------------
# Function Get-SPList
#
# Returns the Items in a list
# http://www.u2u.info/Blogs/karine/Lists/Posts/Post.aspx?ID=26
#
# Query if Null returns the entire list.  to retrieve a subset of the list you will need to pass a CAML Query
#----------------------------------------------------------------------------

Function Get-SPList

{
	Param ( $SPService,
			$List,
			[XML]$Query = $Null )
		
	$XMLList = $SPService.GetListItems( $List.ID, $null, $Query, $null, $null, $null, $null)
	Return $XMLList.data.row 
	
}

#----------------------------------------------------------------------------
# Function Update-SPList
#
# Updates a Sharepoint List
#
#http://www.u2u.info/Blogs/Karine/Lists/Posts/Post.aspx?ID=23
#----------------------------------------------------------------------------

Function Update-SPList 

{
	Param ( $SPService,
			$list,
			[XML]$UpdateQuery )

	$SPService.UpdateListItems( $list.ID, $UpdateQuery )
}

#----------------------------------------------------------------------------
# Main
#----------------------------------------------------------------------------

# ---- Setup Sharpoint Proxy
$SPProxy = get-SPWebService -Url 'http://vbnet/_vti_bin/lists.asmx'
$SPProxy.url = 'http://vbnet/comit/ss/_vti_bin/lists.asmx'

# ---- Get Server List
$ListInfo = Get-SPListInfo $SPProxy 'Server List'

$Query = $Null
$ServerList = Get-SPList $SPProxy $ListInfo $Query

# ----- Get Public VMs
$ServerInfo = Import-Csv c:\temp\serverinfo.csv 
$NotinList = $True
#$ServerInfo
#$serverlist
foreach ( $S in $ServerInfo ) {
	foreach ( $Server in $ServerList ) {
		if ( $Server.ows_LinkTitle -eq $S.Server ) { # ----- Server in Serverlist
			$NotinList = $false
		}
	}
	if ( $NotinList -eq $true ) {
			
			$Title = $S.Server
			write-host "Adding $Title to List" -ForegroundColor Green
			$Status = $S.Status
			$Tier = $S.Tier
			$Network = $S.Network
			$WindowsDomain = $S.WindowsDomain
			$OS = $S.OS
			$WindowsVersion = $S.WindowsVersion
			$OSServicePack = $S.OSServicePack
			$OwningTeam = $S.OwningTeam
			$IPPrimary = $S.IPPrimary
			$RAM = $S.RAM
			$Virtual = $S.Virtual
#			$UpdateQuery = "<Batch OnError='Continue'><Method ID='1' Cmd='New'><Field Name='Title'>$Title</Field><Field Name='Status'>$Status</Field><Field Name='Tier'>$Tier</Field><Field Name='Network'>$Network</Field><Field Name='WindowsDomain'>$WindowsDomain</Field><Field Name='OS'>$OS</Field><Field Name='WindowsVersion'>$WindowsVersion</Field><Field Name='OSServicePack'>$OSServicePack</Field><Field Name='IPPrimary'>$IPPrimary</Field><Field Name='RAM'>$RAM</Field></Method></Batch>"
			$UpdateQuery = "<Batch OnError='Continue'><Method ID='1' Cmd='New'><Field Name='Title'>$Title</Field><Field Name='Status'>$Status</Field><Field Name='Tier'>$Tier</Field><Field Name='Network'>$Network</Field><Field Name='Domain_x002f_Workgroup'>$WindowsDomain</Field><Field Name='OS'>$OS</Field><Field Name='OSVersion'>$WindowsVersion</Field><Field Name='Service_x0020_Pack'>$OSServicePack</Field><Field Name='IP_x0020_Info'>$IPPrimary</Field><Field Name='RAM'>$RAM</Field><Field Name='Virtual'>$Virtual</Field></Method></Batch>"
			Update-SPList $SPProxy $ListInfo $UpdateQuery
		}
		Else {
			Write-Host "$S.Server is already in the list" -ForegroundColor Cyan
	}
}
