' //***************************************************************************
' // ***** Script Header *****
' //
' // Solution:  Config Mgr
' // File:      HideNotifications.vbs
' // Author:    Configuration Manager 2007 SDK, modified by Kent Agerlund
' // Purpose:   Remove software update notifications from the notification area
' // Values:    SetUserExperienceFlag| 0=Use Policy, 1=Always display notifications    
' // Values:    SetUserExperienceFlag| 2=Never display notifications    
' //
' // ***** End Header *****
' //***************************************************************************
'//----------------------------------------------------------------------------
'//
'//  Global constant and variable declarations
'//
'//----------------------------------------------------------------------------

dim updatesDeployment
    
set updatesDeployment = CreateObject ("UDA.CCMUpdatesDeployment")
updatesDeployment.SetUserExperienceFlag 1