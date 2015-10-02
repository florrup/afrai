#! /bin/bash

# Arranque de Scripts
# $1 script a correr
# $2 script que lo corrio (si no es por consola)

###################  Procedimientos ##############################

GRALOG="./gralog.sh"
comandoAInvocar=$1
comandoInvocador=$2
comandosValidos=( "afrainst" "afrainic" "afrareci" "afraumbr" "afralist")


function verificarComandoInvocado(){
	echo "verificando comando de entrada"
	local esValido=1
	for comando in ${comandosValidos[*]}
	do
		if [ $comando == $comandoAInvocar ];then
			esValido=0
		fi
	done 
	if [ $esValido == 1 ];then
		local mensajeError="El comando ingresado es Incorrecto"
		imprimirResultado "$mensajeError" "ERR"
	fi
}

function verificarAmbiente(){
	echo "Verifico el ambiente"
	variablesDeAmbiente=( ${GRUPO} ${CONFDIR} ${BINDIR} ${MAEDIR} ${DATASIZE} ${NOVEDIR} ${ACEPDIR} ${PROCDIR} ${REPODIR} ${LOGDIR} ${RECHDIR} )
	local ambienteCorrecto=0
	echo "${#variablesDeAmbiente[*]}"
	if [ ${#variablesDeAmbiente[*]} != 11 ];then
		ambienteCorrecto=1
	fi
	if [ $ambienteCorrecto == 1 ];then
		local mensajeError="Ambiente no inicializado"
		imprimirResultado "$mensajeError" "ERR"
	fi
	echo
}

function verificarProcesoCorriendo(){
	echo "verifico si el proceso ya esta corriendo"
	local procesoCorriendo=`ps aux | grep "/bin/bash ./$comandoAInvocar.sh$" | sed "s/^.*$comandoAInvocar.*$/$comandoAInvocar/"`
	read x	
	if [ ! -z $procesoCorriendo ];then
		local mensaje="$comandoAInvocar ya esta corriendo"
		imprimirResultado "$mensaje" "WAR"
	fi
}

function imprimirResultado(){
	#si no hay comandoInvocador es porque se corrio por consola
	if [ -z $comandoInvocador ];then
		echo "Resultado: $1"
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
	if [ $comandoAInvocar != "afrainic" ];then
		verificarAmbiente
	fi
	verificarProcesoCorriendo
	grabarEnLog
	./$comandoAInvocar.sh
}


####################   POR CONSOLA   ############################

if [ $# -lt 1 ];then
	echo "Debe indicar el comando a ejecutar"
	exit 1
fi

if [ $# -gt 1 ];then
	echo "Debe indicar un solo comando a ejecutar"
	exit 1
fi

verificarComandoInvocado

if [ $comandoAInvocar != "afrainic" ];then
	verificarAmbiente
fi	

verificarProcesoCorriendo
./$comandoAInvocar.sh

###########################################################
