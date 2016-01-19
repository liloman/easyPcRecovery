@echo OFF
pushd %~dp0
SetLocal EnableDelayedExpansion
set count=0

echo Scaning for removable disks
for /F "tokens=1" %%a in ('wmic logicaldisk where "drivetype=2" get DeviceID^| find ":"') do (
   For /f "usebackq delims=, tokens=2" %%x in (`wmic logicaldisk where "DeviceID='%%a'" get volumeName /format:csv`) do SET volName=%%x
	set /a count+=1
	set mapArray[!count!]=%%a	
    REM remove trailing spaces
    CALL :TRIM !volName! volName
	CALL :TRIM %%a a
    echo !count!^) %%a^(!volName!^)	
)	

if %count%==0 ( 
 echo Insert any removable disk and excute it again. 
 GOTO :EXIT; 
)

echo Which removable disk do you want to use for backups? 
SET /P ch="Choose a number (Press q to exit):"
if %ch% EQU q (GOTO :EXIT)

if %ch% gtr %count% ( 
 echo Incorrect number %ch%!!
 GOTO :EXIT
)

set BDRIVE=!mapArray[%ch%]!
REM remove trailing spaces
CALL :TRIM !bdrive! bdrive 

echo Copying menus to %bdrive%
copy /Y /V easyPcRecovery\menus\*.lst %bdrive%\
copy /Y /V easyPcRecovery\menus\grldr %bdrive%\

REM Copy files to the backup drive
echo Copying files to %BDRIVE%...
xcopy . %BDRIVE%\ /s /e /k /y

cd /D %BDRIVE%\easyPcRecovery

REM Download
echo Downloading the ISOs
bin\wget -nc -i bin\urls.txt

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
move /Y slitaz*.iso extras\slitaz\slitaz.iso

echo Deleting zips...
del *.zip

echo Installing MBR into %bdrive%...
if not exist %bdrive%\easyPcRecovery\mbrbackups mkdir %bdrive%\easyPcRecovery\mbrbackups

REM Get diskId
for /F "skip=3 tokens=1-9  delims=#," %%a in ('cscript bin\getDiskId.vbs %bdrive%') do set diskId=hd%%b

clonezilla\grubinst.exe --save=%bdrive%\easyPcRecovery\mbrbackups\mbr-pre-install-grub.bin  --no-backup-mbr (%diskId%)

if  %ERRORLEVEL% NEQ 0 ( 
  echo.
  echo.
  echo Something was wrong with grubinst.exe
  echo You have a backup: in:
  echo %bdrive%\easyPcRecovery\mbrbackups\mbr-pre-install-grub.bin    
  echo You can run: 
  echo %BDRIVE%\easyPcRecovery\clonezilla\grubinst.exe --restore=%bdrive%\easyPcRecovery\mbrbackups\mbr-pre-intall-grub.bin  ^(%diskId%^) 
  pause 
  GOTO :EXIT
 )

echo Now you can boot the pc with the removable disk inserted to boot easyPcRecovery.
echo if you have only an unit you could boot to gparted and do the partitioning there,
echo you can even set the hidden flag for the new partition if you want it.

pause 


exit /b

:TRIM
SET %2=%1
GOTO :EOF

:EXIT
echo Exit
pause
exit /B

