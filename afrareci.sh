#! /bin/bash

TIEMPO_DORMIDO=30
ciclo=0

# Graba en el log.
function grabarEnLog (){
	echo "*** LOG *** : AFRARECI ${1} ${2}"
	$BINDIR/gralog.sh "AFRARECI" "${1}" "${2}"
}

# Mueve el archivo pasado por parametro a la direccion parasada por paramtro
function moverA (){
	echo "Moviendo ${1} a ${2}..."
	$BINDIR/mover.sh $1 $2
}

# Arranca el proceso pasado por parametro
function arrancarProceso (){
	$BINDIR/arrancar.sh $1
}

# Verifica si existen archivos en el directorio pasado por parametro.
function existenArchivos (){
	cantidadArchivos=`ls $1 | wc -l`
	if [ ! $cantidadArchivos -eq 0 ]
   	then
		# Existe archivo
		return 0
	fi
   	return 1
}

# Valida si el archivo pasado por parametro es de texto
function esDeTexto (){
	local archivo=$NOVEDIR/${1}
	local esTexto=`file --mime-type ${archivo} | grep "text/plain$" `

	if [[ ! -z $esTexto ]]
	then
		# Archivo es de Texto
		return 0
	fi
	# Archivo No es de Texto
	return 1
}

# Valida si el archivo pasado por parametro tiene formato correcto
function tieneFormatoCorrecto (){
	formatoCorrecto=`echo $1 | grep "^[A-Z]\{3\}_[0-9]\{8\}"`
	
	if [[ ! -z $formatoCorrecto ]]
	then
		# Formato correcto: codigo_nroFecha
		return 0
	fi
	# Formato incorrecto
	return 1
}

# Valida si el archivo pasado por parametro posee el codigo central correcto
# y además existen en el archivo centrales.csv
function tieneCodigoCorrecto (){
	
	local centrales=${MAEDIR}/CdC.mae
	codigo=`echo $1 | cut -d'_' -f 1`
	cantidadEnCentrales=`echo ls | grep ^${codigo}'\;' ${centrales} | wc -l`
	
	if [ $cantidadEnCentrales -gt 0 ]
	then
		# Codigo Correcto
		return 0
	fi
	# Codigo incorrecto o no encontrado
	return 1
}

# Valida si la fecha es valida
function fechaValida (){
	local fecha=$1
	local mes=`echo ${fecha:4:2}`
	local dia=`echo ${fecha:6:2}`
	local diaMaximo=31
	local mesMaximo=12
	
	# Valida que el dia y el mes esten dentro de rangos validos.
	if [ $mes -gt $mesMaximo -o $dia -gt $diaMaximo -o $mes -lt 01 -o $dia -lt 01 ]
	then	
		return 1
	fi
	
	# Si el mes es febrero, el dia maximo es 28
	# Si el mes es Abril, Mayo, Septiembre o Noviembre, el dia maximo es 30	
	# Cualquier otro mes, el dia maximo es 31
	if [ $mes -eq 02 ]
	then
		let diaMaximo=$diaMaximo-3
	
	elif [ $mes -eq 04 -o $mes -eq 06 -o $mes -eq 09 -o $mes -eq 11 ]
	then
		let diaMaximo--
	fi
	
	# Valida que el dia no supere el dia maximo, segun el mes
	if [ $dia -gt $diaMaximo ]
	then
		# Dia superior a dia maximo del mes correspondiente
		return 1
	fi
	
	# Fecha valida
	return 0
}

# Valida si el archivo pasado por parametro posee la fecha correcta
function tieneFechaCorrecta (){

	fechaParte2=`echo $1 | cut -d'_' -f 2`
	fecha=`echo ${fechaParte2:0:8}`
	
	# Valida que la fecha sea numerica
	esNumerico=`echo $fecha | grep "^[0-9]\{8\}$"`
	if [ -z $esNumerico ]
	then
		# Fecha no numerica
		return 1
	fi
	
	if ! fechaValida $fecha;
	then
		# Fecha fuera de rango
		return 1
	fi

	fechaActual=`date +'%Y%m%d'`
	let diferencia=$fechaActual-$fecha
	
	# Valida si la fecha es mayor a un año
	if [ $diferencia -gt 10000 ]
	then
		# Mayor a un ano
		return 1
	fi
	
	# Valida si la fecha es mayor a la fecha actual
	if [ $diferencia -lt 0 ]
	then
		# Mayor al dia de la fecha actual
		return 1
	fi
	
	# Fecha Correcta
	return 0
}

# Valida si el archivo pasado por parametro posee nombre correcto
# 0: Archivo valido
# 1: Archivo con fecha invalida
# 2: Archivo con codigo invalido
function tieneNombreCorrecto (){
	
	if tieneCodigoCorrecto $1;
	then
		if tieneFechaCorrecta $1;
		then
			# Archivo Valido
			return 0
		fi
		# Archivo invalido -  Fecha Invalida
		motivoRechazo="Fecha invalida"
	fi
	# Archivo invalido - Codigo incorrecto o no encontrado
	motivoRechazo="Central inexistente"
	return 1
}

function darPermisoParaMover (){
	archivoRutaCompleta=$NOVEDIR/$1
	chmod +x $archivoRutaCompleta
}

# Realiza las validaciones de los archivos en NOVEDIR
function procesarArchivosNovedir (){
	
	motivoRechazo=""
	listadoArchivos=`ls -1 ${NOVEDIR}`	

	for archivo in $listadoArchivos 
	do
		archivoCorrecto=false
		darPermisoParaMover $archivo
		
		#Paso 3: Verifica que el archivo sea de texto.
		if esDeTexto $archivo;
		then
			#Paso 4: Verifica el formato del archivo.
			if tieneFormatoCorrecto $archivo;
			then
				#Paso 5: Valida el nombre del archivo.
				if tieneNombreCorrecto $archivo;
				then
					#Paso 6: 
					# - Mover archivo a ACEPDIR.
					# - Grabar log.
					archivoRutaCompleta=$NOVEDIR/$archivo
                    moverA $archivoRutaCompleta $ACEPDIR
					archivoCorrecto=true
					grabarEnLog "ACEPTADO" "${archivoRutaCompleta}"
				fi
			else
				motivoRechazo="Formato incorrecto"
			fi
		else
			motivoRechazo="Tipo de archivo invalido"
		fi
	
		#Paso 7: Rechazar archivos invalidos
		# - Mover archivo a RECHDIR
		# - Grabar log.
		if ! $archivoCorrecto
		then
			archivoRutaCompleta=$NOVEDIR/$archivo
			moverA $archivoRutaCompleta $RECHDIR
			grabarEnLog "RECHAZADO" "${archivo}-${motivoRechazo}" 
		fi
		echo ""

	done	
}


############################  AFRARECI  ################################
while [[ true ]]
#while [ $ciclo -eq 0 ]
do	
	#Paso 1: Grabar en el log el numero de ciclo.
	let ciclo++
	grabarEnLog " " "ciclo nro. $ciclo"

	#Paso 2: Chequear si hay archivos en el directorio NOVEDIR.	
	if existenArchivos $NOVEDIR;
	then
		#echo "Existieron archivos en novedir"
		#Paso 3 al 7: Procesar los archivos dentro de la carpeta NOVEDIR.
		# Los validos, los mueve a ACEPDIR
		# Los NO validos, los mueve a RECHDIR
		procesarArchivosNovedir
	fi
	
	#Paso 8: Novedades Pendientes.
	if existenArchivos $ACEPDIR;
	then
		afraumbrCorriendo=`ps -A | grep "afraumbr.sh"`
		idAfraumbr=`pgrep -o "afraumbr.sh"`
		if [[ -z $afraumbrCorriendo ]]
		then
			arrancarProceso afraumbr
			idAfraumbr=`pgrep -o "afraumbr.sh"`
			if [ ! -z idAfraumbr ]
			then
				grabarEnLog "AFRAUMBR" "AFRAUMBR corriendo bajo el no.: ${idAfraumbr}"
			else
				grabarEnLog "HUBO UN ERROR EN INVOCAR"
			fi
		else
			# AFRAUMBR estaba corriendo
			grabarEnLog " " "Invocación de AFRAUMBR pospuesta para el siguiente ciclo"
		fi
	fi
	echo ""
	sleep $TIEMPO_DORMIDO
	
done
