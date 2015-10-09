#!/bin/bash
# Pruebas para los scripts

MOVER="./mover.sh"

function noTieneParametros() {
  $MOVER
  if [ "$?" == 1 ]
  then
    echo -e "\t\033[32m No se reciben dos parametros OK\033[0m \n"
  else
    echo -e "\t\033[31m No se reciben dos parametros ERROR\033[0m \n"
  fi
}

function noExisteFile() {
  $MOVER "$1" "$2"
  if [ "$?" == 1 ]
  then
    echo -e "\t\033[32m No existe archivo OK\033[0m \n"
  else
    echo -e "\t\033[31m No existe archivo ERROR\033[0m \n"
  fi
}

function noExisteDirectorio() {
  $MOVER "$1" "$2"
  if [ "$?" == 1 ]
  then
    echo -e "\t\033[32m No existe directorio OK\033[0m \n"
  else
    echo -e "\t\033[31m No existe directorio ERROR\033[0m \n"
  fi
}

function origenIgualDestino() {
  $MOVER "$1" "$2"
  if [ "$?" == 1 ]
  then
    echo -e "\t\033[32m Origen y destino iguales OK\033[0m \n"
  else
    echo -e "\t\033[31m Origen y destino iguales ERROR\033[0m \n"
  fi
}

function borrarArchivo() {
  if [ -f "$1" ]; then
    echo -e "\n\t - El archivo ${1} ha sido borrado\n"
    rm "$1"
  fi
}

function borrarDirectorio() {
  if [ -d "$1" ]; then
    echo -e "\n\t - El directorio ${1} ha sido borrado\n"
    rm -rf "$1"
  fi
}

function crearArchivo() {
  echo -e "\n\t - Creando archivo \"${1}\" \n"
  echo "Probando" > "$1"
}

function crearDirectorio() {
  echo -e "\n\t - Creando directorio \"${1}\" \n"
  mkdir "$1"
}

function estaFile() {  
  if [ -f "$1" ]; then
    echo -e "\n\t - El archivo ${1} esta en el directorio \n"
  else
    echo -e "\n\t - El archivo ${1} NO esta en el directorio \n"
  fi
}

function estaDirectorio() {
  if [ -d "$1" ]; then
    echo -e "\n\t - El directorio ${1} esta \n"
  else
    echo -e "\n\t - El directorio ${1} NO esta \n"
  fi
}

#####   MOVER   #####

echo "### Pruebas para MOVER.SH ###"

FILE="prueba.txt"
DIREC="prueba"

echo "### Limpio para empezar pruebas ###"
borrarArchivo "$FILE"
borrarDirectorio "$DIREC"
#borrarArchivo "log.txt"

# No le paso parametros
noTieneParametros

# No existe FILE. Lo creo.
estaFile $FILE
noExisteFile $FILE $DIREC
crearArchivo "$FILE"
estaFile $FILE

# No existe DIREC. Lo creo.
estaDirectorio $DIREC
noExisteDirectorio $FILE $DIREC
crearDirectorio $DIREC
estaDirectorio $DIREC

# Origen y Destino son iguales
origenIgualDestino $FILE `direc ${0}` # de este no estoy segura

estaFile "$DIREC"/"$FILE"
$MOVER "$FILE" "$DIREC" "./afrainst.sh"	# solo se graba en el log si el comando que invoca registra en log
estaFile "$DIREC"/"$FILE"
estaDirectorio "$DIREC"/duplicados
crearArchivo "$FILE"
$MOVER "$FILE" "$DIREC"
estaDirectorio "$DIREC"/duplicados
estaFile $DIREC/duplicados/$FILE

# Pruebo la secuencia NNN en duplicados
crearArchivo "$FILE"
$MOVER "$FILE" "$DIREC"
crearArchivo "$FILE"
$MOVER "$FILE" "$DIREC"
crearArchivo "$FILE"
$MOVER "$FILE" "$DIREC"

