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
 	
	Ingresar en la página http://materias.fi.uba.ar/7508/Boot-usb/CDLinux.html, y seguir los pasos indicados en la misma para
	la creación del pen-drive booteable.
	Una vez que tengamos el pen-drive booteable lo conectamos y al prender la PC elegimos la opción de bootear desde el pen-drive 
	(o en su defecto hacerlo desde la EFI).
	Luego de inicializar el sistema desde el pen-drive, por pantalla nos dará lugar a elegir si queremos usar la versión de prueba
	"try Ubuntu" o instalar Ubuntu "Install Ubuntu". Elegimos la versión de prueba.
	Al realizar todos los pasos anteriores, vamos a tener el sistema andando y preparado para poder correr AFRAI, entre otras cosas.
	Es recomendable, tener en el pen-drive (o en otro dispositivo) afrai.tar.gz con el cual se podrá iniciar la instalación de AFRAI,
	descripta en el siguiente paso.

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
afralist.pl presente en la carpeta de ejecutables. Una vez ejecutado el comando debe escribir las instrucciones que desea ejecutar:

	Menu de ayuda (-h): Mostrara en pantalla un menu de ayuda mas especifico del comando.

	Consultar (-r): Ira preguntando por pantalla por qué tipo de filtro se quiere realizar la consulta. Ademas usted puede agregarle la opcion guardar (-w), si escribe esta opcion el resultado de la operacion se almacenara en un archivo de subllamadas. En caso de no incorporar la opcion se mostrara el resultado por pantalla.

	Estadisticas (-s): Puede realizar estadisticas sobre los archivos de llamadas sospechosas, seleccionando uno, alguno o todos los archivos de llamadas. Luego debe seleccionar en un menu cual estadistica es la que desea ver. Nuevamente si agrega la opcion guardar (-w), usted podra guardar la salida de la operacion en un archivo con nombre a eleccion, en caso de no invocar esa opcion, mostrara la salida por pantalla.




################################################################################################################################################
