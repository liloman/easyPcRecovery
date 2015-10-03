@echo OFF
pushd %~dp0
SetLocal EnableDelayedExpansion

echo Copying menus to %cd%
copy /Y /V easyPcRecovery\menus\*.lst .
copy /Y /V easyPcRecovery\menus\grldr .

cd easyPcRecovery

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
move /Y slitaz*.iso extras\slitaz

echo Deleting zips...
del *.zip

cd ..
call EasyPcRecovery\ISO\makegrub4dosiso.cmd easyPcRecovery.iso %cd%  easyPcRecovery
pause 
move \EasyPcRecovery\ISO\easyPcRecovery.iso .

echo.
echo.
echo You can record %cd%easyPcRecovery.iso on a CD (software not included)
echo and then boot the pc with it inserted in the tray
echo to boot easyPcRecovery.
echo if you only have one unit you could boot to gparted and do the partitioning there,
echo even you can set the hidden flag for the new partition if you want it.

pause 


exit /b

