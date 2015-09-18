#! bin/bash

GRUPO="/home/key"

# ********************************************Acuerdo de Licencia de Software**********************************************************

licencia () {
# tengo q averiguar como hacer un DO WHILE
	echo "*****************************************************************"
	echo "*              Proceso de Instalacion de "AFRA-I"               *"
	echo "*    Tema I Copyright  Grupo 07 - Segundo Cuatrimestre 2015     *"
	echo "*****************************************************************"
	echo "A T E N C I O N: Al instalar UD. expresa aceptar los terminos y condiciones"
	echo "del "ACUERDO DE LICENCIA DE SOFTWARE" incluido en este paquete."
	echo "Acepta? (Si - No)"
	read respuesta
	if [ respuesta = "Si" ]; then
		echo "Sigue"
	else
		echo "Salir"
	fi
		
}

# *************************************************************************************************************************************
verifInstalacion () {
	estado=$1
	#echo "Directorio de Configuracion: $CONFDIR"
	echo "Directorio de Ejecutables: $BINDIR"
	echo "Directorio de Maestros y Tablas: $MAEDIR"
	echo "Directorio de recepcion de archivos de llamadas: $NOVEDIR"
	echo "Directorio de Archivos de llamadas Aceptadas: $ACEPDIR"
	echo "Directorio de Archivos de llamadas Sospechosas: $PROCDIR"
	echo "Directorio de Archivos de Reportes de llamadas: $REPODIR"
	echo "Directorio de Archivos de Log: $LOGDIR"
	echo "Directorio de Archvios Rechazados: $RECHDIR"
	echo "Estado de la instalacion: ${estado}"
	echo "Proceso de Instalacion Finalizado"
}
# **************************************************************************************************************************************
# ********************************************Definicion de directorios, extensiones, longitudes****************************************
definirBinDir () {
	echo "Defina el directorio de ejecutables ($GRUPO/bin):"
	read BINDIR
	if [ ! -d "${BINDIR}" ];then	
		echo "Directorio ya existente"	
	fi
}

definirMaeDir () {
	echo "Defina el directorio para maestros y tablas ($GRUPO/mae):"
	read MAEDIR
	if [ ! -d "${MAEDIR}" ];then
		echo "Directorio ya existente"	
	fi
}

definirNoveDir () {
	echo "Defina el directorio de recepcion de archivos de llamadas ($GRUPO/novedades):"
	read NOVEDIR
	if [ ! -d "${NOVEDIR}" ];then	
		echo "Directorio ya existente"	
	fi
}

definirAcepDir () {
	echo "Defina el directorio de grabacion de los archivos de llamadas aceptadas ($GRUPO/aceptadas):"
	read ACEPDIR
	if [ ! -d "${ACEPDIR}" ];then	
		echo "Directorio ya existente"	
	fi
}

definirProcDir () {
	echo "Defina el directorio de grabacion de los registros de llamadas sospechosas ($GRUPO/sospechosas):"
	read PROCDIR
	if [ ! -d "${PROCDIR}" ];then	
		echo "Directorio ya existente"	
	fi
}


definirRepoDir () {
	echo "Defina el directorio de grabacion de los reportes ($GRUPO/reportes):"
	read REPODIR
	if [ ! -d "${REPODIR}" ];then		
		echo "Directorio ya existente"	
	fi
}

definirLogDir () {
	echo "Defina el directorio para los archivos de log ($GRUPO/log):"
	read LOGDIR
	if [ ! -d "${LOGDIR}" ];then
		echo "Directorio la existente"	
	fi
}

definirLogExt () {
	echo "Defina nombre para la extension de los archivos de log (log):"
	read LOGEXT
	#Falta verificar que la longitud sea menor o igual a 5
}

definirLogSize () {
	echo "Defina el tamanio maximo para cada archivo de log en Kbytes (400):"
	read LOGSIZE
}


definirRechDir () {
	echo "Defina el directorio de grabacion de Archivos rechazados ($GRUPO/rechazadas):"
	read RECHDIR
	if [ -d "${RECHDIR}" ];then
		echo "Directorio ya existente"	
	fi
}
# **********************************************************************************************************************************
# ***********************************************Creando las Estructuras************************************************************

instalacion () {
	mkdir "${BINDIR}"
	mkdir "${MAEDIR}"
	mkdir "${NOVEDIR}"
	mkdir "${ACEPDIR}"
	mkdir "${PROCDIR}"
	mkdir "${REPODIR}"
	mkdir "${LOGDIR}"
	mkdir "${RECHDIR}"
}

# **********************************************************************************************************************************

definirBinDir 
definirRechDir
definirLogDir
definirRepoDir
definirProcDir
definirAcepDir
definirNoveDir
definirMaeDir
verifInstalacion
