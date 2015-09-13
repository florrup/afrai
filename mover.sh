#!/bin/bash
# Mueve un archivo desde el origen al destino
# $1 archivo a mover
# $2 directorio destino

GRALOG="./gralog.sh"

function msjLog() {
  local MOUT=$1
  local TIPO=$2
  echo "${MOUT}" 
  $GRALOG "$0" "$MOUT" "$TIPO"
}

#Revisa que se reciban si o si dos parametros
if [ $# -lt 2 ]; then
  MOUT="Se deben ingresar al menos dos parametros para Mover"
  msjLog "${MOUT}" "ERR"  
  exit 1
fi

FILE=$1
DEST=$2
ORIG=${PWD} # para mover el archivo hay que estar parados en su directorio
# ??? de esto ^ no estoy segura

# ??? falta tomar los restantes parametros

# Revisa que el archivo a mover exista
if [ ! -f "$FILE" ]; then
  MOUT="El archivo a mover \"${FILE}\" no existe"
  msjLog "$MOUT" "ERR"
  exit 1
fi

# Revisa que el directorio destino exista
if [ ! -d "$DEST" ]; then
  MOUT="El destino \"${DEST}\" no existe"
  msjLog "$MOUT" "ERR"
  exit 1
fi

# Revisa si el path de origen y el de destino son iguales
if [ "$ORIG" = "$DEST" ]; then
  MOUT="Paths de origen y destino son iguales"
  msjLog "$MOUT" "ERR"
  exit 1
fi

# Revisa si ya existe un archivo con el mismo nombre
FILEDEST=$DEST/$FILE
DUPLI=$DEST/duplicados

if [ -f "$FILEDEST" ]; then
  MOUT="Ya existe un archivo con ese nombre en \"${DEST}\""
  msjLog "$MOUT" "WAR"
  # Si no existe DUPLICADOS, lo crea
  if [ ! -d ${DUPLI} ]
  then
    mkdir ${DUPLI}
    echo "El directorio \"${DUPLI}\" ha sido creado"
  fi
  
  # Ya existe DUPLICADOS
  if [ ! -f "$DUPLI"/"$FILE" ]; then
     mv $FILE $DUPLI
     echo "El archivo \"${FILE}\" ha sido movido a \"${DUPLI}\""
     exit 0
  else
    # tengo que depositarlo con secuencia nnn si ya se encuentra
    # ??? obligatorio usar tres digitos para esto?
    NNN=0 

    for ARCH in "${DUPLI}"/*    
    do
       if [ "${ARCH%%.*}" = "${DUPLI}"/"${FILE%%.*}" ]; then
        NNN=$((NNN+1))
      fi
    done
 
    NEWFILE="${DUPLI}"/"${FILE}"."${NNN}"
    mv "${FILE}" "${NEWFILE}"
    exit 0
  fi

else
  mv $FILE $DEST
  MOUT="El archivo \"${FILE}\" ha sido movido al directorio \"${DEST}\""
  msjLog "$MOUT" "INFO"
  exit 0
fi
