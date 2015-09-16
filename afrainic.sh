#!/bin/bash
# Prepara el entorno de ejecucion

GRALOG="./gralog.sh"

CNF="CONFDIR"
BIN="BINDIR"
NOV="NOVEDIR"
ACP="ACEPDIR"
PRO="PROCDIR"
REP="REPODIR"
LOG="LOGDIR"
REC="RECHDIR"

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
  archivos=("$CDP" "$CDA" "$CDC" "$AGE" "$TLL" "$UMB")
  for ARCH in "${archivos[@]}"
  do
    chmod +r "$ARCH"
    if [ "$?" = -1  ]; then
      noPermisos "$ARCH"
    fi
  done
}

# Inicializa el ambiente
function inicializarAmbiente() {
 # echo "FLORRR"
}

# Pregunta si arranca demonio
function deseaArrancar() {
  echo "¿Desea efectuar la activación de AFRARECI? si - no"
  read respuesta
  respuesta=${respuesta,,} # lo paso a lowercase
  case $respuesta in
    "no")
      echo "NOOO"
      ;;
    "si")
      echo "SIIII"
      ;;
    *)
      echo "La respuesta debe ser \"si\" o \"no\""
      ;;
  esac
}

function mostrarYgrabar() {
  variables=("$CNF" "$BIN" "$MAE" "$NOV" "$ACP" "$PRO" "$REP" "$LOG" "$REC")
  mensajes=("Configuración" "Ejecutables" "Maestros y Tablas" "Recepción de archivos de llamadas" "Archivos de llamadas Aceptadas" "Archivos de llamadas Sospechosas" "Archivos de Reportes de llamadas" "Archivos de Log" "Archivos Rechazados")
  i=0
  for VAR in "${variables[@]}"
  do
    MSJ="Directorio de ""${mensajes[${i}]}":" $VAR"
    msjLog "$MSJ" "INFO"
    ((i+=1))
  done  
}

##############################

# 1. Verifica ambiente inicializado

# 2. Verifica instalacion completa
#verificarInstalacion
#instalacionRtado=$?
#if [ "$instalacionRtado" == 1 ]; then
#  echo "La instalacion no esta completa"
#  exit 1
#fi

# 3. Verifica permisos
#verificarPermisos

# 4. Inicializa el ambiente
#inicializarAmbiente

# 5. Muestra y graba en el log
#mostrarYgrabar

# 6. Pregunta si se desea arrancar
#deseaArrancar
