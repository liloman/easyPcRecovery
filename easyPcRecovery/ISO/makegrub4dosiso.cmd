@echo off
:: ver 3 - 1 January 2013  SSi

color 1f
pushd %~dp0

set BOOTFILE=grldr

set ISONAME=%1
set SRCFOLDER=%2
set VNAME=%3
if "%VNAME%"=="" set VNAME=G4DOS
set CF=
if exist %SRCFOLDER%\%BOOTFILE% copy %SRCFOLDER%\%BOOTFILE% . >nul && set CF= (%BOOTFILE% from %SRCFOLDER% used)
if NOT exist %SRCFOLDER%\%BOOTFILE% copy %BOOTFILE% %SRCFOLDER%\%BOOTFILE% >nul && set CF= (%~dp0%BOOTFILE% used)

cls
echo.
echo MAKE A GRUB4DOS BOOTABLE ISO FILE (from a grub4dos bootable USB drive)
echo ======================================================================
echo.
echo Variable 1 = ISO FILENAME    = %ISONAME%
echo Variable 2 = SOURCE FOLDER   = %SRCFOLDER% 
echo Variable 3 = ISO VOLUME NAME = %VNAME% 
echo              BOOTFILE        = %SRCFOLDER%\%BOOTFILE% %CF%
echo.
if "%ISONAME%"==""   echo Usage: %0 [ISO FILENAME] [SOURCE FOLDER]  [ISO VOLUME NAME] && goto :EOF
if "%SRCFOLDER%"=="" echo Usage: %0 [ISO FILENAME] [SOURCE FOLDER]  [ISO VOLUME NAME] && goto :EOF

Echo Make %ISONAME% from %SRCFOLDER% source files
echo using %BOOTFILE% as boot file (ISO volume name=%VNAME%)
echo.
if not exist %SRCFOLDER%\nul echo %SRCFOLDER% does not exist! && goto :EOF
if not exist %BOOTFILE%      echo %BOOTFILE% does not exist! && goto :EOF

oscdimg.exe 2> t1.tmp
find /i "OSCDIMG 2" t1.tmp > nul
if not errorlevel 1 goto :OSCDIMG

if exist t1.tmp del t1.tmp > nul
mkisofs.exe 2> t1.tmp 1>nul
find /i "mkisofs: Missing" t1.tmp > nul
if errorlevel 1 goto :NO_OSCD
if exist t1.tmp del t1.tmp > nul

echo.
if not exist %SRCFOLDER%\%BOOTFILE% echo ERROR: %BOOTFILE% NOT FOUND IN %SRCFOLDER%! && goto :EOF
echo USING MKISOFS
echo.
echo OK TO EXECUTE MKISOFS COMMAND: 
echo.
echo mkisofs -v -iso-level 3 -l -D -d -J -joliet-long -r -volid "%VNAME%" -A GRLDR/MKISOFS -sysid "Win32" -b %BOOTFILE% -no-emul-boot -boot-load-seg 0x7C0 -boot-load-size 4 -allow-multidot -hide grldr -hide boot.catalog -o %ISONAME% %SRCFOLDER%
echo.
pause
     mkisofs -v -iso-level 3 -l -D -d -J -joliet-long -r -volid "%VNAME%" -A GRLDR/MKISOFS -sysid "Win32" -b %BOOTFILE% -no-emul-boot -boot-load-seg 0x7C0  -boot-load-size 4 -allow-multidot -hide grldr -hide boot.catalog -o %ISONAME% %SRCFOLDER%
goto :FIN



:OSCDIMG
echo USING OSCDIMG...
echo.
oscdimg.exe > t1.tmp > nul
find /i "OSCDIMG 2" t1.tmp > nul
if errorlevel 1 goto NO_OSCD
if exist t1.tmp del t1.tmp
echo.
echo OK TO EXECUTE OSCDIMG COMMAND:
echo oscdimg.exe -m  -n -l%VNAME% -bootdata:1#b%BOOTFILE%,e,t0x1000 %SRCFOLDER% %ISONAME%
echo.
pause
     oscdimg.exe -m  -n -l%VNAME% -bootdata:1#b%BOOTFILE%,e,t0x1000 %SRCFOLDER% %ISONAME%
:FIN
dir %ISONAME%
echo Finished!
popd
goto :EOF



:NO_OSCD
cls
if exist t1.tmp del t1.tmp > nul
echo OSCDIMG.EXE or MKISOFS.EXE is required to make an %ISONAME% ISO file!
echo.
echo OSCDIMG.EXE
echo ===========
echo Download OSCDIMG.EXE from Microsoft or install the Windows 7 WAIK.
echo.
echo OR use MKISOFS.EXE instead.
echo.
goto :NOFILE


:NOFILECLS
cls
:NOFILE
echo MKISOFS.EXE
echo ===========
echo Please get mkisofs.exe and cygwin1.dll from http://www.paraglidernc.com/Files/mkisofs2.01-bootcd.ru-cygwin.zip
echo.
goto :EOF

