@echo off
:: ver 3 - 1 January 2013  SSi

pushd %~dp0

set BOOTFILE=grldr

set ISONAME=%1
set SRCFOLDER=%2
set VNAME=%3
if "%VNAME%"=="" set VNAME=G4DOS
set CF=
if exist %SRCFOLDER%\%BOOTFILE% copy %SRCFOLDER%\%BOOTFILE% . >nul && set CF= (%BOOTFILE% from %SRCFOLDER% used)
if NOT exist %SRCFOLDER%\%BOOTFILE% copy %BOOTFILE% %SRCFOLDER%\%BOOTFILE% >nul && set CF= (%~dp0%BOOTFILE% used)

REM echo.
REM echo MAKE A GRUB4DOS BOOTABLE ISO FILE (from a grub4dos bootable USB drive)
REM echo ======================================================================

if "%ISONAME%"==""   echo Usage: %0 [ISO FILENAME] [SOURCE FOLDER]  [ISO VOLUME NAME] && goto :EOF
if "%SRCFOLDER%"=="" echo Usage: %0 [ISO FILENAME] [SOURCE FOLDER]  [ISO VOLUME NAME] && goto :EOF

REM Echo Make %ISONAME% from %SRCFOLDER% source files
REM echo using %BOOTFILE% as boot file (ISO volume name=%VNAME%)

if not exist %SRCFOLDER%\nul echo %SRCFOLDER% does not exist! && goto :EOF
if not exist %BOOTFILE%      echo %BOOTFILE% does not exist! && goto :EOF
if not exist %SRCFOLDER%\%BOOTFILE% echo ERROR: %BOOTFILE% NOT FOUND IN %SRCFOLDER%! && goto :EOF

REM echo USING MKISOFS COMMAND
echo Creating %ISONAME% file. Please be patient
echo mkisofs -quiet slitaz-*.iso -m *.zip  -iso-level 3 -l -D -d -J -joliet-long -r -volid "%VNAME%" -A GRLDR/MKISOFS -sysid "Win32" -b %BOOTFILE% -no-emul-boot -boot-load-seg 0x7C0 -boot-load-size 4 -allow-multidot -hide grldr -hide boot.catalog -o %ISONAME% %SRCFOLDER%
REM echo.

mkisofs -quiet -m *.iso -m *.zip  -iso-level 3 -l -D -d -J -joliet-long -r -volid "%VNAME%" -A GRLDR/MKISOFS -sysid "Win32" -b %BOOTFILE% -no-emul-boot -boot-load-seg 0x7C0  -boot-load-size 4 -allow-multidot -hide grldr -hide boot.catalog -o %ISONAME% %SRCFOLDER%
echo Finished!
popd
exit /B
cmd /c exit -1073741510
