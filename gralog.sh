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

LOGINST=`pwd`/afrainst.log	

TRUNCO=50				# lineas que me guardo al truncar

bytes=1024

CMDO2=`echo $CMDO | sed "s/^.*\/\([a-z]*\).sh$/\1/"`
FILE="${LOGDIR}"/"${CMDO2}"."${LOGEXT}"

WHEN=`date +%T-%d-%m-%Y`
WHO=${USER}

#ARCHLOG=$LOGDIR/$CMDO2.$LOGEXT # archivo temporal para probar logs

# El caso de instalación es una excepción
if [ $CMDO = "./afrainst.sh" ]; then
	#grabo en el log de afrainst
 	echo $WHEN - $WHO - $CMDO - $TIPO - $MSJE >> $LOGINST
else
	# Si el tamanio del archivo de log es mayor que $LOGSIZE
	# Me quedo con las ultimas $TRUNCO lineas
	tamaniomaximo=$((${LOGSIZE} * ${bytes}))	# tamanio maximo en bytes
	if [ -f $FILE ];then      
		tamanioactual=$(wc -c <"$FILE")		
	fi
	if [[ "${tamanioactual}" -ge "${tamaniomaximo}" ]]; then
	  sed -i "1,$(($(wc -l $FILE|awk '{print $1}') - $TRUNCO)) d" $FILE
	  echo $WHEN - $WHO - $CMDO - "INFO" - "Log Excedido" >> $FILE 
	fi

	echo $WHEN - $WHO - $CMDO - $TIPO - $MSJE >> $FILE 			

fi
