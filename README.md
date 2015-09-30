# 75.08 Sistemas Operativos 2° cuatrimestre 2015

## mover.sh
* HIPÓTESIS: Se pasa el path completo del file a mover.
* HIPÓTESIS: Estoy usando la secuencia NNN por cada directorio.

## gralog.sh
* Falta setear variables de configuracion

## afrainic.sh


## afrainst.sh
* Definir que va dentro del archivo Afrainst.config
* Donde va a estar la carpeta CONFDIR para buscar el archivo afrainst.config (asi vemos si esta instalado o no)
* Ver qe archivos hay qe mover a las carpetas en el final de la instalacion

## afrareci.sh
* De donde o como se carga la carpeta NOVEDIR de archivos.
* Definir el formato de los archivos en NOVEDIR
* Bloqueante hasta tener la funcionalidad MoverA

## verificUMBR.sh
* Falta hacer pruebas con la carpeta ACEPDIR
* Falta la grabacion de llamadas sospechosas y llamadas rechazadas
* Falta realizar pruebas con Afralist.sh


##Como setear las variables de ambiente

* Crear un ejemplo de .sh. Para este caso INICIAR.sh y como ejemplo agrego lo siguiente adentro, siendo verificUMBR.sh un script del TP:

  ACEPDIR=~/Grupo07/ACEPDIR

  export ACEPDIR

 ./verificUMBR.sh

* En la carpeta Grupo07/ACEPDIR (ubicada en home/<nombre_de_usuario>/Grupo07..../) estan los archivos de prueba. Ahora usando $ACEPDIR en el script verificUMBR.sh se accede a los archivos de esa carpeta



* Para hacer un ejemplo, en la terminal hacer ACEPDIR="hola" , o sino agregar en ./verificUMBR.sh 

    ls -1 $ACEPDIR

y luego ejecutar ./INICIAR.sh

*Como resultado va a quedar se deberian listar los archivos, en mi caso:

agentes.csv
BEL_20150703.csv
BEL_20150803.csv
CdA.csv
CDN_20150630.csv
CDN_20150830.csv
CdP.csv
CEN_20150630.csv
CEN_20150830.csv
centrales.csv
COS_20150629.csv
COS_20150703.csv
COS_20150727.csv
COS_20150803.csv
COS_20150810.csv
Prueba.sh
SIS_20150629.csv
SIS_20150703.csv
SIS_20150727.csv
SIS_20150803.csv
SIS_20150810.csv
umbrales.csv


