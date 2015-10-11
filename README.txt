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
				Pasos a seguir para correr el Sistema Operativo
################################################################################################################################################



################################################################################################################################################
				Pasos a seguir en la instalación y ejecución del programa AFRA-I
################################################################################################################################################

	a- Insertar el dispositivo de almacenamiento con el contenido del tp (pen drive, cd, etc).

	b- Ubicarse en el directorio donde se desea instalar el programa. 

	c- Copiar el archivo afrai.tar.gz en el directorio mencionado anteriormente.

	d- Descomprimir el archivo afrai.tar.gz. (Boton derecho sobre el archivo, Extraer Aqui)

	e. Luego de esto, se habrá creado la carpeta grupo07, la cual es la base del programa.

	f. Para instalar el programa, se deberá ir a la ruta de esta carpeta base mediante la consola y ejecutar el instalador:

		$ cd [ruta_programa]
		$ cd afrai
		$ ./afrainst.sh
	
	g. Luego de haber seguido los pasos indicados en el instalador, si este finalizó correctamente, se habrán creado varias carpetas 
	   Dirigirse a la carpeta definida para los ejecutables (por defecto /bin):

	   	$ cd bin

	h. Luego habrá que inicializar el programa mediante el siguiente comando:

		$ . ./afrainic.sh

	 En este momento, el usuario podrá elegir entre ejecutar el demonio afrareci o no.
	   De decidir no ejecutarlo, podrá hacerlo luego manualmente mediante el siguiente comando:

		$ arrancar.sh afrareci

	i. Si el usuario quiere detener la ejecucion de este demonio, deberá escribir:

		$ detener.sh afrareci

	j. (Falta agregar "Cualquier otra indicación que considere necesaria")
