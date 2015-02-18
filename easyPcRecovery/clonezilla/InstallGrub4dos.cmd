color 1f
echo off
cls
pushd %~dp0
if not exist \grldr goto :NOGRUB
if not exist \menu.lst goto :NOGRUB
if exist c:\grldr goto :GRLDR
if exist C:\menu.lst goto :MENU


echo This will install grub4dos to your hard disk Master Boot Record
echo.
set /P SET ANS=OK to proceed (Y/N) : 
if /I "%ANS%"=="N" goto :EOF
grubinst.exe -v --skip-mbr-test (hd0)
if errorlevel 1 pause


:NOGRUB
echo Please ensure that the files grldr and menu.lst exist
echo on this backup partition in the root and then run this again!
pause
goto :EOF

:GRLDR
echo C:\GRLDR exists! - you may already have grub4dos installed?
echo If you are sure you don't have grub4dos already installed
echo then please delete C:\grldr and try this again.
pause
goto :EOF

:MENU
echo C:\MENU.LST exists! - you may already have grub4dos installed?
echo If you are sure you don't have grub4dos already installed
echo then please delete C:\MENU.LST and try this again.
pause
goto :EOF
