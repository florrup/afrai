# 75.08 Sistemas Operativos 2° cuatrimestre 2015

## arrancar.sh
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
* HIPOTESIS: Si se instala afrai y luego de quiere reinstalar se debe descomprimir los archivos nuevamente

## afrareci.sh
* Tiempo entre ciclos: 30 segundos.

## verificUMBR.sh
* HIPOTESIS: Si se encuentras mas de un umbral se toma el primer registro 
* Falta realizar pruebas con Afralist.sh
