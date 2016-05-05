[reflection.assembly]::loadwithpartialname("System.ServiceProcess")
$Server = 'vmdb9028'
# List all services on the remote computer
[System.ServiceProcess.ServiceController]::GetServices( $Server )





(new-Object System.ServiceProcess.ServiceController('CCMExec',$Server)).Stop() 
(new-Object System.ServiceProcess.ServiceController('CCMExec',$Server)).WaitForStatus('Stopped',(new-timespan -seconds 5))











#[reflection.assembly]::loadwithpartialname("System.ServiceProcess")
#
## List all services on the remote computer
#[System.ServiceProcess.ServiceController]::GetServices('10.123.123.125')
#
## Stop the service and wait for it to change status
#$service = (new-object System.ServiceProcess.ServiceController('Service name','10.123.123.125'))
#$service.WaitForStatus('Stopped',(new-timespan -seconds 5))
#$service.Stop()
#
## Start the service again
#$service.Start()
#






## Manage remote Services 
#
## do not forget to set a TimeOut on the waitForStatus as ctr-C will not cancel it 
#  
#[System.ServiceProcess.ServiceController]::GetServices('server') 
#
#(new-Object System.ServiceProcess.ServiceController('Service','server')).Start() 
#(new-Object System.ServiceProcess.ServiceController('Service','server')).WaitForStatus('Running',(new-timespan -seconds 5)) 
#
#(new-Object System.ServiceProcess.ServiceController('Service','server')).Stop() 
#(new-Object System.ServiceProcess.ServiceController('Service','server')).WaitForStatus('Stopped'',(new-timespan -seconds 5)) 