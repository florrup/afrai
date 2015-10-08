#! /bin/bash

# Arranque de Scripts
# $1 script a correr
# $2 script que lo corrio (si no es por consola)

#########################  Procedimientos ##################################
source funcionesComunes.sh

GRALOG="gralog.sh"
comandoAInvocar=$1
comandoInvocador=$2
PID=$(getPid $comandoAInvocar)


function verificarComandoInvocado(){
	echo "verificando comando de entrada correcto.."
	if [ ! -f $BINDIR/$comandoAInvocar.sh ]; then
    		local mensajeError="El comando ingresado es Incorrecto"
		imprimirResultado "$mensajeError" "ERR"
	fi
}

function verificarAmbiente(){
	echo "Verificando si el ambiente esta inicializado.."
	if [ $comandoAInvocar != "afrainic" ];then
		ambienteInicializado
		if [ $? == 1 ];then
			local mensajeError="Ambiente no inicializado"
			imprimirResultado "$mensajeError" "ERR"
		fi
	fi
}

function verificarProcesoCorriendo(){
	echo "Verificando si el proceso ya se encuentra corriendo.."
	if [ ! -z "$PID" ];then
		local mensaje="$comandoAInvocar ya esta corriendo con PID: $PID"
		imprimirResultado "$mensaje" "WAR"
	fi
}

# $1 Mensaje $2 Tipo Mensaje
function imprimirResultado(){
	#si no hay comandoInvocador es porque se corrio por consola
	if [ ! -z $comandoInvocador ];then
		msjLog $1 $2
	fi
	echo "$2: $1"
	exit
}

function msjLog() {
	  local MENSAJE=$1
	  local TIPO=$2
	  echo "${MENSAJE}"
	  # solo graba si se invoca por un comando que registre en su log
	  if [ $COMANDOGRABA = "true" ]; then
	    $GRALOG "$BINDIR/$comandoInvocador.sh" "$MENSAJE" "$TIPO"
	  fi
}


#Si arrancar.sh es invocada por un comando que graba en un archivo de log, registrar en el log del comando
function grabaEnLog() {
	if [ "$comandoInvocador" == "afrainst" ] || [ "$comandoInvocador" == "afrainic" ] || [ "$comandoInvocador" == "afrareci" ] || [ "$comandoInvocador" == "afraumbr" ] ; then
	  COMANDOGRABA="true"
	  MENSAJE="Se ha invocado al script arrancar.sh"
	  $GRALOG "$BINDIR/$comandoInvocador.sh" "$MENSAJE" "INFO"
	fi
}

####################   POR CONSOLA SOLO ARRANCA EL DEMONIO  #########################

if [ $# -lt 1 ] ;then
	echo "Modo de arranque incorrecto, por favor intente de la siguiente forma: \"arrancar.sh <comando a arrancar>\""
	exit 1
fi

verificarAmbiente
verificarComandoInvocado
grabaEnLog
verificarProcesoCorriendo

if [ "${comandoAInvocar}" == "afrareci" ];then
	nohup $BINDIR/$comandoAInvocar.sh > /dev/null 2>&1 &
else
	$BINDIR/$comandoAInvocar.sh &
fi

PID=$(getPid $comandoAInvocar)
if [ ! -z $PID ];then
	mensaje="$comandoAInvocar corriendo bajo el no.: $PID. Para detenerlo ejecute detener.sh $comandoAInvocar"
	tipo="INFO"
else
	mensaje="Error al arrancar el comando $comandoAInvocar"
	tipo="ERR"
fi

imprimirResultado "$mensaje" "$tipo"

