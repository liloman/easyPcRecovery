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
attrib +s +h \INSTALL.cmd
attrib +s +h \UNINSTALL.cmd
attrib +s +h \prueba*.cmd
attrib +s +h \HideEverything.cmd
attrib +s +h %systemdrive%\*.lst
attrib +s +h %systemdrive%\grldr
attrib +s +h %systemdrive%\easyPcRecovery
attrib +s +h \README.md
