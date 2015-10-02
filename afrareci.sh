#! /bin/bash

TIEMPO_DORMIDO=10
DIR_CENTRALES=/home/gonzalo/Escritorio/Tp/Cosas_del_Mail/Datos/centrales.csv
NOVEDIR=/home/gonzalo/Escritorio/Tp/Archivos/NOVEDIR
ACEPDIR=/home/gonzalo/Escritorio/Tp/Archivos/ACEPDIR
RECHDIR=/home/gonzalo/Escritorio/Tp/Archivos/RECHDIR
MOVER=/home/gonzalo/Escritorio/Tp/afrai/mover.sh
ciclo=0


# Graba en el log.
function grabarEnLog (){
	echo "*** LOG *** : ${1}"
}

#Mueve el archivo pasado por parametro a la direccion parasada por paramtro
function moverA (){
	echo "Moviendo ${1} a ${2}..."
	$MOVER $1 $2
}

# Verifica si existen archivos en el directorio pasado por parametro.
function existenArchivos (){
	#echo "Verificando existencia de archivos en ${1}..."
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
	echo "Formato del archivo ${esTexto}"
	if [[ ! -z $esTexto ]]
	then
		echo "FUEEEE DE TEXTOOOOO"
		return 0
	fi
	echo "NO PUEDE SEEEEER"
	return 1
}

# Valida si el archivo pasado por parametro tiene formato correcto
function tieneFormatoCorrecto (){
	formatoCorrecto=`echo $1 | grep "^[A-Z]\{3\}_[0-9]\{8\}"`
	
	if [[ ! -z $formatoCorrecto ]]
	then
		return 0
	fi
	return 1
}

# Valida si el archivo pasado por parametro posee el codigo central correcto
# y además existen en el archivo centrales.csv
function tieneCodigoCorrecto (){
	#codigoParte1=`echo $1 | cut -d'_' -f 1`
	#codigo=`echo ${codigoParte1:1:3}`
	codigo=`echo $1 | cut -d'_' -f 1`
	cantidadEnCentrales=`echo ls | grep ^${codigo}'\;' ${DIR_CENTRALES} | wc -l`
	#echo "SE ENCONTRARON: ${cantidadEnCentrales} RESULTADOS DE MATCHEO"
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
		#echo "Fecha no numerica"
		return 1
	fi
	
	if ! fechaValida $fecha;
	then
		#echo "Fecha fuera de rango"
		return 1
	fi

	fechaActual=`date +'%Y%m%d'`
	let diferencia=$fechaActual-$fecha
	#echo "DIFERENCIA: ${diferencia}"
	
	# Valida si la fecha es mayor a un año
	if [ $diferencia -gt 10000 ]
	then
		#echo "Mayor a un ano"
		return 1
	fi
	
	# Valida si la fecha es mayor a la fecha actual
	if [ $diferencia -lt 0 ]
	then
		#echo "Mayor al dia de la fecha"
		return 1
	fi
	
	
	return 0
}

# Valida si el archivo pasado por parametro posee nombre correcto
function tieneNombreCorrecto (){
	if tieneCodigoCorrecto $1;
	then
		#echo "$1 Tuvo codigo correcto"
		
		if tieneFechaCorrecta $1;
		then
			#echo "$1 Tuvo fecha correcta"
			return 0
		fi
		# Fecha Invalida
	fi
	# Nombre invalido
	return 1
}

# Realiza las validaciones de los archivos en NOVEDIR
function procesarArchivosNovedir (){
	#echo "Procesando archivos en NOVEDIR..."
	motivoRechazo=""
	listadoArchivos=`ls -1 ${NOVEDIR}`	

	for archivo in $listadoArchivos 
	do
	archivoCorrecto=false
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
					grabarEnLog "Archivo ${archivo} correcto"
					archivoCorrecto=true
				else
					motivoRechazo="${archivo} - Nombre incorrecto"
				fi
			else
				motivoRechazo="${archivo} - Formato incorrecto"
			fi
		else
			motivoRechazo="${archivo} - Archivo no es de texto"
		fi
	
		#Paso 7: Rechazar archivos invalidos
		# - Mover archivo a RECHDIR
		# - Grabar log.
		if ! $archivoCorrecto
		then
			archivoRutaCompleta=$NOVEDIR/$archivo
			moverA $archivoRutaCompleta $RECHDIR
			grabarEnLog "Motivo de Rechazo: ${motivoRechazo}"
		fi
		echo ""

	done	
}


############################  AFRARECI  ################################
#while [[ true ]]
while [ $ciclo -eq 0 ]
do	
	#Paso 1: Grabar en el log el numero de ciclo.
	let ciclo++
	grabarEnLog "AFRARECI ciclo nro. ${ciclo}"

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
		echo "Existieron archivos en ACEPDIR"
		afraumbr=afrareci.sh
		afraumbrCorriendo=`ps -A | grep "${afraumbr}"`
		errorAfraumbr=false
		idAfraumbr=`pgrep -o ${afraumbr}`
		if [[ ! -z $afraumbrCorriendo ]]
		then
			# AFRAUMBR esta corriendo
			echo "Corriendo con id: ${idAfraumbr}" 
			grabarEnLog "NO SE PUEDE INVOCAR AFRAUMBR, YA ESTA CORRIENDO"
		else
			# INVOCAR AFRAUMBR
			# SI SE PUEDO INVOCAR AFRAUMBR
				grabarEnLog "AFRAUMBR corriendo bajo el no.: ${idAfraumbr}"
				# SI SE DEBE POSPONER
					 grabarEnLog "Invocación de AFRAUMBR pospuesta para el siguiente ciclo"
				# SINO
					grabarEnLog "HUBO UN ERROR EN POSPONER"
			# SINO
			grabarEnLog "HUBO UN ERROR EN INVOCAR"
		fi
	fi
	echo ""
	sleep $TIEMPO_DORMIDO
done


