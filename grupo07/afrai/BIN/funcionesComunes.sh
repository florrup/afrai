# verifica si esta levantado el ambiente
# devuelve: 0 si, 1 no
function ambienteInicializado(){

	if [ "${GRUPO}" == "" ]; then	
		return 1
	fi

	if [ "${CONFDIR}" == "" ]; then	
		return 1
	fi

	if [ "${BINDIR}" == "" ]; then	
		return 1
	fi

	if [ "${MAEDIR}" == "" ]; then	
		return 1
	fi

	if [ "${NOVEDIR}" == "" ]; then	
		return 1
	fi

	if [ "${DATASIZE}" == "" ]; then	
		return 1
	fi

	if [ "${ACEPDIR}" == "" ]; then	
		return 1
	fi

	if [ "${RECHDIR}" == "" ]; then	
		return 1
	fi

	if [ "${PROCDIR}" == "" ]; then	
		return 1
	fi

	if [ "${REPODIR}" == "" ]; then	
		return 1
	fi

	if [ "${LOGDIR}" == "" ]; then	
		return 1
	fi

	if [ "${LOGSIZE}" == "" ]; then	
		return 1
	fi	

	return 0
}

function getPid(){
    local ppid=` ps aux | grep "\(/bin/bash\)\ $BINDIR/$1.sh" | grep -v grep | awk '{print $2}' | head -n 1`
    echo $ppid
}