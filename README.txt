(PARA INSTRUCCIONES EN CASTELLANO IR MAS ABAJO)

ENGLISH
=====================

Prerequisites:
Execute INSTALL.bat(Windows) or install.sh (Linux)

==========
INSTALL ON HD
0-Create a partition/drive with GParted(include) to save backups with enough space to them (they take less than half of used space of the source disk cause it uses compression)
1-Copy everything less extras* to d:\ (or the drive you´ll use for backups)
2-(Optional) Copy extras folder and extras.lst if you want them*
3-Double click on clonezilla/installGrub4dos.cmd
4-Click on hide.cmd to hide everything...
5-Reboot and check out the menu
6-If you want to make the partition/drive hidden for Windows  use Gparted to set the flag "hidden"

INSTALL ON CD
1-Copy everything less extras* to c:\EasyWindowsRescue
2-(Optional) Copy extras folder and extras.lst if you want them*
3-Copy the ISO directory to C:, open a cmd (Start -> Execute cmd) and type:
cd C:\ISO
makegrub4dosiso.cmd easyWindowsRescue.iso c:\EasyWindowsRescue  easyWindowsRescue
4-Burn the iso to a CD and boot the pc with it inside the caddy 
5-Create a partition/drive with GParted(include) to save backups with enough space to them (they take less than half of used space of the source disk cause it uses compression)
6-If you want to make the partition/drive hidden for Windows  use Gparted to set the flag "hidden"

INSTALL ON USB
1-Copy everything less extras* to c:\EasyWindowsRescue
2-(Optional) Copy extras folder and extras.lst if you want them*
3-Copy the ISO directory to C:, open a cmd (Start -> Execute cmd) and type:
cd C:\ISO
makegrub4dosiso.cmd easyWindowsRescue.iso c:\EasyWindowsRescue  easyWindowsRescue
4-Plug the pendrive in,click on unetbootin-windows-608.exe and install easyWindowsRescue.iso on the USB (It doesn't delete anything)
5-Create a partition/drive with GParted(include) to save backups with enough space to them (they take less than half of used space of the source disk cause it uses compression)
6-If you want to make the partition/drive hidden for Windows  use Gparted to set the flag "hidden"

*Boot from USB even if your BIOS doesn´t allow it,Windows XP Recovery console,Windows VIsta/7 Boot, Boot Slitaz 4.0,boot from CD.


FAQ
===========
*Can i have backups for Windows Vista/Linux o other systems?
Of course, you just have to change in submenu.lst the lines than set the disks for whatever you want

*What are F3,F2... that I see on the titles?
They are shortcuts, you can use arrow keys or just function keys (F3...)

*I have installed it but I can't read anything
You have to press F4 when the system is booting to get to the hidden menu

*How can I go to the former menu?
Escape key

*Can I use it to boot from USB even if the BIOS doesn't allowed me to do it?
Of course, press F4, then F9 and at least F7 or using the arrow keys

*Can I change/add a new ISO, change the title or change some parameter?
Absolutely!, just open the .lst one and change whatever you want and automagically then changes will be shown on the next reboot

*I don't want it anymore. How can I uninstall it?
See http://support.microsoft.com/kb/289022

*Emm, I haven't copied the extras folder and it's still on the submenu
You can edit submenu.lst and delete the last two lines to make it go for good




CASTELLANO
=====================

Prerequisitos generales:
Ejecutar download.sh

==========
PARA INSTALAR EN HD
0-Crear una partición/disco con Gparted (incluido) para almacenar los backups con espacio suficiente para albergar el backup (ocupa menos de la mitad del espacio ocupado del disco de origen porque utiliza compresión). 
1-Copiar todo menos extras* a d:\ (o la unidad para los backups)
2-(Opcional) Copiar la carpeta extras y extras.lst si los quieres*
3-Hacer doble click en clonezilla/installGrub4dos.cmd
4-Click en hide.cmd para esconder todo ...
5-Reboot y  comprobar el menu
6-Si quiere que la particion no aparezca en Windows pongale la flag hidden con Gparted

PARA INSTALAR EN CD
1-Copiar todo menos extras* a c:\EasyWindowsRescue
2-(Opcional) Copiar la carpeta extras y extras.lst si los quieres*
3-Copiar el directorio ISO a la unidad C:, abrir un cmd (Inicio -> ejecutar  cmd) y escribir:
cd C:\ISO 
makegrub4dosiso.cmd easyWindowsRescue.iso c:\EasyWindowsRescue  easyWindowsRescue
4-Grabar la iso generada a un CD y arrancar el ordenador con el metido
5-Crear una partición/disco con Gparted (incluido) para almacenar los backups con espacio suficiente para albergar el backup (ocupa menos de la mitad del espacio ocupado del disco de origen porque utiliza compresión)
6-Si quiere que la particion no aparezca en Windows pongale la flag hidden con Gparted

PARA INSTALAR EN USB
1-Copiar todo menos extras* a c:\EasyWindowsRescue
2-(Opcional) Copiar la carpeta extras y extras.lst si los quieres*
3-Copiar el directorio ISO a la unidad C:, abrir un cmd (Inicio -> ejecutar  cmd) y escribir:
cd C:\ISO 
makegrub4dosiso.cmd easyWindowsRescue.iso c:\EasyWindowsRescue  easyWindowsRescue
4-Inserta el pendrive, doble click sobre unetbootin-windows-608.exe e instalar la easyWindowsRescue.iso en el USB (no requiere formateo)
5-Reiniciar con el pendrive metido y la BIOS configurada para arrancar desde este
5-Crear una partición/disco con Gparted (incluido) para almacenar los backups con espacio suficiente para albergar el backup (ocupa menos de la mitad del espacio ocupado del disco de origen porque utiliza compresión)
6-Si quiere que la particion no aparezca en Windows pongale la flag hidden con Gparted


*Arrancar desde USB aunque la BIOS no lo permita o forzar USB2.0,consola de recuperacion de windows XP, arrancar Windows Vista/7,Slitaz 4.0,arrancar desde CD


FAQ
===========
*¿Sirve para hacer los backups en Windows Vista/Linux o cualquier otro sistema?
Por supuesto, solo tienes que cambiar en submenu.lst las lineas que establecen las unidades por lo que quieras

*¿Que son los F3, F2... que veo en los titulos?
Son las teclas de acceso rapido, puedes utilizar las flechas de dirección o directamente las teclas de funcion (F3...)

*Lo he instalado pero no me da tiempo a leer lo que pone al arrancar
Tienes que pulsar F4 cuando el sistema esté arrancando para acceder al menu escondido

*¿Como vuelvo al menu anterior?
Con la tecla Escape

*¿Puedo usarlo para arrancar el ordenador por USB aunque no me lo permita la BIOS?
Por supuesto, tienes que pulsar F4, luego F9 y por ultimo F7 o bien usando las flechas de dirección


*¿Puedo cambiar/agregar una nueva ISO,cambiar un titulo o modificar algun parametro?
¡¡Absolutemente!!. Simplemente abre el .lst correspondiente y cambia lo que te apetezca y automaticamente se mostraran los cambios en el proximo reinicio

*No lo quiero usar mas. ¿Como puedo desinstalarlo?
Tienes que borrarlo del cargador de arranque de Windows (boot.ini)
http://support.microsoft.com/kb/289022

*Emmm, No he copiado la carpeta extras y me siguen apareciendo en el submenu
Puedes editar el archivo submenu.lst y eliminar las dos ultimas lineas y ya no apareceran mas


