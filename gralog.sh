#!/bin/bash
# Registro oficial de logs
# $1 comando que lo invoca
# $2 mensaje

# Revisa que se reciben si o si dos parametros
if [ $# -lt 2 ]; then
  echo "Se deben ingresar al menos dos parametros"
  # salir
fi

CMDO=$1
MSJE=$2
LOGDIR="logs" # directorio de logs
LOGEXT=".log" # extension de logs
LOGSIZE=3
FILE="${CMDO}""${LOGEXT}"
WHEN=`date +%T-%d-%m-%Y`
WHO=${USER}

echo $WHEN
echo $FILE
echo $WHO

TEMP="log.txt" # archivo temporal para probar logs

# Si el archivo no esta creado, lo crea
if [ ! -f "$TEMP" ]; then
  echo "Archivo \"${TEMP}\" ha sido creado"
  echo $WHEN , $WHO , $CMDO, $MSJE >> $FILE
fi
