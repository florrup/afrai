# 75.08 Sistemas Operativos 2° cuatrimestre 2015


## arrancar.sh

* Falta logear.
* Forma de llamarlo desde otro script: ./arrancar.sh <comando a arrancar> <comando que lo llama>
 
## detener.sh
* falta loguear, solo sirve para detener el demonio, afrareci

## funcionesComunes
* tiene funciones para llamar desde cualquier script como verificar si esta inicializado el ambiente

## mover.sh
* HIPÓTESIS: Se pasa el path completo del file a mover.
* RESPUESTA: si, vamos a pasarte la ruta entera ya que las variables de ambiente como acepdir, novedir ya van a estar con el path completo
* HIPÓTESIS: Estoy usando la secuencia NNN por cada directorio.

## gralog.sh
* Falta setear variables de configuracion

## afrainic.sh
* Falta darle permisos a los scripts. 
* Falta setear variable PATH.
* Falta terminar deseaArrancar() -> necesito saber cómo funciona/se usa cada comando

## afrainst.sh

* Ver qe archivos hay qe mover a las carpetas en el final de la instalacion

## afrareci.sh
* LOG

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



  Para hacer un ejemplo, en la terminal hacer ACEPDIR="hola" , o sino agregar en ./verificUMBR.sh 

    ls -1 $ACEPDIR

y luego ejecutar ./INICIAR.sh

Como resultado va a quedar se deberian listar los archivos, en mi caso:

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

Y si se agregaba echo "$ACEPDIR" imprimia un "hola"
