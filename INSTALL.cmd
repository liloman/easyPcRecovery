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

echo Where do you want to install it? 
echo 1)HD
echo 2)Pendrive
echo 3)CD
SET /P OPTDEST="Choose a number (Press q to exit):"
if %OPTDEST% EQU q (GOTO :EXIT)

if %OPTDEST% equ 1 GOTO :OPT_HD
if %OPTDEST% equ 2 GOTO :OPT_PEN
if %OPTDEST% equ 3 GOTO :OPT_CD

echo Incorrect number %OPTDEST%!!
GOTO :ERROR

REM INSTALL ON HD
:OPT_HD
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
  set /a count+=1
  set mapArray[!count!]=%systemdrive%
  set /a Percentage=^(100 * totalFreeMB^) / SizeMB	
  echo 0^) %systemdrive% have !totalFreeMB!MB^(!totalFreeGB!GB^) free ^(!Percentage!%% free^) ^-^-^> WARNING: Needs partitioning
)
	
REM echo Scaning for other disks/partitions...
for /F "tokens=1-2" %%a in ('wmic logicaldisk get DeviceID^, DriveType^| find ":"') do (
   if %%b NEQ 5 if not "%%a"=="%systemdrive%" (
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get FreeSpace /format:value`) do set FreeSpace=%%x
   For /f "usebackq delims== tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get Size /format:value`) do set Size=%%x
   For /f "usebackq delims=, tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get volumeName /format:csv`) do SET volName=%%x
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
	CALL :TRIM %%a a
    echo !count!^) %%a^(!volName!^) have !FreeMB!MB^(!freeGB!GB^) free ^(!Percentage!%% free^)	
	)
	)	
)

if %count%==0 ( 
 echo You don´t have any unit with enough free space. 
 goto :ERROR; 
)

echo Which unit do you want to use for backups? 
SET /P ch="Choose a number (Press q to exit):"
if %ch% EQU q (GOTO :EXIT)

if %ch% gtr %count% ( 
 echo Incorrect number %ch%!!
 GOTO :ERROR
)

if "!mapArray[%ch%]!"=="%systemdrive%" ( 
   GOTO :CH_FSCHECK
)

set BDRIVE=!mapArray[%ch%]!
REM remove trailing spaces
CALL :TRIM !bdrive! bdrive 

GOTO :CH_INSTALL



:CH_FSCHECK
SET /P input="Are you sure you want to partitionate %systemdrive%? (Y/N):"
if /I not "%input%"=="Y" ( GOTO :EXIT)

fsutil dirty query %systemdrive% | find "no" > NUL
IF %ERRORLEVEL% NEQ 0 (
 echo You need to reboot your computer to do a filesystem check^(fsck^).
 echo Reboot and then launch again this executable.
 set /p input="Do you want to reboot the PC right now? (Y/N):".
 if /I "%input%"=="Y" ^( shutdown -r -t 5 -c "Rebooting for filesystem check" ^) 
 GOTO :EXIT
)else (
  REM echo Your filesystem is clean, not need fsck.
  echo Defragmenting the disk for partitioning. This will take some time. Be patient!! 
  echo Press a key to start or close the command for exit.
  pause > nul
  defrag %systemdrive%
  set BDRIVE=%systemdrive%
 )

REM THERE ISN´T AN EXTRA UNIT WITH ENOUGH FREE SPACE TO ALLOCATE ALMOST A BACKUP
REM MUST PARTITIONATE THE CURRENT UNIT TO CREATE ANOTHER UNIT FROM THE FREE SPACE
if not exist %systemdrive%\easyPcRecovery\mbrbackups mkdir %systemdrive%\easyPcRecovery\mbrbackups
if not exist %systemdrive%\easyPcRecovery\gparted mkdir %systemdrive%\easyPcRecovery\gparted
if not exist %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted.bin (
 echo Saving MBR to %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted.bin
 easyPcRecovery\mbrfix\mbrfix.exe /drive 0 savembr %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted.bin
)

echo Copying menu.lst and grldr to %systemdrive%
copy /Y easyPcRecovery\menus\menu-gparted.lst %systemdrive%\menu.lst  > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
copy /Y easyPcRecovery\menus\grldr %systemdrive%\ > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

if not exist gparted*.zip (
echo Downloading the Gparted iso
easyPcRecovery\bin\wget --no-check-certificate -c -q --show-progress http://downloads.sourceforge.net/project/gparted/gparted-live-stable/0.20.0-2/gparted-live-0.20.0-2-i486.zip
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
)

easyPcRecovery\bin\7za.exe e -o%systemdrive%\easyPcRecovery\gparted gparted*.zip live/*
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
move /Y gparted*.zip easyPcRecovery\
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

echo Installing Gparted on MBR
easyPcRecovery\clonezilla\grubinst.exe  --save=%systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted-grub.bin  --force-backup-mbr (hd0)
if %ERRORLEVEL% NEQ 0 ( 
  echo.
  echo.
  echo Something was wrong with grubinst.exe
  echo You have 3 backups in place:
  echo %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted.bin  ^(mbrfix^)
  echo %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted-grub.bin  ^(grub^)   
  echo Your second sector on your hard disk ^(grub^)
  echo You can restore the old mbr (into the directory you downloaded this software) with ANY of this: 
  echo easyPcRecovery\mbrfix\mbrfix.exe /drive 0 restorembr %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted.bin  
  echo OR
  echo easyPcRecovery\clonezilla\grubinst.exe --restore=%systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted-grub.bin  ^(hd0^) 
  echo OR even
  echo easyPcRecovery\clonezilla\grubinst.exe --restore-prevmbr ^(hd0^) 
  pause 
  GOTO :EXIT
)
echo Reboot to boot gparted.
echo Remember you need AT LEAST !TotalusedMB!MB on the new partition.
echo When you´ve finished with gparted, reboot and press F4 to boot Windows again.
set /p input="Do you want to reboot the PC right now? (Y/N):".
if /I "%input%"=="Y" ( shutdown -r -t 5 -c "Rebooting for partitioning with Gparted")
exit /B

REM THERE IS AN EXTRA UNIT WITH ENOUGH FREE SPACE
:CH_INSTALL
SET /P input="Are you sure you want to install easyPcRecovery into %bdrive%? (Y/N):"
if /I not "%input%"=="Y" ( GOTO :EXIT )

REM Be sure to unhide before install to prevent error for copy hide files
@cmd /c UnHideEverything.cmd > nul
if exist %BDRIVE%\UnHideEverything.cmd (
@cmd /c %BDRIVE%\UnHideEverything.cmd > nul
)

echo Copying menu.lst and grldr to %systemdrive%\
copy /Y easyPcRecovery\menus\menu.lst %systemdrive%\  > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
copy /Y easyPcRecovery\menus\grldr %systemdrive%\  > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

if not exist %systemdrive%\easyPcRecovery mkdir %systemdrive%\easyPcRecovery
attrib +s +h %systemdrive%\*.lst
attrib +s +h %systemdrive%\grldr
attrib +s +h %systemdrive%\easyPcRecovery

REM Copy files to the backup drive
echo Copying files to %BDRIVE%...
xcopy . %BDRIVE%\ /s /k /y /q > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

cd /D %BDRIVE%\
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
REM IF INSTALLING FROM CD-ROM INSTALLATION MAKE SURE THE FLAG IS THERE 
echo Restoring backup flag 
echo. > easyPcRecovery\clonezilla\images\images_are_stored_here.txt 

REM Function for download and copy the files
:FUN_DOWN_COPY

REM Change to workdir
cd easyPcRecovery
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

REM Download ISO/zips
echo Downloading the ISOs. Be patient it will take a while. :)
bin\wget --no-check-certificate -c -q --show-progress -i bin\urls.txt
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

REM Clonezilla
echo Copying Clonezilla...
bin\7za.exe x -y -bd -oclonezilla/ clonezilla*.zip live/* > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

REM Gparted
echo Copying Gparted...
bin\7za.exe x  -y -bd -ogparted gparted*.zip live/* > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

REM Plop
echo Copying Plop...
if not exist extras mkdir extras
bin\7za.exe x  -y -bd plpbt*.zip plpbt-5.0.15/plpbt.bin > nul
if exist extras\plop rmdir /s /q extras\plop > nul
move /Y plpbt-5.0.15 extras\plop > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

REM slitaz
echo Coping Slitaz...
if not exist extras\slitaz mkdir extras\slitaz
copy /V /Y slitaz*.iso extras\slitaz\slitaz.iso > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

REM Old gparted files
if exist %systemdrive%\easyPcRecovery\gparted  (
echo Deleting old gparted installation dir
rmdir /Q /S %systemdrive%\easyPcRecovery\gparted > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
)

REM Ask to remove downloaded files
SET /P delin="Do you want to delete the downloaded files? (Y/N):"
if /I "%delin%"=="Y" (
echo Deleting downloaded zips...
del *.zip
del *.iso
)

REM Depends on the choosen option
if %OPTDEST% equ 1 set MBR=%systemdrive%
if %OPTDEST% equ 2 GOTO :OPT_PEN
if %OPTDEST% equ 3 GOTO :FINISH_CD


echo Installing MBR into %systemdrive%...
if not exist %systemdrive%\easyPcRecovery\mbrbackups mkdir %systemdrive%\easyPcRecovery\mbrbackups
if not exist %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install.bin (
 echo Saving MBR to %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install.bin
 mbrfix\mbrfix.exe /drive 0 savembr %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install.bin
 if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
)

clonezilla\grubinst.exe --save=%systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install-grub.bin  --force-backup-mbr (hd0)
if  %ERRORLEVEL% NEQ 0 ( 
  echo.
  echo.
  echo      ERROR
  echo Something was wrong with grubinst.exe
  echo You have 3 backups in place:
  echo %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install.bin  ^(mbrfix^)
  echo %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install-grub.bin  ^(grub^)   
  echo Your second sector on your hard disk ^(grub^)
  echo You can run: 
  echo %BDRIVE%\easyPcRecovery\mbrfix\mbrfix.exe /drive 0 restorembr %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-install.bin  
  echo OR 
  echo %BDRIVE%\easyPcRecovery\clonezilla\grubinst.exe --restore=%systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted-grub.bin  ^(hd0^) 
  echo OR even
  echo  %BDRIVE%\easyPcRecovery\clonezilla\grubinst.exe --restore-prevmbr ^(hd0^)
  echo IF you partitionated your hard disk before with this software you have even 2 more MBR backups:
  echo %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted.bin  ^(mbrfix^)
  echo %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted-grub.bin  ^(grub^)   
  echo You can try ONE OF THESE FIRST in this order, to get your original boot menu back: 
  echo %BDRIVE%\easyPcRecovery\mbrfix\mbrfix.exe /drive 0 restorembr %systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted.bin  
  echo or
  echo %BDRIVE%\easyPcRecovery\clonezilla\grubinst.exe --restore=%systemdrive%\easyPcRecovery\mbrbackups\mbr-pre-gparted-grub.bin ^(hd0^)
  GOTO :ERROR
 )

echo Hiding files...
cd ..
@cmd /c HideEverything.cmd > nul

echo.
echo.
echo ===============FINISHED===============
echo Reboot and make your fresh first backup right now if you want it.
echo Press F4 on the boot menu to see the avaliable options.
echo ===============FINISHED===============

pause 
EXIT /B


:OPT_CD
echo Copying menu.lst to %cd%
copy /Y  easyPcRecovery\menus\menu.lst . > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
copy /Y easyPcRecovery\menus\grldr . > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

REM Download and copy files 
GOTO :FUN_DOWN_COPY

:FINISH_CD

cd ..
echo Deleting backup flag 
del /Q easyPcRecovery\clonezilla\images\images_are_stored_here.txt > nul
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )
call EasyPcRecovery\ISO\makegrub4dosiso.cmd ..\..\easyPcRecovery.iso %cd%  easyPcRecovery
if %ERRORLEVEL% NEQ 0 (  GOTO :ERROR )

echo.
echo.
echo ===============FINISHED===============
echo You can record %cd%\easyPcRecovery.iso on a CD (software not included)
echo and then boot the pc with it inserted in the tray
echo to boot easyPcRecovery.
echo If you only have one unit you could boot to gparted and do the partitioning there,
echo even you can set the hidden flag for the new partition if you want it.
echo ===============FINISHED===============
pause 
	
EXIT /B


:ERROR
echo Something went wrong. ERRORLEVEL:%ERRORLEVEL% 
GOTO :EXIT

:TRIM
SET %2=%1
GOTO :EOF

:EXIT
echo Exiting. Press any key to exit.
pause
exit /B
cmd /c exit -1073741510
