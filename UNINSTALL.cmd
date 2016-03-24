@ECHO OFF
pushd %~dp0
SetLocal EnableDelayedExpansion
set BDRIVE=""

for /F "tokens=1-2" %%a in ('wmic logicaldisk get DeviceID^, DriveType^| find ":"') do (
	if exist %%a\easyPcRecovery\clonezilla\live\vmlinuz set BDRIVE=%%a
)

if %BDRIVE% == "" (
 echo Not found any easyPcRecovery installation
GOTO :EXIT
)

SET /P input="Are you sure you want to uninstall easyPcRecovery from %BDRIVE%? (Y/N):"
if /I not "%input%"=="Y" ( GOTO :EXIT)


echo Restoring MBR...
%BDRIVE%\easyPcRecovery\mbrfix\mbrfix.exe /yes /drive 0 restorembr %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install.bin
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

cd /D %BDRIVE%\
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

echo Uninstalling from %BDRIVE%...
del README.md
del UnHideEverything.cmd HideEverything.cmd 
del INSTALL.cmd UNINSTALL.cmd

SET /P input="Do you want to delete all your backups from %BDRIVE%? (Y/N):"
if /I "%input%"=="Y" ( 
echo Deleting backups then...
rmdir /s /q easyPcRecovery > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
)else (
rmdir /s /q easyPcRecovery\menus
rmdir /s /q easyPcRecovery\mbrfix
rmdir /s /q easyPcRecovery\ISO  
rmdir /s /q easyPcRecovery\gparted
rmdir /s /q easyPcRecovery\extras
rmdir /s /q easyPcRecovery\bin
rmdir /s /q easyPcRecovery\clonezilla\live
REM Be careful don´t add /s flag here!!
del /q easyPcRecovery\clonezilla\*
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
)

cd /D %systemdrive%\
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

echo Uninstalling from %systemdrive%...
del /q grldr menu.lst
rmdir /s /q easyPcRecovery
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

echo.
echo ===============UNINSTALLED!===============
echo.
echo    easyPcRecovery uninstalled !!
echo.
echo ===============UNINSTALLED!===============
pause 

EXIT /B

:ERROR
echo Something went wrong. ERRORLEVEL:%ERRORLEVEL% 
GOTO :EXIT

:EXIT
echo Exiting. Press any key to exit.
pause
exit /B
cmd /c exit -1073741510
