@ECHO OFF
pushd %~dp0
SetLocal EnableDelayedExpansion
set BDRIVE=""
REM cls


REM Check for admin rights
REM fsutil dirty query %systemdrive% >nul
net session >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO You need ADMIN RIGHTS!
	GOTO :EXIT
)
REM Reset errorlevel
VER > NUL 

for /F "tokens=1-2" %%a in ('wmic logicaldisk where "DeviceID='%systemdrive%'" get DeviceID^, DriveType^| find ":"') do (
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get FreeSpace /format:value`) do set FreeSpace=%%x
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get Size /format:value`) do set Size=%%x
    set FreeKB=!FreeSpace:~0,-4!
    set SizeKB=!Size:~0,-4!    
        Rem Half space MINIMUM (depends of what you got in your disk...)
	set /a totalUsed= ^(sizeKB - FreeKB^)/2072 
        Rem Plus the space for easyPcRecovery files...
        set /a totalUsed= totalUsed+ 500
	SET /a TotalFree= freeKB / 1036
	set /a totalGB=totalUsed/1036
	echo You need a extra partition/disk with AT LEAST !TotalUsed!MB^(!totalGB!GB^) free    
)
	
echo Scaning for other disks/partitions...
set count=0
for /F "tokens=1-2" %%a in ('wmic logicaldisk get DeviceID^, DriveType^| find ":"') do (
   if %%b NEQ 5 if not "%%a"=="C:" (
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get FreeSpace /format:value`) do set FreeSpace=%%x
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get Size /format:value`) do set Size=%%x
    set FreeKB=!FreeSpace:~0,-4!
    set SizeKB=!Size:~0,-4!
	set /a freeMB=freeKB / 1036
	set /a freeGB=freeMB / 1036
	set /a sizeMB=sizeKB / 1036
    set /a Percentage=^(100 * FreeMB^) / SizeMB
	if !freeMB! GTR !Totalused! (
	set /a count+=1
	set mapArray[!count!]=%%a	
    echo !count!^) %%a have !FreeMB!MB^(!freeGB!GB^) free ^(!Percentage!%% free^)		
	)
	)	
)
if %count% GTR 0 ( GOTO :CH_DRIVE )

if !Totalused! GTR !totalFree! (
echo You don´t have enough space for any backup. Sorry.
 GOTO :EXIT
)

echo You need free space. 
echo You have !totalFree!MB free in %systemdrive%

set /p input="Do you want to partitionate your %systemdrive% drive? (Y/N)".
if /I "%input%"=="Y" ( 
  GOTO :CH_FSCHECK 
)else ( 
 GOTO :EXIT 
)


:CH_DRIVE
echo Which unit do you want to use for backups? (0 to exit)
SET /P ch="Choose a number:"
if %ch% EQU 0 (GOTO :EXIT)
if %ch% gtr %count% ( 
 echo Incorrect number %ch%!!. 
 GOTO :EXIT
) else (
 echo !mapArray[%ch%]! is going to be the disk to save the backups.
 set BDRIVE=!mapArray[%ch%]!
 GOTO :CH_INSTALL
)

:CH_FSCHECK
fsutil dirty query %systemdrive% | find "no" > NUL
IF %ERRORLEVEL% NEQ 0 (
 echo You need to reboot your computer to do a filesystem check^(fsck^).
 echo Reboot and then launch again this executable.
 set /p input="Do you want to reboot the PC right now? (Y/N):".
 if /I "%input%"=="Y" ( shutdown -r -t 10 -c "Rebooting for filesystem check")
 GOTO :EXIT
)else (
  echo Your filesystem is clean, not need fsck.
  echo Defragmenting the disk. This will take some time. Be patient!!
  echo Press a key to start.
  pause > null
  defrag %systemdrive% -v
  set BDRIVE=%systemdrive%
  GOTO :CH_GPARTED
)

REM THERE ISN´T AN EXTRA UNIT WITH ENOUGH FREE SPACE TO ALLOCATE ALMOST A BACKUP
REM MUST PARTITIONATE THE CURRENT UNIT TO CREATE ANOTHER UNIT FROM THE FREE SPACE
:CH_GPARTED
echo Saving MBR to easyPcRecovery\mbrfix\mbr-backup.bin
easyPcRecovery\mbrfix\mbrfix.exe /drive 0 savembr easyPcRecovery\mbrfix\mbr-backup.bin
echo Preparing menu
copy /Y /V easyPcRecovery\menus\menu-gparted.lst %systemdrive%\menu.lst
copy /Y /V easyPcRecovery\menus\grldr %systemdrive%\
copy /Y /V easyPcRecovery\clonezilla\hotkey %systemdrive%\easyPcRecovery\clonezilla
mkdir %systemdrive%\easyPcRecovery\clonezilla
mkdir %systemdrive%\easyPcRecovery\gparted
xcopy \easyPcRecovery\gparted %systemdrive%\easyPcRecovery\gparted /s /e /k /y
echo Installing Gparted on MBR
\easyPcRecovery\clonezilla\grubinst.exe --skip-mbr-test (hd0)
if errorlevel 1 ( 
  pause 
  GOTO :EXIT
)
echo Reboot to boot gparted.
echo Remember you need AT LEAST !Totalused!MB on the new partition.
echo When you´ve finished with gparted, reboot and press F4 to boot Windows again.
set /p input="Do you want to reboot the PC right now? (Y/N):".
if /I "%input%"=="Y" ( shutdown -r -t 10 -c "Rebooting for partitioning with Gparted")
exit /B

REM THERE IS AN EXTRA UNIT WITH ENOUGH FREE SPACE
:CH_INSTALL

echo Copying menus to %systemdrive%
copy /Y /V easyPcRecovery\menus\*.lst %systemdrive%\
copy /Y /V easyPcRecovery\menus\grldr %systemdrive%\
mkdir %systemdrive%\easyPcRecovery\clonezilla
copy /Y /V easyPcRecovery\clonezilla\hotkey %systemdrive%\easyPcRecovery\clonezilla
attrib +s +h %systemdrive%\*.lst
attrib +s +h %systemdrive%\grldr
attrib +s +h %systemdrive%\easyPcRecovery
REM remove trailing spaces
CALL :TRIM %bdrive% bdrive  

REM Copy files to the backup drive
echo Copying files to %BDRIVE%...
xcopy . %BDRIVE%\ /s /e /k /y

cd /D %BDRIVE%\easyPcRecovery

REM Download
echo Downloading the ISOs
REM bin\wget -i bin\urls.txt

REM Clonezilla
echo Clonezilla...
bin\7za.exe x -oclonezilla/ clonezilla*.zip live/*

REM REM Gparted
echo Gparted...
bin\7za.exe e -ogparted gparted*.zip live/*

REM Plop
echo Plop...
mkdir extras
bin\7za.exe x plpbt*.zip plpbt-5.0.14/plpbt.bin
move /Y plpbt-5.0.14 extras\plop

REM slitaz
echo Slitaz...
mkdir extras\slitaz
move /Y slitaz*.iso extras\slitaz

echo Deleting zips...
del *.zip

echo Installing MBR into %systemdrive%...
clonezilla\grubinst.exe --skip-mbr-test (hd0)
if errorlevel 1 ( 
echo Something was wrong with grubinst.exe
pause
GOTO :EXIT
)

echo Hiding files...
REM cd ..
REM HideEverything.cmd


echo
echo
echo ===============FINISHED===============
echo Reboot and make your fresh first backup right now if you want it.
echo Press F4 on the boot menu to see the avaliable options.
echo ===============FINISHED===============
pause 
	
EXIT /B

:TRIM
SET %2=%1
GOTO :EOF

:EXIT
echo Exit
pause
exit /B
cmd /c exit -1073741510