#!/bin/bash
# Registro oficial de logs
# $1 comando que lo invoca, se pasa como $0
# $2 mensaje
# $3 tipo de mensaje

# Revisa que se reciban si o si dos parametros
if [ $# -lt 2 ]; then
  echo "Se deben ingresar al menos dos parametros"
  exit 1
fi

CMDO=$1
MSJE=$2
TIPO=$3        # INFO, WAR, ERR

# estas de abajo son variables de configuracion
# falta setearlas, estos valores son de prueba

LOGINST=`pwd`/loginst.log

LOGSIZE=10     # longitud maxima		ES $LOGSIZE
LOGDIR="logs"  # directorio de logs 		ES $LOGDIR DE CONFIGURACION
LOGEXT="log"   # extension de logs		ES $LOGEXT

TRUNCO=5       # lineas que me guardo al truncar

FILE="${LOGDIR}"/"${CMDO%%.*}"."${LOGEXT}"

WHEN=`date +%T-%d-%m-%Y`
WHO=${USER}

TEMP="log.txt" # archivo temporal para probar logs

# El caso de instalación es una excepción, verificarlo
if [ $CMDO = "afrainst.sh" ]; then
  	echo "Cargar en directorio de instalacion"
 	echo $WHEN - $WHO - $CMDO - $TIPO - $MSJE >> $LOGINST
	# directorio de instalacion
else

	# Si el tamanio del archivo de log es mayor que $LOGSIZE
	# Me quedo con las ultimas $TRUNCO lineas
	if [ $(cat log.txt | wc -l) -gt $LOGSIZE ]; then
	  sed -i "1,$(($(wc -l $TEMP|awk '{print $1}') - $TRUNCO)) d" $TEMP 	# reemplazar TEMP por FILE
	fi


	echo $WHEN - $WHO - $CMDO - $TIPO - $MSJE >> $TEMP 			# reemplazar TEMP por FILE

fi
