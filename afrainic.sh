#!/bin/bash
# Prepara el entorno de ejecucion

GRALOG="./gralog.sh"

MAE="MAEDIR" # utilizar el path correspondiente
CDP="${MAE}"/"CdP.mae"
CDA="${MAE}"/"CdA.mae"
CDC="${MAE}"/"CdC.mae"
AGE="${MAE}"/"agentes.mae"
TLL="${MAE}"/"tllama.tab"
UMB="${MAE}"/"umbral.tab"

function msjLog() {
  local MOUT=$1
  local TIPO=$2
  echo "${MOUT}"
  $GRALOG "$0" "$MOUT" "$TIPO"
}

function existeArch() {
  local FILE=$1
  local COMPLETA=0
  if [ ! -f "$FILE" ]; then
    MOUT="El archivo \"${FILE}\" no existe"
    msjLog "$MOUT" "ERR"
    COMPLETA=1
  fi
  return "$COMPLETA"
}

function noPermisos() {
  local FILE=$1
  MOUT="El archivo \"${FILE}\" no tiene los permisos necesarios"
  msjLog "$MOUT" "ERR"
}

function setPermisosLectura() {
  chmod +r "$1"
}

# Verifica que la instalacion esta completa
# Devuelve 0 si esta completa, 1 si no
function verificarInstalacion() {
  archivos=("$CDP" "$CDA" "$CDC" "$AGE" "$TLL" "$UMB")
  local COMPLETA=0
  for ARCH in "${archivos[@]}"
  do
    existeArch "$ARCH"
    existe=$?
    COMPLETA=$((COMPLETA + existe))
  done

  if [ "$COMPLETA" -le 6 ]
  then # algo no esta instalado
    return 1
  else
    return 0
  fi
}

# Verifica los permisos
function verificarPermisos() {
  # a los de lectura se los seteo automaticamente?
}

##############################

verificarInstalacion
instalacionRtado=$?
if [ "$instalacionRtado" == 1 ]; then
  echo "La instalacion no esta completa"
  exit 1
fi
