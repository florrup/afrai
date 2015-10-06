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

LOGINST=`pwd`/afrainst.log

LOGSIZE=$LOGSIZE     # longitud maxima		ES $LOGSIZE
LOGDIR=$LOGDIR  # directorio de logs 		ES $LOGDIR DE CONFIGURACION
LOGEXT=$LOGEXT   # extension de logs		ES $LOGEXT

TRUNCO=5       # lineas que me guardo al truncar

CMDO2=`echo $CMDO | sed "s/^.\/\([a-z]*\).sh$/\1/"`
FILE="${LOGDIR}"/"${CMDO2}"."${LOGEXT}"

WHEN=`date +%T-%d-%m-%Y`
WHO=${USER}

ARCHLOG=$LOGDIR/$CMDO.$LOGEXT # archivo temporal para probar logs

# El caso de instalación es una excepción
if [ $CMDO = "./afrainst.sh" ]; then
	#grabo en el log de afrainst
 	echo $WHEN - $WHO - $CMDO - $TIPO - $MSJE >> $LOGINST
else
	# Si el tamanio del archivo de log es mayor que $LOGSIZE
	# Me quedo con las ultimas $TRUNCO lineas
	if [ $(cat log.txt | wc -l) -gt $LOGSIZE ]; then
	  sed -i "1,$(($(wc -l $TEMP|awk '{print $1}') - $TRUNCO)) d" $FILE
	fi


	echo $WHEN - $WHO - $CMDO - $TIPO - $MSJE >> $FILE 			

fi
