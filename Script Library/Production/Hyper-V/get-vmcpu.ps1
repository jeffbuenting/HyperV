#Get-VM -VMMServer vbas0080 | where { ($_.status -ne 'Stored' ) -and ($_.hostname -ne 'VBVS9001') -and ($_.CPUMAX -ne '100') } | ft name,cpumax,cputype,hostname
Get-VM -VMMServer vbas0080 | where { ( $_.status -ne 'Stored') -and ( $_.hostname -ne 'vbvs9001.vbgov.com' )} | sort cputype | format-table name,cputype,hostname 
