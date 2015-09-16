#!/bin/bash
# Pruebas para los scripts

MOVER="./mover.sh"

function tieneParametros() {
  $MOVER
  if [ "$?" == 1 ]
  then
    echo -e "\t\033[32m No se reciben dos parametros OK\033[0m \n"
  else
    echo -e "\t\033[31m No se reciben dos parametros ERROR\033[0m \n"
  fi
}

function existeFile() {
  $MOVER "$1" "$2"
  if [ "$?" == 1 ]
  then
    echo -e "\t\033[32m No existe archivo OK\033[0m \n"
  else
    echo -e "\t\033[31m No existe archivo ERROR\033[0m \n"
  fi
}

function existeDirectorio() {
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

#####   MOVER   #####

echo "### Pruebas para MOVER.SH ###"

FILE="prueba.txt"
DIREC="prueba"

echo "### Limpio para empezar pruebas ###"
borrarArchivo "$FILE"
borrarDirectorio "$DIREC"
borrarArchivo "log.txt"

# No le paso parametros
tieneParametros

# No existe FILE. Lo creo.
existeFile $FILE $DIREC
crearArchivo "$FILE"
existeFile $FILE $DIREC

# No existe DIREC. Lo creo.
existeDirectorio $FILE $DIREC
crearDirectorio ${DIREC}

# Origen y Destino son iguales
# de este no estoy segura
origenIgualDestino $FILE $PWD

# falta probar DUPLICADOS
