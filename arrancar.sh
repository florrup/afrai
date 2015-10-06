#! /bin/bash

# Arranque de Scripts
# $1 script a correr
# $2 script que lo corrio (si no es por consola)

#########################  Procedimientos ##################################
source funcionesComunes.sh

GRALOG="$BINDIR/gralog.sh"
comandoAInvocar=$1
comandoInvocador=$2
PID=$(getPid $comandoAInvocar)


function verificarComandoInvocado(){
	echo "verificando comando de entrada"
	if [ ! -f $BINDIR/$comandoAInvocar.sh ]; then
    		local mensajeError="El comando ingresado es Incorrecto"
		imprimirResultado "$mensajeError" "ERR"
	fi
}

function verificarAmbiente(){
	echo "Verifico el ambiente"
	if [ $comandoAInvocar != "afrainic" ];then
		ambienteInicializado
		if [ $? == 1 ];then
			local mensajeError="Ambiente no inicializado"
			imprimirResultado "$mensajeError" "ERR"
		fi
	fi
}

function verificarProcesoCorriendo(){
	echo "verifico si el proceso ya esta corriendo"
	local procesoCorriendo=`ps aux | grep "/bin/bash ./$comandoAInvocar.sh$" | sed "s/^.*$comandoAInvocar.*$/$comandoAInvocar/"`
	if [ ! -z $procesoCorriendo ];then
	#if [ ! -z "$PID" ];then
		local mensaje="$comandoAInvocar ya esta corriendo"
		imprimirResultado "$mensaje" "WAR"
	fi
}

# $1 Mensaje $2 Tipo Mensaje
function imprimirResultado(){
	#si no hay comandoInvocador es porque se corrio por consola
	if [ -z $comandoInvocador ];then
		echo "$2: $1"
	else
		echo "en el log "
		msjLog $1 $2
	fi
	exit
}

function msjLog() {
	  local MENSAJE=$1
	  local TIPO=$2
	  echo "${MENSAJE}"
	  # solo graba si se invoca por un comando que registre en su log
	  if [[ ( ! -z $comandoInvocador ) && ( $COMANDOGRABA = "true" ) ]]; then
	    $GRALOG "$comandoInvocador" "$MENSAJE" "$TIPO"
	  fi
}


#Si arrancar.sh es invocada por un comando que graba en un archivo de log, registrar en el log del comando
function grabaEnLog() {
	if [ "$comandoInvocador" == "./afrainst.sh" ] || [ "$comandoInvocador" == "./afrainic.sh" ] || [ "$comandoInvocador" == "./afrareci.sh" ] || [ "$comandoInvocador" == "./afraumbr.sh" ] ; then
	  COMANDOGRABA="true"
	  MENSAJE="Se ha invocado al script arrancar.sh"
	  $GRALOG "$comandoInvocador" "$MENSAJE" "INFO"
	fi
}

# funcion llamada por los scripts
function arrancar(){
	verificarComandoInvocado
	grabaEnLog
	verificarAmbiente
	verificarProcesoCorriendo
	
	if [ "${comandoAInvocar}" == "afrareci" ];then
		nohup $BINDIR/$comandoAInvocar.sh > /dev/null 2>&1 &
	else
		$BINDIR/$comandoAInvocar.sh
	fi
}


####################   POR CONSOLA SOLO ARRANCA EL DEMONIO  #########################

if [ $# -lt 1 ] ;then
	echo "Modo de arranque \"arrancar.sh afrareci\""
	exit 1
fi

arrancar
###########################################################
