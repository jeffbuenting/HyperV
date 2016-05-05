Function Get-Input1( $Question ) 
{
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    $objForm = New-Object System.Windows.Forms.Form 
	$objForm.Text = $Question
	$objForm.Size = New-Object System.Drawing.Size(300,200) 
	$objForm.StartPosition = "CenterScreen"

	$objForm.KeyPreview = $True
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    	{$x=$objTextBox.Text;$objForm.Close()}})
	$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
		{$objForm.Close()}})

	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Size(75,120)
	$OKButton.Size = New-Object System.Drawing.Size(75,23)
	$OKButton.Text = "OK"
	$OKButton.Add_Click({$x=$objTextBox.Text;$objForm.Close()})
	$objForm.Controls.Add($OKButton)
	
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Size(150,120)
	$CancelButton.Size = New-Object System.Drawing.Size(75,23)
	$CancelButton.Text = "Cancel"
	$CancelButton.Add_Click({$objForm.Close()})
	$objForm.Controls.Add($CancelButton)
	
	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10,20) 
	$objLabel.Size = New-Object System.Drawing.Size(280,20) 
	$objLabel.Text = $Question
	$objForm.Controls.Add($objLabel) 
	
	$objTextBox = New-Object System.Windows.Forms.TextBox 
	$objTextBox.Location = New-Object System.Drawing.Size(10,40) 
	$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
	$objForm.Controls.Add($objTextBox) 
	
	$objForm.Topmost = $True
	
	$objForm.Add_Shown({$objForm.Activate()})
	[void] $objForm.ShowDialog()

 	Return $x
}

#----------------------------------------------------

Function Get-Input( $Question )

{
    $a = new-object -comobject MSScriptControl.ScriptControl
    $a.language = "vbscript"
    $a.addcode("function getInput() getInput = inputbox(`"$Question`",`"$Question`") end function" )
    $b = $a.eval("getInput")

    Return $b

}

#------------------------------------------------------


Function Get-Confirmation( $Question )

{
    $a = new-object -comobject MSScriptControl.ScriptControl
    $a.language = "vbscript"
    $a.addcode("function getConfirm() getconfirm = msgbox(`"$Question`",68,`"$Question`") end function" )
    $b = $a.eval("getconfirm")

    Return $b

}










#The MsgBox function displays a message box, waits for the user to click a button, and returns a value that indicates which button the user clicked.
#
#The MsgBox function can return one of the following values:
#
#1 = vbOK - OK was clicked 
#2 = vbCancel - Cancel was clicked 
#3 = vbAbort - Abort was clicked 
#4 = vbRetry - Retry was clicked 
#5 = vbIgnore - Ignore was clicked 
#6 = vbYes - Yes was clicked 
#7 = vbNo - No was clicked 
#Note: The user can press F1 to view the Help topic when both the helpfile and the context parameter are specified.
#
#Tip: Also look at the InputBox function.
#
#Syntax
#MsgBox(prompt[,buttons][,title][,helpfile,context]) 
#
#Parameter Description 
#prompt Required. The message to show in the message box. Maximum length is 1024 characters. You can separate the lines using a carriage return character (Chr(13)), a linefeed character (Chr(10)), or carriage return–linefeed character combination (Chr(13) & Chr(10)) between each line 
#buttons Optional. A value or a sum of values that specifies the number and type of buttons to display, the icon style to use, the identity of the default button, and the modality of the message box. Default value is 0
#0 = vbOKOnly - OK button only 
#1 = vbOKCancel - OK and Cancel buttons 
#2 = vbAbortRetryIgnore - Abort, Retry, and Ignore buttons 
#3 = vbYesNoCancel - Yes, No, and Cancel buttons 
#4 = vbYesNo - Yes and No buttons 
#5 = vbRetryCancel - Retry and Cancel buttons 
#16 = vbCritical - Critical Message icon 
#32 = vbQuestion - Warning Query icon 
#48 = vbExclamation - Warning Message icon 
#64 = vbInformation - Information Message icon 
#0 = vbDefaultButton1 - First button is default 
#256 = vbDefaultButton2 - Second button is default 
#512 = vbDefaultButton3 - Third button is default 
#768 = vbDefaultButton4 - Fourth button is default 
#0 = vbApplicationModal - Application modal (the current application will not work until the user responds to the message box) 
#4096 = vbSystemModal - System modal (all applications wont work until the user responds to the message box) 
#We can divide the buttons values into four groups: The first group  (0–5) describes the buttons to be displayed in the message box, the second group (16, 32, 48, 64) describes the icon style, the third group (0, 256, 512, 768) indicates which button is the default; and the fourth group (0, 4096) determines the modality of the message box. When adding numbers to create a final value for the buttons parameter, use only one number from each group
# 
#title Optional. The title of the message box. Default is the application name 
#helpfile Optional. The name of a Help file to use. Must be used with the context parameter 
#context Optional. The Help context number to the Help topic. Must be used with the helpfile parameter 




#------------------------------------------------------



Get-Input1 "does this work?"
Get-Input "how about this"
