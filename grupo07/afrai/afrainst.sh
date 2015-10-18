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
MOVER="$GRUPO/afrai/BIN/mover.sh"
GRALOG="$GRUPO/afrai/BIN/gralog.sh"
caracteresInvalidos="\ / : * ? \" < > .|"

existeArchivo () {
        if [ -f "$1" ];then
                return 0;
        else
                return 1;
	fi
}

#PASO1
verificarInstalacion(){
	echo -e "\nVerificando instalación...\n"
        existeArchivo $AFRACONFIG
        local resultado=$?
        if [ $resultado == 0 ];then
                echo "Verificando instalación completa..."
		verificarInstalacionCompleta
        else
                echo -e "AFRA-I no está instalado en su PC\n"
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
	LOGEXT=$(grep '^LOGEXT' $AFRACONFIG | cut -d '=' -f 2)

	#revisar que este todo y devolver el estado de la instalacion + archivos a instalar si es que faltan
	verificarExistenciaDeDirectoriosYArchivos

}

function verificarExistenciaDeDirectoriosYArchivos() {
	dir=("$CONFDIR" "$BINDIR" "$MAEDIR" "$ACEPDIR" "$RECHDIR" "$RECHDIR/llamadas" "$PROCDIR" "$PROCDIR/proc" "$REPODIR" "$NOVEDIR" "$LOGDIR")
	bin=("mover.sh" "gralog.sh" "funcionesComunes.sh" "detener.sh" "arrancar.sh" "afraumbr.sh" "afrareci.sh" "afralist.pl" "afrainic.sh")
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
	echo "Directorio de Configuración: ${CONFDIR}"
	echo "Directorio de Ejecutables: ${BINDIR}"
	echo "Directorio de Maestros y Tablas: ${MAEDIR}"
	echo "Directorio de recepción de archivos de llamadas: ${NOVEDIR}"
	echo "Directorio de Archivos de llamadas Aceptadas: ${ACEPDIR}"
	echo "Directorio de Archivos de llamadas Sospechosas: ${PROCDIR}"
	echo "Directorio de Archivos de Reportes de llamadas: ${REPODIR}"
	echo "Directorio de Archivos de Log: ${LOGDIR}"
	echo "Directorio de Archvios Rechazados: ${RECHDIR}"
	echo -e "\nEstado de la instalación: $1"
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
		cp $posicionActual/BIN/$I2 $BINDIR  
	done

	posicionActual=`pwd`

	for I3 in ${faltantesMae[*]}
	do
		cp $posicionActual/MAE/$I3 $MAEDIR  
	done
}

estadoAfrai(){
	local estado=$1
	local respuesta;
	
	mostrar $estado;

	if [ $estado != "COMPLETO" ];then
		# listar componentes faltantes
		echo "Componentes faltantes:";	
		mostrarFaltantes;
		echo "¿Desea completar la instalación? (Si - No)"
		read respuesta
		if [ ${respuesta^^} == "SI" ] 
		then
			echo "Instalando faltantes..."			
			instalarFaltantes;	
			clear;
			estado=COMPLETO;
			mostrar $estado;
		else
			fin;
		fi
	fi	
	echo "Proceso de Instalación Finalizado"
	fin;
}


#PASO4
verificarPerl(){
	echo -e "Verificando instalación de Perl...\n"
	local datosPerl=`perl -v`
	local version=$(echo "$datosPerl" | grep " perl [0-9]" | sed "s-.*\(perl\) \([0-9]*\).*-\2-")
	if [ $version -ge 5 ];then
		echo -e "Perl version: $datosPerl \n"
		$GRALOG "$0" "$datosPerl" "INFO"
		echo "Cumple con los requisitos del sistema. Por favor oprima ENTER para continuar"
		read x
		clear
	else
		local MENSAJE="Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior. Efectúe su instalación e inténtelo nuevamente. Proceso de Instalación Cancelado"
		echo "Para ejecutar el sistema AFRA-I es necesario contar con Perl 5 o superior"
		echo "Efectúe su instalación e inténtelo nuevamente"
		echo -e "\nProceso de Instalación Cancelado\n"
		$GRALOG "$0" "$MENSAJE" "ERR"
		fin;
	fi
}

#PASO5
definicionesInstalacion() {
	local estado=0
	while [ $estado -eq 0 ]
	do	
		estado=1
		echo "*****************************************************************"
		echo "*              Proceso de Instalación de \"AFRA-I\"               *"
		echo "*    Tema I Copyright  Grupo 07 - Segundo Cuatrimestre 2015     *"
		echo "*****************************************************************"
		echo "A T E N C I Ó N: Al instalar UD. expresa aceptar los términos y condiciones"
		echo "del "ACUERDO DE LICENCIA DE SOFTWARE" incluido en este paquete."
		echo "¿Acepta? (Si - No)"	
		read respuesta
		local MENSAJE="Proceso de Instalación de \"AFRA-I\" Tema I Copyright  Grupo 07 - Segundo Cuatrimestre 2015 A T E N C I Ó N: Al instalar UD. expresa aceptar los términos y condiciones del \"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete. ¿Acepta? (Si - No): ${respuesta^^}"
		$GRALOG "$0" "$MENSAJE" "INFO"
		if [ ${respuesta^^} = "NO" ];then
			echo -e "\nProceso Cancelado\n";
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
	echo "Directorio de Configuración: ${CONFDIR}"
	echo "Directorio de Ejecutables: ${BINDIR}"
	echo "Directorio de Maestros y Tablas: ${MAEDIR}"
	echo "Directorio de recepción de archivos de llamadas: ${NOVEDIR}"
	echo "Directorio de Archivos de llamadas Aceptadas: ${ACEPDIR}"
	echo "Directorio de Archivos de llamadas Sospechosas: ${PROCDIR}"
	echo "Directorio de Archivos de Reportes de llamadas: ${REPODIR}"
	echo "Directorio de Archivos de Log: ${LOGDIR}"
	echo "Directorio de Archvios Rechazados: ${RECHDIR}"
	echo "Estado de la instalación: ${estado}"
	echo "Proceso de Instalación Finalizado"
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
		if [ "$BINDIR" = "" ];then
			BINDIR="bin"
		fi
		existeDir $BINDIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $BINDIR" "INFO"
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
		if [ "$MAEDIR" = "" ];then
			MAEDIR="mae"
		fi
		existeDir $MAEDIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $MAEDIR" "INFO"
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
		if [ "$NOVEDIR" = "" ];then
			NOVEDIR="novedades"
		fi
		existeDir $NOVEDIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $NOVEDIR" "INFO"
	done
}

#PASO9
 definirEspacioNovedades(){
         local estado=1;
         while [ $estado == 1 ];do
		 local MENSAJE="Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes (100) : "
                 echo "$MENSAJE"
                 read DATASIZE
		 if [ "$DATASIZE" = "" ];then
			DATASIZE=100
		 fi
                 DATASIZE=`echo $DATASIZE | grep "^[0-9]*$"`
                 if [ ! -z $DATASIZE ];then
			 $GRALOG "$0" "$MENSAJE $DATASIZE" "INFO"
                         verificarEspacioDisco
                         estado=$?;
                 else
                         echo "No posee caracteres numéricos, intente nuevamente"
                 fi
         done
}

#PASO10
verificarEspacioDisco(){
	local espacioDisco=`df $posicionActual | tail -n 1 | tr -s ' ' | cut -d' ' -f 4`
	let tamanio=espacioDisco/1024	
	if [ $tamanio -lt $DATASIZE ];then
		local MENSAJE="Insuficiente espacio en disco. Espacio disponible: $tamanio Mb. Espacio requerido $DATASIZE Mb. Inténtelo nuevamente."
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $tamanio Mb."
		echo "Espacio requerido $DATASIZE Mb"
		echo "Inténtelo nuevamente."
		$GRALOG "$0" "$MENSAJE" "ERR"
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
		local MENSAJE="Defina el directorio de grabación de los archivos de llamadas aceptadas ($GRUPO/aceptadas):"
		echo "$MENSAJE"
		read ACEPDIR
		if [ "$ACEPDIR" = "" ];then
			ACEPDIR="aceptadas"
		fi
		existeDir $ACEPDIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $ACEPDIR" "INFO"
	done
}

#PASO12
definirProcDir () {
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio de grabación de los registros de llamadas sospechosas ($GRUPO/sospechosas):"
		echo "$MENSAJE"
		read PROCDIR
		if [ "$PROCDIR" = "" ];then
			PROCDIR="sospechosas"
		fi
		existeDir $PROCDIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $PROCDIR" "INFO"
	done
}

#PASO13
definirRepoDir () {	
	local estado=1
	while [ $estado -eq 1 ]
	do
		local MENSAJE="Defina el directorio de grabación de los reportes ($GRUPO/reportes):"
		echo "$MENSAJE"
		read REPODIR
		if [ "$REPODIR" = "" ];then
			REPODIR="reportes"
		fi
		existeDir $REPODIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $REPODIR" "INFO"
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
		if [ "$LOGDIR" = "" ];then
			LOGDIR="log"
		fi
		existeDir $LOGDIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $LOGDIR" "INFO"
	done
}

#PASO15
definirLogExt () {
	local estado=1 
	while [ $estado == 1 ];do
		local MENSAJE="Defina nombre para la extensión de los archivos de log (log):"
		echo "$MENSAJE"
		read LOGEXT
		if [ "$LOGEXT" = "" ];then
			LOGEXT="log"
		fi
	        if [ ${#LOGEXT} -le 5 ];then
			 $GRALOG "$0" "$MENSAJE $LOGEXT" "INFO"
			 estado=0
	         else
	                 echo "Debe ingresar una extensión con un máximo de 5 caracteres"
	         fi
	done
}

#PASO16
definirLogSize () {
         local estado=1;
	 local MENSAJE="Defina el tamanio máximo para cada archivo de log en Kbytes (400):"
         while [ $estado == 1 ];do
		echo "$MENSAJE"
		read LOGSIZE
		if [ "$LOGSIZE" = "" ];then
			LOGSIZE=400
		fi
                LOGSIZE=`echo $LOGSIZE | grep "^[0-9]*$"`
                if [ -z $LOGSIZE ];then
                        echo "No pose caracteres numéricos, intente nuevamente"
		else	
			$GRALOG "$0" "$MENSAJE $LOGSIZE" "INFO"
			estado=0; 
		fi
         done
}

#PASO17
definirRechDir () {
	local estado=1
	local MENSAJE="Defina el directorio de grabación de Archivos rechazados ($GRUPO/rechazadas):"
	while [ $estado -eq 1 ]
	do	
		echo "$MENSAJE"
		read RECHDIR
		if [ "$RECHDIR" = "" ];then
			RECHDIR="rechazadas"
		fi
		existeDir $RECHDIR
		estado=$?
		$GRALOG "$0" "$MENSAJE $RECHDIR" "INFO"
	done
}

#PASO18Y19
mostrarDefiniciones () {
	local MENSAJE="Directorio de Ejecutables: ${BINDIR}"
	echo -e "\n$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Maestros y Tablas: ${MAEDIR}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de recepción de archivos de llamadas: ${NOVEDIR}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Espacio mínimo libre para arribos: ${DATASIZE} Mb"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de llamadas Aceptadas: ${ACEPDIR}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de llamadas Sospechosas: ${PROCDIR}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de Reportes de llamadas: ${REPODIR}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archivos de Log: ${LOGDIR}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Extension para los archivos de log: ${LOGEXT}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Tamanio máximo para los archivos de log: ${LOGSIZE} Kb"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Directorio de Archvios Rechazados: ${RECHDIR}"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="Estado de la instalación: LISTA"
	echo "$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	MENSAJE="¿Desea continuar con la instalación? (Si - No):"
	echo -e "\n$MENSAJE"
	read respuesta
	$GRALOG "$0" "$MENSAJE $respuesta" "INFO"
	if [ "${respuesta^^}" = "SI" ];then
		MENSAJE="Iniciando Instalación. ¿Está Ud. seguro? (Si - No):"
		echo -e "\n$MENSAJE"
		read respuesta2
		$GRALOG "$0" "$MENSAJE $respuesta2" "INFO"
		if [ "${respuesta2^^}" = "SI" ];then
			instalacion;
		fi
		fin;
	else
		clear
		definicionesDir
	fi	
}

#PASO20
instalacion () {

variables=(${BINDIR} ${MAEDIR} ${NOVEDIR} ${ACEPDIR} ${PROCDIR} ${PROCDIR}/proc ${REPODIR} ${LOGDIR} ${RECHDIR} ${RECHDIR}/llamadas)
	echo "Creando Estructuras de directorio"
	for index in ${variables[*]}
	do
    		echo "Creando $index"
		mkdir $GRUPO/$index

	done
	local MENSAJE="Actualizando la configuración del sistema"
	echo -e "\n$MENSAJE"
	$GRALOG "$0" "$MENSAJE" "INFO"
	escribirConfig;
	moverArchivos;
	#Borrar archivos temporarios si es q los hay
	MENSAJE="Instalación CONCLUÍDA"
	echo -e "\n$MENSAJE\n"
	$GRALOG "$0" "$MENSAJE" "INFO"
}

moverArchivos (){
	posicionActual=`pwd`
	moverEjecutablesYFunciones
	moverMaestrosYTablas
}

#PASO20.2
moverEjecutablesYFunciones () {
	local ejecutables=`ls "$posicionActual/BIN"`
	
	echo -e "\nInstalando Programas y Funciones"
	for archivoejec in ${ejecutables[*]}
	do
		cp $posicionActual/BIN/$archivoejec $GRUPO/$BINDIR 
	done
}

#PASO20.3
moverMaestrosYTablas () {
	local maestros=`ls "$posicionActual/MAE"`

	echo -e "\nInstalando Archivos Maestros y Tablas"
	#Mover los archivos maestros y las tablas
	for archivomae in ${maestros[*]}
	do
    		echo "moviendo $archivomae"
		cp $posicionActual/MAE/$archivomae $GRUPO/$MAEDIR 
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
	#LOGEXT
	echo "LOGEXT=$LOGEXT=$WHO=$WHEN" >> $AFRACONFIG
	#RECHDIR
	echo "RECHDIR=$GRUPO/$RECHDIR=$WHO=$WHEN" >> $AFRACONFIG
}

#PASO21
fin(){
	$GRALOG "$0" "Fin de Instalación" "INFO"
	if [ -f "$GRUPO/CONF/afrainst.log" ];then
		rm "$GRUPO/CONF/afrainst.log"
	fi
	if [ -d "$GRUPO/CONF" ];then
		$MOVER $posicionActual/afrainst.log $GRUPO/CONF
	fi
	exit
}

# ******************** MAIN DEL PROGRAMA ********************************************************************************************************
verificarInstalacion; #PASO 1 - 4
definicionesInstalacion; #PASO 5 - 20
fin #PASO 21

#  BUGS Y MEJORAS #
# - Verificar que los nombres de los directorios no se dupliquen


