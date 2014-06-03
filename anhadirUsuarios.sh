#!/bin/bash

#Comprobamos que se pase el número de parámetros correcto
if [ $# -ne 1 ]
then
        echo "[ERROR] Número de argumentos inválido"
        echo "Uso: ./anhadirusuario.sh <fichero_de_entrada>"
        exit 1
fi

#Si el fichero de entrada no existe lanzamos un error y salimos
if [[ ! -f $1 ]]
then
        echo "[ERROR] Fichero $1 no encontrado"
        exit 1
fi

if [ -f usuarios_temp.txt ]
then
        rm usuarios_temp.txt
fi

#Leemos por teclado el password con el que se crearán los usuarios
echo "Bienvenido al programa de creación de usuarios."
echo "Se crearán los siguientes usuarios en el SFTP: $(cat $1 | tr '\n' ' ')"
echo -e "¿Está de acuerdo? [s/N]: \c "
read siOno
if [ "$siOno" = "s" ]
then
        echo "[OK]"
else
        echo "[ABORTANDO...]"
        exit 1
fi

echo -e "Por favor, introduzca la contraseña con la que se crearán las cuentas: \c "
read contrasenha
#Creamos el fichero para newusers
for usuario in $(cat $1)
do
        echo "$usuario:$contrasenha::sftp::/var/mountpoint/$usuario:/sbin/nologin" >> usuarios_temp.txt
done

#Creamos los usuarios
newusers usuarios_temp.txt

#Modificamos los permisos para que encaje con los requisitos de chroot
for directorio_home in $(cat $1)
do
        chown root:root /var/mountpoint/$directorio_home
        chmod 755 /var/mountpoint/$directorio_home
        #Creamos los directorios para UL y DL
        mkdir /var/mountpoint/$directorio_home/FROM
        mkdir /var/mountpoint/$directorio_home/TO
        #Los asignamos al propietario y grupo
        chown root:sftp /var/mountpoint/$directorio_home/FROM
        chown root:sftp /var/mountpoint/$directorio_home/TO
        #Asignamos los permisos
        chmod 775 /var/mountpoint/$directorio_home/FROM
        chmod 755 /var/mountpoint/$directorio_home/TO
done

rm usuarios_temp.txt
