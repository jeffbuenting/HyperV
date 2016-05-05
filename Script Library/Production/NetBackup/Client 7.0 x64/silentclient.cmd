REM $Id: silentclient.cmd,v 1.18 2009/09/28 14:45:09 $ 
REM 
REM bcpyrght 
REM ******************************************************************************* 
REM  $VRTScprght: Copyright 1993 - 2009 Symantec Corporation, All Rights Reserved $ 
REM ******************************************************************************* 
REM ecpyrght 
REM 

 @ECHO OFF

REM Change the following lines to reflect the name of this master server, and any other servers
REM allowed to access this client. These options have no effect when reinstalling NetBackup.

SET CLIENT=.
SET MASTERSERVER=VBBS002

REM Remove this line if you have no other media servers that will be allowed to access this machine

SET ADDITIONALSERVERS=VBBS0003

REM Destination directory goes here.

SET INSTALLDIR=C:\Program Files\VERITAS\

REM Use 1 to Install the Debug Symbols, 0 to not install them.

SET INSTALLDEBUG=0

REM Use 1 to Start the NetBackup services, 0 to not start them.

SET SERVICESTART=1

REM Use Automatic to set the services to automatically start, Manual to manually start them.
REM This option has no effect when reinstalling NetBackup.

SET SERVICESTARTTYPE=Automatic

REM Set to 1 to start the Job Tracker at every login, 0 otherwise. This option has no effect 
REM when reinstalling NetBackup.

SET STARTTRACKER=0

REM NetBackup Port Numbers

SET BPCD_PORT=13782
SET BPRD_PORT=13720

REM Stop NetBackup Processes
REM WARNING please make sure no NetBackup jobs are active and all databases are shutdown.

SET STOP_NBU_PROCESSES=0

REM Abort install if reboot is required

SET ABORT_REBOOT_INSTALL=0


REM --------------------------------------
REM Do not change anything after this line
REM Install logs will be saved to %ALLUSERSPROFILE%\Symantec\NetBackup\InstallLogs
REM --------------------------------------

SET RESPFILENAME=%TEMP%\%COMPUTERNAME%_silentclient.resp

IF EXIST %RESPFILENAME% del %RESPFILENAME%

@ECHO INSTALLDIR:%INSTALLDIR%>> %RESPFILENAME%
@ECHO MASTERSERVERNAME:%MASTERSERVER%>> %RESPFILENAME%
@ECHO ADDITIONALSERVERS:%ADDITIONALSERVERS%>> %RESPFILENAME%
@ECHO NETBACKUPCLIENTINSTALL:1>> %RESPFILENAME%
@ECHO SERVERS:%MASTERSERVER%,%ADDITIONALSERVERS%>> %RESPFILENAME%
@ECHO CLIENTNAME:%CLIENT%>> %RESPFILENAME%
@ECHO NBSTARTTRACKER:%STARTTRACKER%>> %RESPFILENAME%
@ECHO STARTUP:%SERVICESTARTTYPE%>> %RESPFILENAME%
@ECHO NBSTARTSERVICES:%SERVICESTART%>> %RESPFILENAME%
@ECHO BPCD_PORT:%BPCD_PORT%>> %RESPFILENAME%
@ECHO BPRD_PORT:%BPRD_PORT%>> %RESPFILENAME%
@ECHO CLIENTSLAVENAME:%CLIENT%>> %RESPFILENAME%
@ECHO SILENTINSTALL:1>> %RESPFILENAME%
@ECHO ISPUSHINSTALL:1>> %RESPFILENAME%
@ECHO ISCUSTOMINSTALL:1>> %RESPFILENAME%
@ECHO REBOOT:ReallySuppress>> %RESPFILENAME%
@ECHO NUMERICINSTALLTYPE:1>> %RESPFILENAME%
@ECHO INSTALLDEBUG:%INSTALLDEBUG%>> %RESPFILENAME%
@ECHO STOP_NBU_PROCESSES:%STOP_NBU_PROCESSES%>> %RESPFILENAME%
@ECHO ABORT_REBOOT_INSTALL:%ABORT_REBOOT_INSTALL%>> %RESPFILENAME%


c:\temp\setup.exe -s /REALLYLOCAL /RESPFILE:'%RESPFILENAME%'
rem "\\vbgov.com\deploy\Disaster_Recovery\NetBackup\Software\7.0 Installation Windows\PC_Clnt\x64\setup.exe" -s /RESPFILE:'%RESPFILENAME%'

IF EXIST %RESPFILENAME% del %RESPFILENAME%

pause



