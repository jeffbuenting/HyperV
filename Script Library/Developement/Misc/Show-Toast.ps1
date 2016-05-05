#--------------------------------------------------------------------------------
# Function Show-Toast
#
# Displays a pop up window in the lower right hand corner to notify the user of some item.  This is known as toast.
#
# Input: 
#		$Icon 		This is the icon that appears in the notification area. The icon must be 16 pixels high by 16 pixels wide. If you have icon-editing software you can create your own icon; if not, try searching your computer (or the Internet) for .ICO files. Just make sure you specify the full path to the icon file when assigning a value to the Icon property
#		$TipIcon	Info, Warning, and Error.  This is the icon that appears inside your notice (see the illustration below). You can choose between the following operating system-supplied icons: Info; Warning; and Error.
#		$Msg		The actual Message to be displayed
#		$TipTitle	The Title of your notice.
#		$TimeOut	Length of time the toast will display.  Should be from 10000 to 300000
#
# http://www.microsoft.com/technet/scriptcenter/resources/pstips/may08/pstip0523.mspx
#--------------------------------------------------------------------------------

Function Show-Toast( $Icon, $TipIcon, $Msg, $TipTitle )

{
   	If ( $TimeOut -eq $Null ) { $TimeOut = 10000 }

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

	$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon 

	$objNotifyIcon.Icon = $Icon
	$objNotifyIcon.BalloonTipIcon = $TipIcon 
	$objNotifyIcon.BalloonTipText = $Msg
	$objNotifyIcon.BalloonTipTitle = $TipTitle
	
	$objNotifyIcon.Visible = $True 
	$objNotifyIcon.ShowBalloonTip($TimeOut)
}

#---------------------------------------------------------------------------------

Show-Toast "c:\temp\wdlogo.ico" "Error" "Look, Toast!" "Toast"