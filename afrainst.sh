#! /bin/bash

#########################################################
# AFRAINST.SH Ejecuta la instalacion del programa afrai #
#########################################################

#  Variables definidas por default

GRUPO=~/grupo07;
CONFDIR=CONF;
AFRACONFIG="$GRUPO/$CONFDIR/AFRAINST.conf";
DATASIZE=100;
MOVER="mover.sh"

existeArchivo () {
        if [ -f "$1" ];then
                return 0;
        else
                return 1;
	fi
}

#PASO1
verificarInstalacion(){
	#SACAR
	echo "Verificando instalacion..."
	read x;
	#**************************************
        existeArchivo $AFRACONFIG
        local resultado=$?
        if [ $resultado == 0 ];then
                echo "Verificando instalacion completa..."
		verificarInstalacionCompleta

		#TODO:VERIFICAR INSTALACION COMPLETA PASO 2
        else
                echo "******************* No esta instalado AFRA-l *****************"
                verificarPerl;
        fi
}

#PASO2
verificarInstalacionCompleta(){
	local estado;
	
	#traer variables del afrainst.config
	GRUPO=$(grep '^GRUPO' $AFRACONFIG | cut -d '=' -f 2)
	CONFDIR=$(grep '^CONFDIR' $AFRACONFIG | cut -d '=' -f 2)
	BINDIR=$(grep '^BINDIR' $AFRACONFIG | cut -d '=' -f 2)
	MAEDIR=$(grep '^MAEDIR' $AFRACONFIG | cut -d '=' -f 2)
	DATASIZE=$(grep '^DATASIZE' $AFRACONFIG | cut -d '=' -f 2)
	ACEPDIR=$(grep '^ACEPDIR' $AFRACONFIG | cut -d '=' -f 2)
	RECHDIR=$(grep '^RECHDIR' $AFRACONFIG | cut -d '=' -f 2)
	PROCDIR=$(grep '^PROCDIR' $AFRACONFIG | cut -d '=' -f 2)
	REPODIR=$(grep '^REPODIR' $AFRACONFIG | cut -d '=' -f 2)
	NOVEDIR=$(grep '^NOVEDIR' $AFRACONFIG | cut -d '=' -f 2)
	LOGDIR=$(grep '^LOGDIR' $AFRACONFIG | cut -d '=' -f 2)
	LOGSIZE=$(grep '^LOGSIZE' $AFRACONFIG | cut -d '=' -f 2)
	
	
	#revisar que este todo y devolver el estado de la instalacion + archivos a instalar si es que faltan
	verificarExistenciaDeDirectoriosYArchivos

}

function verificarExistenciaDeDirectoriosYArchivos() {
	dir=("$CONFDIR" "$BINDIR" "$MAEDIR" "$ACEPDIR" "$RECHDIR" "$PROCDIR" "$REPODIR" "$NOVEDIR" "$LOGDIR")
#	mae=("$BINDIR/" "$BINDIR/" "$BINDIR/" "$BINDIR/" "$BINDIR/" "$BINDIR/")
#	tab=(  	

	local K=0;
#	local H=1;
#	local G=1;

	for I in ${dir[*]}
	do
    		if [ ! -d $I ]; then # si el directorio no existe, agrego directorios que no existen al vector. 
			faltantesDir[$K]=$I;		
			let K=K+1;
			
#			if [ $I == "$BINDIR" ];then
#				for H in ${mae[*]}
#				do
#
#				done	
#			fi

#			if [ $I -eq "MAEDIR" ];then
#				for ((J=0;J<${#mae[@]};J++))
#				do
#
#				done	
		fi
  	done
	
	#verificar si faltan directorios
	if [ ${#faltantesDir[@]} -eq 0 ];then
		estado=COMPLETO
	else
		estado=INCOMPLETO
	fi
	#mostrar estado y consultar al usuario como continuar
	estadoAfrai $estado;
		
}

mostrar(){
	echo "Directorio de Configuracion: ${CONFDIR}"
	echo "Directorio de Ejecutables: ${BINDIR}"
	echo "Directorio de Maestros y Tablas: ${MAEDIR}"
	echo "Directorio de recepcion de archivos de llamadas: ${NOVEDIR}"
	echo "Directorio de Archivos de llamadas Aceptadas: ${ACEPDIR}"
	echo "Directorio de Archivos de llamadas Sospechosas: ${PROCDIR}"
	echo "Directorio de Archivos de Reportes de llamadas: ${REPODIR}"
	echo "Directorio de Archivos de Log: ${LOGDIR}"
	echo "Directorio de Archvios Rechazados: ${RECHDIR}"
	echo "Estado de la instalacion: $1"
}

estadoAfrai(){
	local estado=$1
	local respuesta;
	
	mostrar $estado;

	if [ $estado != "COMPLETO" ];then
		# listar componentes faltantes
		echo "Componentes faltanes:";
		for I in ${faltantesDir[*]}
		do
			echo $I;
		done		

		echo "Desea completar la instalacion? (Si - No)"
		read respuesta
		if [ ${respuesta^^} == "SI" ] 
		then
			echo "instalando faltantes"			
			for I in ${faltantesDir[*]}
			do
				mkdir $I;
			done	
			clear;
			estado=COMPLETO;
			mostrar $estado;
		else
			fin;
		fi
	fi	
	echo "Proceso de Instalacion Finalizado"
	fin;
}


#PASO4
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

#PASO21
fin(){
	#TODO:cerrar log
	exit
}

#PASO9
 definirEspacioNovedades(){
         #TODO: grabar en log
         local estado=1;
         while [ $estado == 1 ];do
                 echo "Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes (100) : "
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

#PASO10
verificarEspacioDisco(){
	local espacioDisco=$(df -h | grep "/$" | sed "s-^/dev/sda. *\([0-9]*[,]*[0-9]*[KMG]\) *\([0-9]*[,]*[0-9]*[KMG]\) *\([0-9]*[,]*[0-9]*[KMG]\).*-\3-");
	tamanio=$(echo "$espacioDisco" | sed "s-^\([0-9]*\).*-\1-")
	medida=$(echo "$espacioDisco" | sed "s-^\([0-9]*\)\([KMG]\).*-\2-")	
	if [ $medida == "K" ];then
		tamanio=`echo "scale=10;$tamanio/1024" | bc -l`
	fi	
	if [ $medida == "G" ];then 
		let tamanio=tamanio*1024	
	fi

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
		if [ ${respuesta^^} = "NO" ];then
			echo "Proceso Cancelado";
			fin;
		elif [ ${respuesta^^} = "SI" ];then		
			while [ ${respuesta^^} = "SI" ]
			do
				definicionesDir
				respuesta=$?
			done
		else	
			clear	
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
	echo "Espacio minimo libre para arribos: ${DATASIZE} Mb"
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
	if [ "${respuesta^^}" = "SI" ];then
		echo "Iniciando Instalacion. Esta Ud. seguro? (Si - No):"
		read respuesta2
		if [ "${respuesta2^^}" = "SI" ];then
			instalacion;
		fi
		fin;
	else
		clear
		definicionesDir
		#return "Si"
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
         local estado=1;
         while [ $estado == 1 ];do
		echo "Defina el tamanio maximo para cada archivo de log en Kbytes (400):"
		read LOGSIZE
                LOGSIZE=`echo $LOGSIZE | grep "^[0-9]*$"`
                if [ -z $LOGSIZE ];then
                        echo "No pose caracteres numericos, intente nuevamente"
		else	
			estado=0; 
		fi
         done
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

variables=(${CONFDIR} ${BINDIR} ${MAEDIR} ${NOVEDIR} ${ACEPDIR} ${PROCDIR} ${PROCDIR}/proc ${REPODIR} ${LOGDIR} ${RECHDIR} ${RECHDIR}/llamadas)
	echo "Creando Estructuras de directorio"
	mkdir $GRUPO	
	for index in ${variables[*]}
	do
    		echo "Creando $index"
		mkdir $GRUPO/$index

	done

	escribirConfig;
	moverArchivos;
	
	echo "Actualizando la configuracion del sistema"
	#	escribirLog   
	#Borrar archivos temporarios si es q los hay
	echo "Instalacion CONCLUIDA"
}

moverArchivos (){
	posicionActual=`pwd`

	moverEjecutablesYFunciones
	moverMaestrosYTablas
}

#PASO20.2
moverEjecutablesYFunciones () {
	local ejecutables=`ls "$posicionActual/BIN"`
	
	echo "Instalando Programas y Funciones"
	for archivoejec in ${ejecutables[*]}
	do
		$posicionActual/$MOVER $posicionActual/BIN/$archivoejec $GRUPO/$BINDIR 
	done
	read x
}

#PASO20.3
moverMaestrosYTablas () {
	local maestros=`ls "$posicionActual/MAE"`

	echo "Instalando Archivos Maestros y Tablas"
	#Mover los archivos maestros y las tablas
	for archivomae in ${maestros[*]}
	do
    		echo "moviendo $archivomae"
		$posicionActual/$MOVER $posicionActual/MAE/$archivomae $GRUPO/$MAEDIR 
	done
}

#PASO20.4
escribirConfig () {
	#grabar
	#GRUPO
	echo "GRUPO=$GRUPO" >> $AFRACONFIG
	#CONFDIR
	echo "CONFDIR=$GRUPO/$CONFDIR" >> $AFRACONFIG
	#BINDIR
	echo "BINDIR=$GRUPO/$BINDIR" >> $AFRACONFIG
	#MAEDIR
	echo "MAEDIR=$GRUPO/$MAEDIR" >> $AFRACONFIG
	#NOVEDIR
	echo "DATASIZE=$DATASIZE" >> $AFRACONFIG
	#NOVEDIR
	echo "NOVEDIR=$GRUPO/$NOVEDIR" >> $AFRACONFIG
	#ACEPDIR
	echo "ACEPDIR=$GRUPO/$ACEPDIR" >> $AFRACONFIG
	#PROCDIR
	echo "PROCDIR=$GRUPO/$PROCDIR" >> $AFRACONFIG
	#PROCDIR/proc	
	
	#REPODIR
	echo "REPODIR=$GRUPO/$REPODIR" >> $AFRACONFIG
	#LOGDIR
	echo "LOGDIR=$GRUPO/$LOGDIR" >> $AFRACONFIG
	#LOGSIZE
	echo "LOGSIZE=$LOGSIZE" >> $AFRACONFIG
	#RECHDIR
	echo "RECHDIR=$GRUPO/$RECHDIR" >> $AFRACONFIG
	#RECHDIR/llamadas
}

# ******************** MAIN DEL PROGRAMA ********************************************************************************************************
verificarInstalacion; #PASO 1 - 4 TODO:falta paso 2
definicionesInstalacion; #PASO 5 - 20
fin #PASO 21
#instalacion

#definirLogSize

#  BUGS Y MEJORAS #
# - Ver como grabar el LOG
# - completar paso 2/3/20
# - Verificar que los nombres de los directorios no se dupliquen
# - grabar afrainst.conf con el formato correspondiente
# Ejemplo: GRUPO=/usr/alumnos/temp/grupo01=alumnos=09/04/2015 10:03 p.mcd 
