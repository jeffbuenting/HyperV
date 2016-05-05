get-vm -vmmserver vbas0080 |sort name | ConvertTo-Html name,Status,hostname,owner -Title "Virtual Machine Information" | Set-Content "\\vbws006\d$\program files\microsoft virtual server\website\vminfo.htm"

