#! /bin/bash
GRUPO=~/grupo07;
CONFDIR=${GRUPO}/CONF;
AFRACONFIG="AFRAINST.conf";
DATASIZE=100;
NOVEDIR="/home/ramon/desa/";

existeArchivo () {
        local configuracion=$1;
        if [ -f "${configuracion}" ];then
                return 0;
        else
                return 1;
	fi
}

#PASO 1
verificarInstalacion(){
	#SACAR
	echo "Verificando instalacion..."
	read x;
	#**************************************
	local config="$CONFIG/$AFRACONFIG"
        existeArchivo $config
        local resultado=$?
        if [ $resultado == 0 ];then
                echo "puede estar instalado"
                #TODO:VERIFICAR INSTALACION COMPLETA PASO 2
        else
                echo "******************* No esta instalado AFRA-l *****************"
                #TODO:VERIFICO SI PERL ESTA INSTALADO
                verificarPerl;
        fi
}


#PASO 4
verificarPerl(){
	#SACAR
	echo "Verificando instalacion de Perl..."
	read x;
	#**************************************
	local datosPerl=`perl -v`
	local version=$(echo "$datosPerl" | grep " perl [0-9]" | sed "s-.*\(perl\) \([0-9]*\).*-\2-")
	if [ $version -ge 5 ];then
		echo "Perl version: $datosPerl"
		echo "##################################################################"
		#TODO:GRABAR EN LOG
	else
		#TODO: grabar en log
		echo "Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior."
		echo "Efectúe su instalación e inténtelo nuevamente."
		echo "Proceso de Instalación Cancelado"
		fin;
	fi
}

#paso 21
fin(){
	#TODO:cerrar log
	exit
}

#PASO 9
 definirEspacioNovedades(){
         #TODO: grabar en log
         local estado=1;
         while [ $estado == 1 ];do
                 echo "Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes (100):"
                 read DATASIZE
                 DATASIZE=`echo $DATASIZE | grep "^[0-9]*$"`
                 if [ ! -z $DATASIZE ];then
                         verificarEspacioDisco
                         estado=$?;
                 else
                         echo "No pose caracteres numericos, intente nuevamente"
                 fi
         done
}

#PASO 10
verificarEspacioDisco(){
	local espacioDisco=$(df -h /dev/sda5 | grep "/dev/sda5" | sed "s-^/dev/sda5 *\([0-9]*.\) *\([0-9]*.\) *\([0-9]*.\).*-\3-");
	#echo "$espacioDisco"
	tamanio=$(echo "$espacioDisco" | sed "s-^\([0-9]*\).*-\1-")
	let tamanio=tamanio*100;

	medida=$(echo "$espacioDisco" | sed "s-.*\([^0-9]\)-\1-")
	
	if [ $tamanio -lt $DATASIZE ];then
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $tamanio Mb."
		echo "Espacio requerido $DATASIZE Mb"
		echo "Inténtelo nuevamente."
		return 1;
	else
		return 0;
	fi
}


# ********************************************Acuerdo de Licencia de Software**********************************************************

#PASO5
definicionesInstalacion() {
	read x
	clear;
	local estado=0
	while [ $estado -eq 0 ]
	do
		estado=1
		echo "*****************************************************************"
		echo "*              Proceso de Instalacion de "AFRA-I"               *"
		echo "*    Tema I Copyright  Grupo 07 - Segundo Cuatrimestre 2015     *"
		echo "*****************************************************************"
		echo "A T E N C I O N: Al instalar UD. expresa aceptar los terminos y condiciones"
		echo "del "ACUERDO DE LICENCIA DE SOFTWARE" incluido en este paquete."
		echo "Acepta? (Si - No)"
		read respuesta
		#TODO: verificar si la respuesta es Si o No y no otra respuesta.
		if [ $respuesta = "No" ];then
			echo "Proceso Cancelado";
			fin;
		else 
			while [ $respuesta = "Si" ]
			do
				definicionesDir
				respuesta=$?
			done
		
			estado=0;
		fi		
	done
}


definicionesDir() {
	definirBinDir
	definirMaeDir
	definirNoveDir
	definirEspacioNovedades
	definirAcepDir
	definirProcDir
	definirRepoDir
	definirLogDir
	definirLogExt
	definirLogSize
	definirRechDir
	mostrarDefiniciones
	return $?
}
# *************************************************************************************************************************************
# ********************************************Print en Screen**************************************************************************

#PASO18Y19
mostrarDefiniciones () {
	echo "Directorio de Ejecutables: ${BINDIR}"
	echo "Directorio de Maestros y Tablas: ${MAEDIR}"
	echo "Directorio de recepcion de archivos de llamadas: ${NOVEDIR}"
	#echo "Espacio minimo libre para arribos: ${DATASIZE} Mb"
	echo "Directorio de Archivos de llamadas Aceptadas: ${ACEPDIR}"
	echo "Directorio de Archivos de llamadas Sospechosas: ${PROCDIR}"
	echo "Directorio de Archivos de Reportes de llamadas: ${REPODIR}"
	echo "Directorio de Archivos de Log: ${LOGDIR}"
	echo "Extension para los archivos de log: ${LOGEXT}"
	echo "Tamanio maximo para los archivos de log: ${LOGSIZE} Kb"
	echo "Directorio de Archvios Rechazados: ${RECHDIR}"
	echo "Estado de la instalacion: LISTA"
	echo "Desea continuar con la instalacion? (Si - No):"
	read respuesta
	if [ "$respuesta" = "Si" ];then
		echo "Iniciando Instalacion. Esta Ud. seguro? (Si - No):"
		read respuesta2
		if [ "$respuesta2" = "Si" ];then
			instalacion;
		fi
		fin;
	else
		clear
		definicionesDir
		return "Si"
	fi	
}

#PASO3.1
verifInstalacion () {
	local estado=$1
	echo "Directorio de Configuracion: ${CONFDIR}"
	echo "Directorio de Ejecutables: ${BINDIR}"
	echo "Directorio de Maestros y Tablas: ${MAEDIR}"
	echo "Directorio de recepcion de archivos de llamadas: ${NOVEDIR}"
	echo "Directorio de Archivos de llamadas Aceptadas: ${ACEPDIR}"
	echo "Directorio de Archivos de llamadas Sospechosas: ${PROCDIR}"
	echo "Directorio de Archivos de Reportes de llamadas: ${REPODIR}"
	echo "Directorio de Archivos de Log: ${LOGDIR}"
	echo "Directorio de Archvios Rechazados: ${RECHDIR}"
	echo "Estado de la instalacion: ${estado}"
	echo "Proceso de Instalacion Finalizado"
}
# **************************************************************************************************************************************
# ********************************************Definicion de directorios, extensiones, longitudes****************************************

existeDir () {
	local direccion=$1
	if [ -d "$direccion" ];then
		echo "Directorio ya existe"
		return 1
	else
		return 0
	fi
}

#PASO6
definirBinDir () {
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio de ejecutables ($GRUPO/bin):"
		read BINDIR
		existeDir $BINDIR
		estado=$?
	done
}

#PASO7
definirMaeDir () {		
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio para maestros y tablas ($GRUPO/mae):"
		read MAEDIR
		existeDir $MAEDIR
		estado=$?
	done
}

#PASO8
definirNoveDir () {	
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio de recepcion de archivos de llamadas ($GRUPO/novedades):"
		read NOVEDIR
		existeDir $NOVEDIR
		estado=$?
	done
}

#PASO11
definirAcepDir () {	
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio de grabacion de los archivos de llamadas aceptadas ($GRUPO/aceptadas):"
		read ACEPDIR
		existeDir $ACEPDIR
		estado=$?
	done
}

#PASO12
definirProcDir () {
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio de grabacion de los registros de llamadas sospechosas ($GRUPO/sospechosas):"
		read PROCDIR
		existeDir $PROCDIR
		estado=$?
	done
}

#PASO13
definirRepoDir () {	
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio de grabacion de los reportes ($GRUPO/reportes):"
		read REPODIR
		existeDir $REPODIR
		estado=$?
	done
}

#PASO14
definirLogDir () {
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio para los archivos de log ($GRUPO/log):"
		read LOGDIR
		existeDir $LOGDIR
		estado=$?
	done
}

#PASO15
definirLogExt () {
	echo "Defina nombre para la extension de los archivos de log (log):"
	read LOGEXT
	#Falta verificar que la longitud sea menor o igual a 5
}

#PASO16
definirLogSize () {
	echo "Defina el tamanio maximo para cada archivo de log en Kbytes (400):"
	read LOGSIZE
}

#PASO17
definirRechDir () {
	local estado=1
	while [ $estado -eq 1 ]
	do
		echo "Defina el directorio de grabacion de Archivos rechazados ($GRUPO/rechazadas):"
		read RECHDIR
		existeDir $RECHDIR
		estado=$?
	done
}
# **********************************************************************************************************************************
# ***********************************************Creando las Estructuras************************************************************

#PASO20
instalacion () {
	echo "Creando Estructuras de directorio"
	mkdir "${CONFDIR}"
#	local DIRE
#	DIRE="${GRUPO}"
#	echo "$DIRE"
#	mkdir $DIRE
#	mkdir "${GRUPO}/"
#	mkdir "${GRUPO}/${BINDIR}/"
#	mkdir "$DIR"
#	DIR="${GRUPO}/${MAEDIR}"
#	mkdir $DIR
#	DIR="${GRUPO}/${NOVEDIR}"
#	mkdir $DIR
#	DIR="${GRUPO}/${ACEPDIR}"
#	mkdir $DIR
#	DIR="${GRUPO}/${PROCDIR}"
#	mkdir $DIR
#	DIR="${GRUPO}/${REPODIR}"
#	mkdir $DIR
#	DIR="${GRUPO}/${LOGDIR}"
#	mkdir $DIR
#	DIR="${GRUPO}/${CONFDIR}"
#	mkdir $DIR
#	DIR="${GRUPO}/${RECHDIR}"
#	mkdir $DIR
	echo "Instalando Archivos Maestros y Tablas"
	#Mover los archivos maestros y las tablas 
	echo "Actualizando la configuracion del sistema"
	escribirLog   
	#Hay q almacenar la informacion de configuracion del sistema en el archivo afrainst.conf en confdir grabando un registro para cada
	#una de las variables indicadas durante este proceso
	#Borrar archivos temporarios si es q los hay
	echo "Instalacion CONCLUIDA"
}

#PASO20.4
escribirLog () {
	

}

# ******************** MAIN DEL PROGRAMA ********************************************************************************************************
verificarInstalacion; #PASO 1 - 4 TODO:falta paso 2
definicionesInstalacion; #PASO 5 - 20
fin #PASO 21
#instalacion


#  BUGS Y MEJORAS #
# - Chequear las entradas de los reads (Si y No; los valores numericos;etc)
# - Creacion de carpetas (antes las creaba pero en la carpeta del repo, hay qe redireccionar la creacion)
# - Ver como se guarda todos los datos de configuracion para los demas scripts
# - Ver como grabar el LOG
# - Ver que grabar en el afrainst.config
# - completar paso 2 y 20


