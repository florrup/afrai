#!/bin/bash
# Prepara el entorno de ejecución

GRALOG="./gralog.sh"   

CNF=~/grupo07/CONF/AFRAINST.conf 	# DE PRUEBA usar file de configuración

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

function existeScript() {
  local SCR=$1
  local COMPLETA=0
  if [ ! -f "$SCR" ]; then
    MOUT="El script \"${SCR}\" no existe"
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
  variables=("$GRUPO" "$CONFDIR" "$BINDIR" "$MAEDIR" "$DATASIZE" "$ACEPDIR" "$RECHDIR" "$PROCDIR" "$REPODIR" "$NOVEDIR" "$LOGDIR" "$LOGSIZE")
  for VAR in "${variables[@]}"
  do
    if [[ ! -z "$VAR" ]]; then # si la variable no esta vacia es porque fue inicializado
      ((i+=1))
    fi
  done
  if [ "$i" -gt 0 ]; then
    MSJ="Ambiente ya inicializado, para reiniciar termine la sesión e ingrese nuevamente"
    msjLog "$MSJ" "ERR"
    return 1
  fi
  return 0
}

# Verifica que la instalación está completa
# Devuelve 0 si está completa, 1 si no
function verificarInstalacion() {

  faltantes=()

  # checkeo archivos
  local COMPLETA=0
  for ARCH in "${archivos[@]}"
  do
    existeArch "$ARCH"
    existe=$?

    if [ $existe = 1 ]; then
      faltantes+=("$ARCH")
    else
      COMPLETA=$(($COMPLETA + 1))
    fi
  done

  if [ "$COMPLETA" -lt 6 ]; then # algo no está instalado
    echo "Hay algún archivo sin instalar"
  fi

  # checkeo scripts
  local COMPLETA=0
  for SCRIPT in "${scripts[@]}"
  do
    existeScript "$SCRIPT"
    existe=$?

    if [ $existe = 1 ]; then
      faltantes+=("$SCRIPT")
    else
      COMPLETA=$(($COMPLETA + 1))
    fi
  done

  if [ "$COMPLETA" -lt 5 ]; then # algo no está instalado
    echo "Hay algún script faltante"
  fi

  if [ ${#faltantes[@]} -gt 0 ]; then
    echo "Hay algo (archivo o script) faltante"
    return 1
  fi

  return 0
}

# Verifica los permisos
# Devuelve 1 si no se pueden setear, 0 en caso contrario 
function verificarPermisos() {
  i=0

  # checkeo archivos
  for ARCH in "${archivos[@]}"
  do
    chmod +r "$ARCH"
    if [ "$?" = -1  ]; then
      noPermisos "$ARCH"
      ((i+=1))
    fi
  done

  # checkeo scripts
  for SCRIPT in "${scripts[@]}"
  do
    chmod +x "$SCRIPT"
    if [ "$?" = -1  ]; then
      noPermisos "$SCRIPT"
      ((i+=1))
    fi
  done

  if [ "$i" -gt 0 ]; then
    msjLog "No se han podido setear los permisos" "ERR"
    return 1
  fi
  return 0
}

# Desde el archivo de configuración tomo todas las variables
function setearVariablesAmbiente() {
  GRUPO=$(grep '^GRUPO' $CNF | cut -d '=' -f 2)
  CONFDIR=$(grep '^CONFDIR' $CNF | cut -d '=' -f 2)
  BINDIR=$(grep '^BINDIR' $CNF | cut -d '=' -f 2)
  MAEDIR=$(grep '^MAEDIR' $CNF | cut -d '=' -f 2)
  DATASIZE=$(grep '^DATASIZE' $CNF | cut -d '=' -f 2)
  ACEPDIR=$(grep '^ACEPDIR' $CNF | cut -d '=' -f 2)
  RECHDIR=$(grep '^RECHDIR' $CNF | cut -d '=' -f 2)
  PROCDIR=$(grep '^PROCDIR' $CNF | cut -d '=' -f 2)
  REPODIR=$(grep '^REPODIR' $CNF | cut -d '=' -f 2)
  NOVEDIR=$(grep '^NOVEDIR' $CNF | cut -d '=' -f 2)
  LOGDIR=$(grep '^LOGDIR' $CNF | cut -d '=' -f 2)
  LOGSIZE=$(grep '^LOGSIZE' $CNF | cut -d '=' -f 2)
}

# Inicializa el ambiente
function inicializarAmbiente() {
  # permito que todas las variables sean utilizadas desde otros scripts con export
  #export PATH="${BINDIR}"
  export GRUPO
  export CONFDIR
  export BINDIR
  export MAEDIR
  export DATASIZE
  export ACEPDIR
  export RECHDIR
  export PROCDIR
  export REPODIR
  export NOVEDIR
  export LOGDIR
  export LOGSIZE
}

# Muestra y graba en el log variables y contenido
function mostrarYgrabar() {
  variables=("$CONFDIR" "$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$PROCDIR" "$REPODIR" "$LOGDIR" "$RECHDIR")
  mensajes=("Configuración" "Ejecutables" "Maestros y Tablas" "Recepción de archivos de llamadas" "Archivos de llamadas Aceptadas" "Archivos de llamadas Sospechosas" "Archivos de Reportes de llamadas" "Archivos de Log" "Archivos Rechazados")
  i=0
  for VAR in "${variables[@]}"
  do
    MSJ="Directorio de ""${mensajes[${i}]}":" $VAR"
    msjLog "$MSJ" "INFO"
    # listar archivos si es CONFDIR, BINDIR, MAEDIR, LOGDIR
    if [ "$VAR" = "$CONFDIR" ] || [ "$VAR" = "$BINDIR" ] || [ "$VAR" = "$MAEDIR" ] || [ "$VAR" = "$LOGDIR" ] ; then
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
      $BINDIR/arrancar.sh afrareci
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

# Seteo todas las variables de ambiente
# A partir del archivo de configuración
setearVariablesAmbiente

# 2. Verifica instalacion completa
CDP="${MAEDIR}"/"CdP.mae"			# agregar "${BINDIR}"
CDA="${MAEDIR}"/"CdA.mae"
CDC="${MAEDIR}"/"CdC.mae"
AGE="${MAEDIR}"/"agentes.mae"
TLL="${MAEDIR}"/"tllama.tab"
UMB="${MAEDIR}"/"umbral.tab"

AFRARECI="afrareci.sh"
AFRAUMBR="afraumbr.sh"
AFRALIST="afralist.pl"
ARRANCAR="arrancar.sh"
DETENER="detener.sh"

archivos=("$CDP" "$CDA" "$CDC" "$AGE" "$TLL" "$UMB")
scripts=("$AFRARECI" "$AFRAUMBR" "$AFRALIST" "$ARRANCAR" "$DETENER")

verificarInstalacion
instalacionRtado=$?
if [ "$instalacionRtado" == 1 ]; then
  echo "La instalación no está completa, existen los siguientes archivos faltantes $(printf '%s\n' "${faltantes[@]}")" 
  echo "Se deberá volver a realizar la instalación"
  exit 1
fi

# 3. Verifica permisos
verificarPermisos
permisosRtado=$?
if [ "$permisosRtado" == 1 ]; then
  exit 1
fi

# 4. Inicializa el ambiente
inicializarAmbiente

# 5. Muestra y graba en el log
mostrarYgrabar

# 6. Pregunta si se desea arrancar
deseaArrancar
