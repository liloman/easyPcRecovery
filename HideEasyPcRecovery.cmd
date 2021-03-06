@ECHO OFF
pushd %~dp0
net session >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO You need ADMIN RIGHTS!
    pause
	GOTO :EOF
)
@ECHO ON

REM Reset errorlevel
VER > NUL 

attrib +s +h \easyPcRecovery
attrib +s +h \InstallEasyPcRecovery.cmd
attrib +s +h \UninstallEasyPcRecovery.cmd
attrib +s +h \README.md
attrib +s +h \HideEasyPcRecovery.cmd
if exist %systemdrive%\menu.lst  attrib +s +h %systemdrive%\menu.lst
if exist %systemdrive%\grldr attrib +s +h %systemdrive%\grldr
if exist %systemdrive%\easyPcRecovery attrib +s +h %systemdrive%\easyPcRecovery
