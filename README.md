# 75.08 Sistemas Operativos 2° cuatrimestre 2015

##HIPOTESIS
* Si se instala afrai y luego de quiere reinstalar se debe descomprimir los archivos nuevamente

## arrancar.sh
* Falta logear.
* Forma de llamarlo desde otro script: $BINDIR/arrancar.sh <comando a arrancar> <comando que lo llama>
 
## detener.sh
* falta loguear, solo sirve para detener el demonio, afrareci

## funcionesComunes
* tiene funciones para llamar desde cualquier script como verificar si esta inicializado el ambiente

## mover.sh
* HIPÓTESIS: Se pasa el path completo del file a mover.
* HIPÓTESIS: Estoy usando la secuencia NNN por cada directorio.

## gralog.sh
* HIPÓTESIS: Tomo las últimas 50 líneas al truncar.

## afrainic.sh
* Falta terminar deseaArrancar() -> necesito saber cómo funciona/se usa cada comando

## afrainst.sh
* falta logear

## afrareci.sh
* Perfeccionar LOG
* Llamar al AFRAUMBR en PARALELO: Probar si al correrlo en paralelo se puede ingresar cosas por teclado

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
