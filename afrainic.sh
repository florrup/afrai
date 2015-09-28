#!/bin/bash
# Prepara el entorno de ejecucion

GRALOG="./gralog.sh"

CNF=$PWD/"prue.txt" # usar file de configuracion

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

# Verifica si el ambiente ya ha sido inicializado
# Devuelve 1 si ya fue inicializado, 0 sino
function verificarAmbienteInicializado() {
  i=0
  variables=("$GRP" "$CON" "$BIN" "$MAE" "$DATASIZE" "$ACEP" "$RECH" "$PRO" "$REP" "$NOV" "$LOG" "$LOGSIZE")
  for VAR in "${variables[@]}"
  do
    if [[ ! -z "$VAR" ]]; then # si la variable no esta vacia es porque fue inicializado
      ((i+=1))
    fi
  done
  if [ "$i" -gt 0 ]; then
    MSJ="Ambiente ya inicializado, para reiniciar termine la sesion e ingrese nuevamente"
    msjLog "$MSJ" "ERR"
    return 1
  fi
  return 0
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

  # falta checkear si estan los scripts

  if [ "$COMPLETA" -le 6 ]
  then # algo no esta instalado
    return 1
  else
    return 0
  fi
}

# Verifica los permisos
# Devuelve 1 si no se pueden setear, 0 en caso contrario 
function verificarPermisos() {
  i=0
  archivos=("$CDP" "$CDA" "$CDC" "$AGE" "$TLL" "$UMB")
  for ARCH in "${archivos[@]}"
  do
    chmod +r "$ARCH"
    if [ "$?" = -1  ]; then
      noPermisos "$ARCH"
      ((i+=1))
    fi
  done

  # falta checkear permisos de los scripts

  if [ "$i" -ge 0 ]; then
    msjLog "No se han podido setear los permisos" "ERR"
    return 1
  fi
  return 0
}

# Inicializa el ambiente
# Setea todas las variables de ambiente
function inicializarAmbiente() {
  GRP=$(grep '^GRUPO' $CNF | cut -d '=' -f 2)
  CON=$(grep '^CONFDIR' $CNF | cut -d '=' -f 2)
  BIN=$(grep '^BINDIR' $CNF | cut -d '=' -f 2)
  MAE=$(grep '^MAEDIR' $CNF | cut -d '=' -f 2)
  DATASIZE=$(grep '^DATASIZE' $CNF | cut -d '=' -f 2)
  ACEP=$(grep '^ACEPDIR' $CNF | cut -d '=' -f 2)
  RECH=$(grep '^RECHDIR' $CNF | cut -d '=' -f 2)
  PRO=$(grep '^PROCDIR' $CNF | cut -d '=' -f 2)
  REP=$(grep '^REPODIR' $CNF | cut -d '=' -f 2)
  NOV=$(grep '^NOVEDIR' $CNF | cut -d '=' -f 2)
  LOG=$(grep '^LOGDIR' $CNF | cut -d '=' -f 2)
  LOGSIZE=$(grep '^LOGSIZE' $CNF | cut -d '=' -f 2)

  # falta setear PATH

  # permito que todas las variables sean utilizadas desde otros scripts con export
  export GRP
  export CON
  export BIN
  export MAE
  export DATASIZE
  export ACEP
  export RECH
  export PRO
  export REP
  export NOV
  export LOG
  export LOGSIZE
}

# Muestra y graba en el log variables y contenido
function mostrarYgrabar() {
  variables=("$CON" "$BIN" "$MAE" "$NOV" "$ACEP" "$PRO" "$REP" "$LOG" "$RECH")
  mensajes=("Configuración" "Ejecutables" "Maestros y Tablas" "Recepción de archivos de llamadas" "Archivos de llamadas Aceptadas" "Archivos de llamadas Sospechosas" "Archivos de Reportes de llamadas" "Archivos de Log" "Archivos Rechazados")
  i=0
  for VAR in "${variables[@]}"
  do
    MSJ="Directorio de ""${mensajes[${i}]}":" $VAR"
    msjLog "$MSJ" "INFO"
    # listar archivos si es CONFDIR, BINDIR, MAEDIR, LOGDIR
    if [ "$VAR" = "$CON" ] || [ "$VAR" = "$BIN" ] || [ "$VAR" = "$MAE" ] || [ "$VAR" = "$LOG" ] ; then
      LIST=$(ls "$VAR")
      msjLog "$LIST" "INFO"
    fi
    ((i+=1))
  done  
  msjLog "Estado del Sistema: INICIALIZADO" "INFO"
}

# Pregunta si arranca demonio
function deseaArrancar() {
  echo "¿Desea efectuar la activación de AFRARECI? si - no"
  read respuesta
  respuesta=${respuesta,,} # lo paso a lowercase
  case $respuesta in
    "no")
      echo "NOOO" # falta explicar como hacerlo con comando arrancar
      ;;
    "si")
      echo "SIIII" # falta activar demonio
      ;;
    *)
      echo "La respuesta debe ser \"si\" o \"no\""
      deseaArrancar 
      ;;
  esac
}


##############################


# 1. Verifica ambiente inicializado
verificarAmbienteInicializado
inicializadoRtado=$?
if [ "$inicializadoRtado" == 1 ]; then
  exit 1
fi

# 2. Verifica instalacion completa
verificarInstalacion
instalacionRtado=$?
#if [ "$instalacionRtado" == 1 ]; then
#  echo "La instalacion no esta completa" # dar instrucciones mas completas
#  exit 1
#fi

# 3. Verifica permisos
verificarPermisos
permisosRtado=$?
#if [ "$permisosRtado" == 1 ]; then
#  exit 1
#fi

# 4. Inicializa el ambiente
inicializarAmbiente

# 5. Muestra y graba en el log
mostrarYgrabar

# 6. Pregunta si se desea arrancar
deseaArrancar
