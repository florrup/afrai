
AFRACONFIG=~/grupo07/CONF/AFRAINST.conf;
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

export GRUPO 
export CONFDIR 
export BINDIR 
export MAEDIR 
export DATASIZE 
export NOVEDIR 
export ACEPDIR 
export PROCDIR 
export REPODIR 
export LOGDIR 
export RECHDIR
export LOGSIZE

#consola
#./arrancar.sh afrainst
#script
#./arrancar.sh afrainst testarrancar
#detener
./detener.sh afrainst

