################################################################################################################################################
	FIUBA - 75.08 - Sistemas Operativos - Segundo Cuatrimestre 2015
	   GRUPO N° 7
			
	      	# Andújar, Martín
	      	# Centurión, Ramón
		# Guerini, Francisco
		# Nakasone, Nicolás
		# Rupcic,Florencia
		# Vallerino,Gonzalo

################################################################################################################################################
				Descripcion del Programa
################################################################################################################################################
		
        El Departamento de Prevención de Fraudes de cierta empresa desea realizar un control sobre las
	llamadas telefónicas para evitar el uso fraudulento de las comunicaciones de la empresa.
	Para realizar dicho control recibe archivos de llamadas desde cada una de sus centrales telefónicas.
	El control de llamadas consistirá, para el alcance de este TP, en comprobar si la llamada se
	encuentra dentro del umbral de consumo determinado por la empresa.
	Si supera el umbral, se considera que el consumo es sospechoso.
	El sistema AFRA-I se encargará entonces de realizar validaciones sobre registros y dicho control mencionado 
	sobre las llamadas que bajo ciertas condiciones se consideran sospechosas y luego realizar un reporte de las 
	que finalmente terminaron siendo clasificadas de esta manera.

################################################################################################################################################
				Pasos a seguir para correr el Sistema Operativo
################################################################################################################################################



################################################################################################################################################
				Requisitos de instalacion
################################################################################################################################################

	Contar con Perl versión 5 o superior.
	Contar con un espacio mínimo superior al especificado para almacenar el flujo de novedades.
		
################################################################################################################################################
				Pasos a seguir en la instalación y ejecución del programa AFRA-I
################################################################################################################################################

	a- Insertar el dispositivo de almacenamiento con el contenido del tp (pen drive, cd, etc).

	b- Ubicarse en el directorio donde se desea instalar el programa. 

	c- Copiar el archivo afrai.tar.gz en dicho directorio .

	d- Descomprimir el archivo afrai.tar.gz. con la opcion Click Derecho-->Extraer Aqui.

	e. Luego de esto, se habrá creado la carpeta grupo07, la cual es la base del programa.

	f. Para instalar el programa, se deberá ir a la ruta de esta carpeta base mediante la consola y ejecutar el instalador:

		$ cd [ruta_programa]
		$ cd afrai
		$ ./afrainst.sh
	
	g. Luego de haber seguido los pasos indicados en el instalador afrainst.sh, si este finalizó correctamente, se podrá ver que se crearon varias carpetas.
	   Dirigirse luego a la carpeta definida para los ejecutables (por defecto /bin):

	   	$ cd bin

	h. Luego inicializar el programa mediante el siguiente comando:

		$ . ./afrainic.sh

	   En este momento,se puede optar por ejecutar el demonio afrareci o no.
	   Si se decide no ejecutarlo,puede hacer manualmente mediante el siguiente comando:

		$ arrancar.sh afrareci

	i. Si el usuario quiere detener la ejecucion de este demonio, deberá escribir:

		$ detener.sh afrareci

################################################################################################################################################
			GENERAR CONSULTAS, INFORMES Y ESTADISTICAS	
################################################################################################################################################

Luego de haber procesado los archivos, se pueden generar consultas, informes y estadisticas usando el comando
afralist.pl presente en la carpeta de ejecutables. Para ver detalladamente cómo usarlo, ejecutar el comando:
	afralist.pl -h
que mostrará por pantalla el manual de ayuda del mismo.

	afralist.pl -r
Ira preguntando por pantalla por qué tipo de filtro se quiere realizar la consulta. Es obligatorio al menos seleccionar un filtro, en caso de no hacerlo, vuelve a realizar desde el principio que filtro desea aplicar. En caso de incorporar -w como parámetro la consulta se persistirá en REPODIR con el nombre resultado.xxx con xxx la numeración en orden de la consulta a grabar realizada.

	afralist.pl -s
Solicita filtro sobre la gestion o sobre el rango de fechas sobre los que se desea realizar la estadística. El filtro es obligatorio, en caso de no seleccionar ninguno, se le solicitarán los filtros nuevamente hasta seleccionar al menos uno. La estadística agrupa por gestión y año, mostrando cantidad de resoluciones, cantidad de disposiciones y cantidad de convenios. En caso de incorporar -w como parámetro los resultados los persiste en la carpeta REPODIR con el nombre a elección.




################################################################################################################################################
