@echo off
cls
color 1f
echo Make an Easy2Boot USB drive (requires RMPrepUSB to be installed)
echo ================================================================
echo.

pushd "%~dp0"
if not exist ..\menu.lst echo ERROR: Cannot find Easy2Boot files in %~dp0 & color 4f & pause & exit

REM change to our working folder
set WF=C:\Program Files (x86)\RMPrepUSB
if exist "%WF%\rmpartusb.exe" goto :gotwf
set WF=C:\Program Files\RMPrepUSB
if exist "%WF%\rmpartusb.exe" goto :gotwf

:NF
echo.
echo Sorry - I cannot find RMPrepUSB!
echo Please install RMPrepUSB to your C:\Program Files folder
echo OR
echo Specify the folder where RMPrepUSB is located.
echo
set /p WF=RMPrepUSB folder is at (e.g. D:\temp\RMPrepUSB) ? : 
if exist "%WF%\rmpartusb.exe" goto :gotwf
set /p ask=Sorry - couldn't find it - press R to Retry or any other key to exit (Retry\Abort) : 
if /i "%ask%"=="R" goto :NF
exit


:gotwf
pushd "%WF%"
RMPARTUSB FIND > %temp%\mdtemp.cmd
call %temp%\mdtemp.cmd > nul
if exist %temp%\mdtemp.cmd del %temp%\mdtemp.cmd > nul
if "%DRIVESIZE%"=="0" color 4f & echo NO USB DRIVE FOUND (or 'Run as Administrator' required)! & pause & exit

REM list all USB drives so user can see them and their drive number
RMPARTUSB LIST
REM Ask user for a drive number
set /P DD=Please enter the USB drive number you want to ERASE and FORMAT (e.g. %DRIVE%) : 
REM execute RMPARTUSB (insert SURE if you don't want the user prompt)
cls
echo.
RMPARTUSB DRIVE=%DD% GETDRV > %temp%\mdtemp.cmd
call %temp%\mdtemp.cmd > nul
if exist %temp%\mdtemp.cmd del %temp%\mdtemp.cmd > nul
if "%USBDRIVESIZE%"=="0" echo ERROR: NOT A USB DRIVE? & color 4f & pause & exit

RMPARTUSB LIST
if "%DD%"=="0" echo WARNING: DRIVE 0 IS YOUR SYSTEM DRIVE!!! & pause & exit
set /p ask=Are you sure it is OK to format DRIVE %DD% (Y/N) : 
if /i not "%ask%"=="Y" exit
if "%DD%"=="0" exit
echo.
echo CHOOSE A FILESYSTEM 
echo ===================
echo.
echo NTFS  - If you want to boot from large files over 4GB 
echo FAT32 - If you have files below 4GB in size (most compatible)
echo.
set ask=
set /p ask=Format as FAT32 ([Y]/N=NTFS) : 
set FMT=FAT32
if /i "%ask%"=="N" set FMT=NTFS


echo.
echo ERASE AND FORMAT DRIVE %DD% as %FMT%...
RMPARTUSB DRIVE=%dd% WINPE %FMT% 2PTN VOLUME=E2B > nul
if errorlevel 1 (color 4f & echo RMPARTUSB COMMAND FAILED! & pause & exit)
echo Format complete - OK
set USBDRIVELETTER=
REM get the drive letter of the newly formatted drive
FOR /F "tokens=*" %%A IN ('RMPARTUSB DRIVE^=%dd% GETDRV') DO %%A
If "%USBDRIVELETTER%"=="" goto :EOF

popd

if not exist ..\menu.lst exit
echo.
echo Copying over Easy2Boot files to %USBDRIVELETTER% - Please wait...
xcopy /herky ..\*.* %USBDRIVELETTER%\*.* > nul
echo.
If errorlevel 1 color 4f & echo ERROR IN COPYING FILES & pause & exit

pushd "%WF%"

REM install grub4dos - use new grubinst to install to PBR
echo Installing grub4dos to PBR of %USBDRIVELETTER%...
set GR=..\clonezilla\grubinst.exe

if "%dd%"=="0" exit

REM Dismount the drive, run grubinst, remount the drive
"%~dp0LockDismount.exe" -force %dd% %GR% -t=0 --install-partition=0 (hd%dd%)
If errorlevel 1 color 4f & pause & exit
REM use touchdrv to ensure MBR changes are not removed by Windows!
touchdrv %USBDRIVELETTER%


REM also install to MBR
echo.
echo Installing grub4dos to MBR of %USBDRIVELETTER%...
if %DD% GEQ 10 set GR=..\clonezilla\grubinst.exe
"%~dp0LockDismount.exe" -force %dd% %GR% -t=0 --skip-mbr-test (hd%dd%)
If errorlevel 1 color 4f & pause & exit
touchdrv %USBDRIVELETTER%

popd

color 2f
echo FINISHED - OK.
echo.
pause
