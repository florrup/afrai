#! /bin/bash

TIEMPO_DORMIDO=15
EXTENSION_TEXTO=*.txt
FORMATO_CORRECTO="<"*">_<"*">".txt
#GET_CODIGO=ls -1 *.txt | grep -E "<(...)>"
DIR_CENTRALES="/home/gonzalo/Escritorio/Tp/Cosas_del_Mail/Datos/centrales.csv"

ciclo=0


# Graba en el log.
function grabarEnLog (){
	echo $1
}

#Mueve el archivo pasado por parametro a la direccion parasada por paramtro
function moverA (){
	echo "Moviendo archivo..."
}

# Verifica si existen archivos en el directorio pasado por parametro.
#function existenArchivos (){
#	echo "Verificando existencia de archivos..."
#	if [ "$(ls $1)" ]
#	then
#		for directorio in $1
#		do		
#			cantidadArchivos=`find $directorio -type f | wc -l`
#			if [ ! $cantidadArchivos -eq 0 ]
#	    		then
#				# Existe archivo
#		    		return 0
#	    		fi
#   		done
#  	fi
	# No existe archivo
#  	return 1	
#}

# Verifica si existen archivos en el directorio pasado por parametro.
function existenArchivos (){
	echo "Verificando existencia de archivos en ${1}..."
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
	if [[ $1 == $EXTENSION_TEXTO ]]
	then
#		echo "          ${archivo} es de TEXTO"
		return 0
	fi
#	echo "          ${1} NO es de TEXTO"
	return 1
}

#function esDeTexto2 (){
#	
#	local tipe=`file $1`
#	local tipo=`echo $tipe | sed 's/^\(.*\):\(.*\)/\2/g'`	
#
#	if !(echo $tipo | grep '^.*text.*$' &>/dev/null) 
#		then 
#			echo "Rechazado  ${1##*/}  - Tipo invalido : $tipo"
#			return 1
#		else
#			echo "          ${1} es de TEXTO"
#			return 0
#	fi
#}

# Valida si el archivo pasado por parametro tiene formato correcto
function tieneFormatoCorrecto (){
	if [[ $1 == $FORMATO_CORRECTO ]]
	then
#		echo "          ${1} con FORMATO CORRECTO"
		return 0
	fi
#	echo "		${1} NO tiene FORMATO correcto"
	return 1
}

# Valida si el archivo pasado por parametro posee el codigo central correcto
# y además existen en el archivo centrales.csv
function tieneCodigoCorrecto (){
	codigoParte1=`echo $1 | cut -d'_' -f 1`
	codigo=`echo ${codigoParte1:1:3}`
	cantidadEnCentrales=`echo ls | grep ^${codigo}'\;' ${DIR_CENTRALES} | wc -l`
	echo "SE ENCONTRARON: ${cantidadEnCentrales} RESULTADOS DE MATCHEO"
	if [ $cantidadEnCentrales -gt 0 ]
	then
		# Codigo Correcto
		return 0
	fi
	# Codigo incorrecto o no encontrado
	return 1
}

# Valida si el archivo pasado por parametro posee la fecha correcta
function tieneFechaCorrecta (){
	fechaParte2=`echo $1 | cut -d'_' -f 2`
	fecha=`echo ${fechaParte2:1:8}`
#	echo "FECHA: ${fecha}"
	
	
	# Valida que la fecha sea numerica
	if [[ $fecha == *[0-9] ]]
	then
		echo "NO ES NUMERICA"
		return 1
	fi


	fechaActual=`date +'%Y%m%d'`
#	echo "FECHA ACTUAL: ${fechaActual}"
	let diferencia=$fechaActual-$fecha
	echo "DIFERENCIA: ${diferencia}"
	
	# Valida si la fecha es mayor a un año
	if [ $diferencia -gt 10000 ]
	then
		echo "MAYOR A UN AÑO"
		return 1
	fi
	
	# Valida si la fecha es mayor a la fecha actual
	if [ $diferencia -lt 0 ]
	then
		echo "MAYOR AL DIA DE LA FECHA"
		return 1
	fi
	
	
	return 0
}

# Valida si el archivo pasado por parametro posee nombre correcto
function tieneNombreCorrecto (){
	if tieneCodigoCorrecto $1;
	then
		echo "$1 Tuvo codigo correcto"
		
		if tieneFechaCorrecta $1;
		then
			echo "$1 Tuvo fecha correcta"
			return 0
		fi
		# Fecha Invalida
	fi
	# Nombre invalido
	return 1
}

# Realiza las validaciones de los archivos en NOVEDIR
function procesarArchivosNovedir (){
	echo "Procesando archivos en NOVEDIR..."
	archivoNombreCorrecto=false
	
	motivoRechazo=""
#	archivo="name_archivo"
	listadoArchivos=`ls -1 "NOVEDIR"`	

	for archivo in $listadoArchivos 
	do
	archivoRechazado=false
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
					moverA $archivo
					grabarEnLog "Archivo ${archivo} correcto"
				else
					archivoRechazado=true
					motivoRechazo="${archivo} - Nombre incorrecto"
				fi
			else
				archivoRechazado=true
				motivoRechazo="${archivo} - Formato incorrecto"
			fi
		else
			archivoRechazado=true
			motivoRechazo="${archivo} - Archivo no es de texto"
		fi
	
		#Paso 7: Rechazar archivos invalidos
		# - Mover archivo a RECHDIR
		# - Grabar log.
		if $archivoRechazado ;
		then
			moverA
			grabarEnLog "$motivoRechazo"
		fi
		echo ""

	done	
}


############################  AFRARECI  ################################
while [[ true ]]
do	
	#Paso 1: Grabar en el log el numero de ciclo.
	let ciclo++
	grabarEnLog "AFRARECI ciclo nro. ${ciclo}"


	#Paso 2: Chequear si hay archivos en el directorio NOVEDIR.	
	if existenArchivos "NOVEDIR";
	then
		echo "Existieron archivos en novedir"
		#Paso 3 al 7: Procesar los archivos dentro de la carpeta NOVEDIR.
		# Los validos, los mueve a ACEPDIR
		# Los NO validos, los rechaza
		procesarArchivosNovedir
	fi
	
	#Paso 8: Novedades Pendientes.
	if existenArchivos "ACEPDIR";
	then
		echo "Existieron archivos en ACEPDIR"
		seInvocoAfraumbr=false
		errorAfraumbr=false
		idAfraumbr=00000
		if $seInvocoAfraumbr;
		then
			grabarEnLog "AFRAUMBR corriendo bajo el no.: ${idAfraumbr}"
		elif $errorAfraumbr;
		then
			grabarEnLog "Hubo un ERROR"
		else
			grabarEnLog "Invocación de AFRAUMBR pospuesta para el siguiente ciclo"
		fi
	fi
	echo ""
	sleep $TIEMPO_DORMIDO
done


