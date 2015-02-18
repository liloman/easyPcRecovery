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
	SET /a sizeMB= sizeKB / 1036
    Rem Half space MINIMUM (depends of what you got in your disk...)
	set /a totalUsedMB= ^(sizeKB - FreeKB^)/2072 
    Rem Plus the space for easyPcRecovery files...
    set /a totalUsedMB= totalUsedMB+ 500
	SET /a TotalFreeMB= freeKB / 1036
	set /a totalFreeGB=totalFreeMB/1036
	set /a totalGB=totalUsedMB/1036	
	echo You need a partition/disk/unit with AT LEAST !TotalUsedMB!MB^(!totalGB!GB^) free    
)


set count=0
REM If there is enough space in %systemdrive%
if !totalFreeMB! GTR !TotalusedMB! (  
  set mapArray[0]=%systemdrive%
  set /a Percentage=^(100 * totalFreeMB^) / SizeMB	
  echo 0^) %systemdrive% have !totalFreeMB!MB^(!totalFreeGB!GB^) free ^(!Percentage!%% free^) ^-^-^> WARNING: Needs partitioning
)
	
REM echo Scaning for other disks/partitions...
for /F "tokens=1-2" %%a in ('wmic logicaldisk get DeviceID^, DriveType^| find ":"') do (
   if %%b NEQ 5 if not "%%a"=="C:" (
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get FreeSpace /format:value`) do set FreeSpace=%%x
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get Size /format:value`) do set Size=%%x
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get volumeName /format:value`) do set volName=%%x
    set FreeKB=!FreeSpace:~0,-4!
    set SizeKB=!Size:~0,-4!
	set /a freeMB=freeKB / 1036
	set /a freeGB=freeMB / 1036
	set /a sizeMB=sizeKB / 1036
    set /a Percentage=^(100 * FreeMB^) / SizeMB
	if !freeMB! GTR !TotalusedMB! (
	set /a count+=1
	set mapArray[!count!]=%%a	
    REM remove trailing spaces
    CALL :TRIM !volName! volName
    echo !count!^) %%a^(!volName!^) have !FreeMB!MB^(!freeGB!GB^) free ^(!Percentage!%% free^)	
	)
	)	
)

REM :CH_DRIVE

echo Which unit do you want to use for backups? 
SET /P ch="Choose a number (Press q to exit):"
if %ch% EQU q (GOTO :EXIT)
echo ON
if %ch% gtr %count% ( 
 echo Incorrect number %ch%!!
 GOTO :EXIT
)

if "!mapArray[%ch%]!"=="%systemdrive%" ( 
   GOTO :CH_FSCHECK
)

echo !mapArray[%ch%]! is going to be the disk to save the backups.
set BDRIVE=!mapArray[%ch%]!
GOTO :CH_INSTALL



:CH_FSCHECK
SET /P input="Are you sure you want to partitionate %systemdrive%? (Y/N):"
if /I "%input%"!="Y" ( GOTO :EXIT)

fsutil dirty query %systemdrive% | find "no" > NUL
IF %ERRORLEVEL% NEQ 0 (
 echo You need to reboot your computer to do a filesystem check^(fsck^).
 echo Reboot and then launch again this executable.
 set /p input="Do you want to reboot the PC right now? (Y/N):".
 if /I "%input%"=="Y" ( shutdown -r -t 2 -c "Rebooting for filesystem check") 
 GOTO :EXIT
)else (
  REM echo Your filesystem is clean, not need fsck.
  echo Defragmenting the disk for partitioning. This will take some time. Be patient!! 
  echo Press a key to start or close the command for exit.
  pause > nul
  defrag %systemdrive% -v
  set BDRIVE=%systemdrive%
  GOTO :CH_GPARTED
)

REM THERE ISN´T AN EXTRA UNIT WITH ENOUGH FREE SPACE TO ALLOCATE ALMOST A BACKUP
REM MUST PARTITIONATE THE CURRENT UNIT TO CREATE ANOTHER UNIT FROM THE FREE SPACE
:CH_GPARTED
if not exist %systemdrive%\easyPcRecovery\clonezilla mkdir %systemdrive%\easyPcRecovery\clonezilla
if not exist %systemdrive%\easyPcRecovery\gparted mkdir %systemdrive%\easyPcRecovery\gparted
if not exist %systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted.bin(
 echo Saving MBR to %systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted.bin
 easyPcRecovery\mbrfix\mbrfix.exe /drive 0 savembr %systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted.bin
)
echo Preparing menu
copy /Y /V easyPcRecovery\menus\menu-gparted.lst %systemdrive%\menu.lst
copy /Y /V easyPcRecovery\menus\grldr %systemdrive%\
copy /Y /V easyPcRecovery\clonezilla\hotkey %systemdrive%\easyPcRecovery\clonezilla
xcopy \easyPcRecovery\gparted %systemdrive%\easyPcRecovery\gparted /s /e /k /y
echo Installing Gparted on MBR
\easyPcRecovery\clonezilla\grubinst.exe --skip-mbr-test (hd0) --save=%systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted-grub.bin  --force-backup-mbr
if %ERRORLEVEL% NEQ 0 ( 
  echo Something was wrong with grubinst.exe
  echo You have backup in 2 places:
  echo %systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted.bin  (mbrfix)
  echo %systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted-grub.bin  (grub)   
  echo You can run: 
  echo %systemdrive%\easyPcRecovery\mbrfix\mbrfix.exe /drive 0 restorembr %systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted.bin  
  echo or
  echo %systemdrive%\easyPcRecovery\clonezilla\grubinst.exe --skip-mbr-test (hd0) --restore=%systemdrive%\easyPcRecovery\gparted\mbr-pre-gparted-grub.bin
  echo or even
  echo  %systemdrive%\easyPcRecovery\clonezilla\grubinst.exe --skip-mbr-test (hd0) --restore-prevmbr
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
SET /P input="Are you sure you want to install into %bdrive%? (Y/N):"
if /I "%input%"!="Y" ( GOTO :EXIT)

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
if not exist %systemdrive%\easyPcRecovery\gparted\mbr-pre-install.bin(
 echo Saving MBR to %systemdrive%\easyPcRecovery\gparted\mbr-pre-install.bin
 easyPcRecovery\mbrfix\mbrfix.exe /drive 0 savembr %systemdrive%\easyPcRecovery\gparted\mbr-pre-install.bin
)

easyPcRecovery\clonezilla\grubinst.exe --skip-mbr-test (hd0) --save=%systemdrive%\easyPcRecovery\gparted\mbr-pre-install-grub.bin  --force-backup-mbr
if  %ERRORLEVEL% NEQ 0 ( 
  echo Something was wrong with grubinst.exe
  echo You have backup in 2 places:
  echo %systemdrive%\easyPcRecovery\gparted\mbr-pre-install.bin  (mbrfix)
  echo %systemdrive%\easyPcRecovery\gparted\mbr-pre-install-grub.bin  (grub)   
  echo You can run: 
  echo %BDRIVE%\easyPcRecovery\mbrfix\mbrfix.exe /drive 0 restorembr %systemdrive%\easyPcRecovery\gparted\mbr-pre-install.bin  
  echo or
  echo %BDRIVE%\easyPcRecovery\clonezilla\grubinst.exe --skip-mbr-test (hd0) --restore=%systemdrive%\easyPcRecovery\gparted\mbr-pre-install-grub.bin
  echo or even
  echo  %BDRIVE%\easyPcRecovery\clonezilla\grubinst.exe --skip-mbr-test (hd0) --restore-prevmbr
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