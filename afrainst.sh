#! /bin/bash

#########################################################
# AFRAINST.SH Ejecuta la instalacion del programa afrai #
#########################################################

#  Variables definidas por default

posicionActual=`pwd`
GRUPO=~/grupo07;
CONFDIR=CONF;
AFRACONFIG="$GRUPO/$CONFDIR/AFRAINST.conf";
DATASIZE=100;
MOVER="mover.sh"
GRALOG="gralog.sh"

existeArchivo () {
        if [ -f "$1" ];then
                return 0;
        else
                return 1;
	fi
}

#PASO1
verificarInstalacion(){
	echo "Verificando instalacion..."
        existeArchivo $AFRACONFIG
        local resultado=$?
        if [ $resultado == 0 ];then
                echo "Verificando instalacion completa..."
		verificarInstalacionCompleta
        else
                echo "Afrai no esta instalado en su PC"
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
	dir=("$CONFDIR" "$BINDIR" "$MAEDIR" "$ACEPDIR" "$RECHDIR" "$RECHDIR/llamadas" "$PROCDIR" "$PROCDIR/proc" "$REPODIR" "$NOVEDIR" "$LOGDIR")
	bin=("README.md" "mover.sh" "gralog.sh" "funcionesComunes.sh" "detener.sh" "arrancar.sh" "afraumbr.sh" "afrareci.sh" "afralist.pl" "afrainic.sh")
	mae=("umbral.tab" "tllama.tab" "CdP.mae" "CdC.mae" "CdA.mae" "agentes.mae")


	local K=0;
	for I in ${dir[*]}
	do
   		if [ ! -d $I ]; then # si el directorio no existe, agrego directorios que no existen al vector. 
			faltantesDir[$K]=$I;		
			let K=K+1;
		fi
 	done


	local H=0;
	for I2 in ${bin[*]}
	do
		if [ ! -f "$BINDIR/$I2" ];then 
			faltantesBin[$H]=$I2;
			let H=H+1;
		fi
	done	


	local G=0;
	for I3 in ${mae[*]}
	do
		if [ ! -f "$MAEDIR/$I3" ];then 
			faltantesMae[$G]=$I3;
			let G=G+1;
		fi
	done	

	#verificar si faltan directorios
	if [ ${#faltantesDir[@]} -eq 0 -a ${#faltantesBin[@]} -eq 0 -a ${#faltantesMae[@]} -eq 0 ];then
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

mostrarFaltantes (){
	for I in ${faltantesDir[*]}
	do
		echo $I;
	done

	for I2 in ${faltantesBin[*]}
	do
		echo $BINDIR/$I2;
	done	

	for I3 in ${faltantesMae[*]}
	do
		echo $MAEDIR/$I3;
	done
}

instalarFaltantes () {
	for I in ${faltantesDir[*]}
	do
		mkdir $I;
	done

	posicionActual=`pwd`
	
	for I2 in ${faltantesBin[*]}
	do
		$posicionActual/$MOVER $posicionActual/BIN/$I2 $BINDIR  
	done

	posicionActual=`pwd`

	for I3 in ${faltantesMae[*]}
	do
		$posicionActual/$MOVER $posicionActual/MAE/$I3 $MAEDIR  
	done
}

estadoAfrai(){
	local estado=$1
	local respuesta;
	
	mostrar $estado;

	if [ $estado != "COMPLETO" ];then
		# listar componentes faltantes
		echo "Componentes faltanes:";	
		mostrarFaltantes;
		echo "Desea completar la instalacion? (Si - No)"
		read respuesta
		if [ ${respuesta^^} == "SI" ] 
		then
			echo "instalando faltantes"			
			instalarFaltantes;	
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
	echo "Verificando instalacion de Perl..."
	local datosPerl=`perl -v`
	local version=$(echo "$datosPerl" | grep " perl [0-9]" | sed "s-.*\(perl\) \([0-9]*\).*-\2-")
	if [ $version -ge 5 ];then
		echo "Perl version: $datosPerl"
		$posicionActual/$GRALOG "$0" "$datosPerl" "INFO"
	else
		local MENSAJE="Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente. Proceso de Instalación Cancelado"
		echo "Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior"
		echo "Efectúe su instalación e inténtelo nuevamente"
		echo "Proceso de Instalación Cancelado"
		$posicionActual/$GRALOG "$0" "$MENSAJE" "ERR"
		fin;
	fi
}

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
		local MENSAJE="Proceso de Instalacion de \"AFRA-I\" Tema I Copyright  Grupo 07 - Segundo Cuatrimestre 2015 A T E N C I O N: Al instalar UD. expresa aceptar los terminos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete. Acepta? (Si - No): ${respuesta^^}"
		$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
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
		local MENSAJE="Defina el directorio de ejecutables ($GRUPO/bin):" 
		echo "$MENSAJE"
		read BINDIR
		existeDir $BINDIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $BINDIR" "INFO"
	done
}

#PASO7
definirMaeDir () {		
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio para maestros y tablas ($GRUPO/mae):"
		echo "$MENSAJE"
		read MAEDIR
		existeDir $MAEDIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $MAEDIR" "INFO"
	done
}

#PASO8
definirNoveDir () {	
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio de recepción de archivos de llamadas ($GRUPO/novedades):"
		echo "$MENSAJE"
		read NOVEDIR
		existeDir $NOVEDIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $NOVEDIR" "INFO"
	done
}

#PASO9
 definirEspacioNovedades(){
         local estado=1;
         while [ $estado == 1 ];do
		 local MENSAJE="Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes (100) : "
                 echo "$MENSAJE"
                 read DATASIZE
                 DATASIZE=`echo $DATASIZE | grep "^[0-9]*$"`
                 if [ ! -z $DATASIZE ];then
			 $posicionActual/$GRALOG "$0" "$MENSAJE $DATASIZE" "INFO"
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
		local MENSAJE="Insuficiente espacio en disco. Espacio disponible: $tamanio Mb. Espacio requerido $DATASIZE Mb. Inténtelo nuevamente."
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $tamanio Mb."
		echo "Espacio requerido $DATASIZE Mb"
		echo "Inténtelo nuevamente."
		$posicionActual/$GRALOG "$0" "$MENSAJE" "ERR"
		return 1;
	else
		return 0;
	fi
}



#PASO11
definirAcepDir () {	
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio de grabacion de los archivos de llamadas aceptadas ($GRUPO/aceptadas):"
		echo "$MENSAJE"
		read ACEPDIR
		existeDir $ACEPDIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $ACEPDIR" "INFO"
	done
}

#PASO12
definirProcDir () {
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio de grabacion de los registros de llamadas sospechosas ($GRUPO/sospechosas):"
		echo "$MENSAJE"
		read PROCDIR
		existeDir $PROCDIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $PROCDIR" "INFO"
	done
}

#PASO13
definirRepoDir () {	
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio de grabacion de los reportes ($GRUPO/reportes):"
		echo "$MENSAJE"
		read REPODIR
		existeDir $REPODIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $REPODIR" "INFO"
	done
}

#PASO14
definirLogDir () {
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio para los archivos de log ($GRUPO/log):"
		echo "$MENSAJE"
		read LOGDIR
		existeDir $LOGDIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $LOGDIR" "INFO"
	done
}

#PASO15
definirLogExt () {
	local estado=1 
	while [ $estado == 1 ];do
		local MENSAJE="Defina nombre para la extension de los archivos de log (log):"
		echo "$MENSAJE"
		read LOGEXT
		#TODO VER REGEX DE CANTIDAD DE CARACTERES		
		#LONGITUD=`echo $LOGEXT | grep "^.{1,5}$"`
        	#        if [ ! -z $LONGITUD ];then
				 $posicionActual/$GRALOG "$0" "$MENSAJE $LOGEXT" "INFO"
				 estado=0
        	#         else
        	#                 echo "Debe ingresar una extensión con un máximo de 5 caracteres"
        	#         fi
	done
}

#PASO16
definirLogSize () {
         local estado=1;
	 local MENSAJE="Defina el tamanio maximo para cada archivo de log en Kbytes (400):"
         while [ $estado == 1 ];do
		echo "$MENSAJE"
		read LOGSIZE
                LOGSIZE=`echo $LOGSIZE | grep "^[0-9]*$"`
                if [ -z $LOGSIZE ];then
                        echo "No pose caracteres numericos, intente nuevamente"
		else	
			$posicionActual/$GRALOG "$0" "$MENSAJE $LOGSIZE" "INFO"
			estado=0; 
		fi
         done
}
#PASO17
definirRechDir () {
	local estado=1
	local MENSAJE="Defina el directorio de grabacion de Archivos rechazados ($GRUPO/rechazadas):"
	while [ $estado -eq 1 ]
	do	
		echo "$MENSAJE"
		read RECHDIR
		existeDir $RECHDIR
		estado=$?
		$posicionActual/$GRALOG "$0" "$MENSAJE $RECHDIR" "INFO"
	done
}

#PASO18Y19
mostrarDefiniciones () {
	local MENSAJE="Directorio de Ejecutables: ${BINDIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Maestros y Tablas: ${MAEDIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de recepcion de archivos de llamadas: ${NOVEDIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Espacio minimo libre para arribos: ${DATASIZE} Mb"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de llamadas Aceptadas: ${ACEPDIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de llamadas Sospechosas: ${PROCDIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de Reportes de llamadas: ${REPODIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de Log: ${LOGDIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Extension para los archivos de log: ${LOGEXT}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Tamanio maximo para los archivos de log: ${LOGSIZE} Kb"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archvios Rechazados: ${RECHDIR}"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Estado de la instalacion: LISTA"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Desea continuar con la instalacion? (Si - No):"
	echo "$MENSAJE"
	read respuesta
	$posicionActual/$GRALOG "$0" "$MENSAJE $respuesta" "INFO"
	if [ "${respuesta^^}" = "SI" ];then
		MENSAJE="Iniciando Instalacion. Esta Ud. seguro? (Si - No):"
		echo "$MENSAJE"
		read respuesta2
		$posicionActual/$GRALOG "$0" "$MENSAJE $respuesta2" "INFO"
		if [ "${respuesta2^^}" = "SI" ];then
			instalacion;
		fi
		fin;
	else
		clear
		definicionesDir
		#TODO QUE ES ESTO
		#return "Si"
	fi	
}

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
	local MENSAJE="Actualizando la configuracion del sistema"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
	escribirConfig;
	moverArchivos;
	#Borrar archivos temporarios si es q los hay
	MENSAJE="Instalacion CONCLUIDA"
	echo "$MENSAJE"
	$posicionActual/$GRALOG "$0" "$MENSAJE" "INFO"
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
	WHEN=`date +%T-%d-%m-%Y`
	WHO=${USER}

	#GRUPO
	echo "GRUPO=$GRUPO=$WHO=$WHEN" >> $AFRACONFIG
	#CONFDIR
	echo "CONFDIR=$GRUPO/$CONFDIR=$WHO=$WHEN" >> $AFRACONFIG
	#BINDIR
	echo "BINDIR=$GRUPO/$BINDIR=$WHO=$WHEN" >> $AFRACONFIG
	#MAEDIR
	echo "MAEDIR=$GRUPO/$MAEDIR=$WHO=$WHEN" >> $AFRACONFIG
	#NOVEDIR
	echo "DATASIZE=$DATASIZE=$WHO=$WHEN" >> $AFRACONFIG
	#NOVEDIR
	echo "NOVEDIR=$GRUPO/$NOVEDIR=$WHO=$WHEN" >> $AFRACONFIG
	#ACEPDIR
	echo "ACEPDIR=$GRUPO/$ACEPDIR=$WHO=$WHEN" >> $AFRACONFIG
	#PROCDIR
	echo "PROCDIR=$GRUPO/$PROCDIR=$WHO=$WHEN" >> $AFRACONFIG	
	#REPODIR
	echo "REPODIR=$GRUPO/$REPODIR=$WHO=$WHEN" >> $AFRACONFIG
	#LOGDIR
	echo "LOGDIR=$GRUPO/$LOGDIR=$WHO=$WHEN" >> $AFRACONFIG
	#LOGSIZE
	echo "LOGSIZE=$LOGSIZE=$WHO=$WHEN" >> $AFRACONFIG
	#RECHDIR
	echo "RECHDIR=$GRUPO/$RECHDIR=$WHO=$WHEN" >> $AFRACONFIG
}

#PASO21
fin(){
	$posicionActual/$GRALOG "$0" "Fin de Instalacion" "INFO"
	exit
}

# ******************** MAIN DEL PROGRAMA ********************************************************************************************************
verificarInstalacion; #PASO 1 - 4
definicionesInstalacion; #PASO 5 - 20
fin #PASO 21

#  BUGS Y MEJORAS #
# - Ver entrada de max 5 caracteres en extension del log
# - Verificar que los nombres de los directorios no se dupliquen


