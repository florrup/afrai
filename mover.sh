#!/bin/bash
# Mueve un archivo desde el origen al destino
# $1 archivo a mover
# $2 directorio destino

#Revisa que se reciban si o si dos parametros
if [ $# -lt 2 ]; then
  echo "Se deben ingresar al menos dos parametros"
  # salir
fi

FILE=$1
DEST=$2
ORIG=${PWD} # para mover el archivo hay que estar parados en su directorio

echo         #
echo "Valores de prueba"
echo "$FILE" #
echo "$DEST" #
echo "$ORIG" #
echo         #

# Revisa que el archivo a mover exista
if [ ! -f "$FILE" ]; then
  echo "El archivo a mover \"${FILE}\" no existe"
  # no muevo el archivo
  # registro en log
  # salir
fi

# Revisa que el directorio destino exista
if [ ! -d "$DEST" ]; then
  echo "El destino \"${DEST}\" no existe"
  # no muevo el archivo
  # registro en log
  # salir
fi

# Revisa si el path de origen y el de destino son iguales
if [ "$ORIG" = "$DEST" ]; then
  echo "Paths de origen y destino son iguales"
  # no muevo el archivo
  # registro en log
  # salir
fi

# Si ya existe un archivo con el mismo nombre
FILEDEST=$DEST/$FILE
echo $FILEDEST
DUPLI=$DEST/duplicados
echo $DUPLI

if [ -f "$FILEDEST" ]; then
  echo "Ya existe un archivo con ese nombre en \"${DEST}\""

  # Si no existe DUPLICADOS, lo crea
  if [ ! -d ${DUPLI} ]
  then
    mkdir ${DUPLI}
    echo "El directorio \"${DUPLI}\" ha sido creado"
  fi
  
  # Ya existe DUPLICADOS 
  # tengo que depositarlo con secuencia nnn
fi
