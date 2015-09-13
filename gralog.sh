#!/bin/bash
# Registro oficial de logs
# $1 comando que lo invoca
# $2 mensaje
# $3 tipo de mensaje

# Revisa que se reciben si o si dos parametros
if [ $# -lt 2 ]; then
  echo "Se deben ingresar al menos dos parametros"
  exit 1
fi

CMDO=$1
MSJE=$2
TIPO=$3

LOGSIZE=3      # longitud maxima
LOGDIR="logs/" # directorio de logs ES LA $LOGDIR DE CONFIGURACION
LOGEXT=".log"  # extension de logs
FILE="${CMDO%%.*}""${LOGEXT}"
WHEN=`date +%T-%d-%m-%Y`
WHO=${USER}

TEMP="log.txt" # archivo temporal para probar logs

if [ $LOGDIR = "inst" ]; then
  echo "Cargar en directorio de instalacion"
  # directorio de instalacion
fi

echo $WHEN , $WHO , $CMDO, $TIPO, $MSJE >> $TEMP # reemplazar aca por FILE


