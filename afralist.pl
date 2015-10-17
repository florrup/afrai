#! /usr/bin/perl

	$procdir = $ENV{PROCDIR}; #direccion donde esten los archivos a consultar
	$maedir = $ENV{MAEDIR}; #direccion donde esten los archivos Maestros
	$repodir = $ENV{REPODIR}; #direccion donde dejara los archivos de salida
	$consutaNro = 0; #contador de consulta


	# Lee el ingreso validando que sea S o N
	sub respSN {
		my $resp;
		do{
			$resp = <STDIN>;
			chomp($resp);
			$resp = uc $resp;
			if ($resp ne 'S' && $resp ne 'N'){
				print "Error, ingrese nuevamente (S/N): "
			}
		}until($resp eq 'S' || $resp eq 'N');
		$resp;
	}

	# Lee el ingreso de una cadena y la parsea en segun espacios
	sub respToken {
		my $codString = <STDIN>;
		my @return = split(' ', uc($codString));
		@return;
	}

	# Lee un string y NO lo parsea
	sub respSimple {
		my $codString = <STDIN>;
		chomp($codString);
		$codString;
	}

	# Une los codigos para generar la expresion regular
	sub unirCodigos{
		my @tokens = @_;
		my $codUni = ".*";
		if($#tokens != -1){
			$codUni = "(";
			foreach $token (@tokens){
				$codUni .= $token."|";
			}
			chop($codUni);
			$codUni .= ")";
		}
		$codUni;
	}

	# Valida la oficina
	sub validarOficina{
		my $bool = (($_[0] !~ /^[[:alnum:]]{3}$/)&&($_[0] ne "0")&&($_[0] ne "-a")&&($_[0] ne "-A"));
		$bool;
	}

	# Valida el ingreso de los anio meses
	sub validarAnioMes{
		my @anioMes = @_;
		my @aniomesValido = ();
		my $todosAM = 0;

		foreach my $am (@anioMes){
			if($am == "-a"){
				$todosAM = 1;
			}
			if($am !~ /^[0-9]{4}[0-1][0-9]$/ && $todosAM == 0){
				print "El anio mes: $am es invalido y no sera tenido en cuenta\n";
			}
			if($am =~ /^[0-9]{4}[0-1][0-9]$/ && $todosAM == 0){
				push(@aniomesValido, $am);
			}
		}
		if($#aniomesValido == -1 || $todosAM == 1){
			$aniomesValido[0] = "[0-9]{4}[0-1][0-9]\$";
			print "Se consultaran todos los anio mes del directorio\n";
		}
		@aniomesValido;
	}

	#Pregunta las oficinas y los anio mes al usuario validando ambos ingresos
	sub oficinaYaniomes{
		my @archivos = ();
		my @nombreArchivos = ();
		$ERROR = 0;
		do{
			print "Ingrese oficina (-a todas las)(0 para terminar): ";
			my $oficina = &respSimple;
			if(&validarOficina ($oficina)){
				print "Oficina invalida\n";
				$oficina = "-1";
			}
			if($oficina eq "-a" or $oficina eq "-A"){
				$oficina = /^[[:alnum:]]{3}\$/;
				print "Se consultaran todas las oficinas del directorio\n";
			}
			if($oficina ne "0" && $oficina ne "-1"){
				print "Ingrese anio mes separados por espacio de la forma (AAAAMM) ('enter': para consultar todos): ";
				my @aniomes = &respToken;
				my @aniomesValido = &validarAnioMes (@aniomes);
				foreach $am (@aniomesValido){
					push(@archivos, $oficina."_".$am);
				}
			}
		}until($oficina eq "0" || $oficina eq  /^[[:alnum:]]{3}\$/);

		#Genera una lista con el nombre completo del archivo si el archivo existe en el directorio
		foreach $archDir (@archSort){
			foreach $arch (@archivos){
				if($archDir =~ $arch){
					push(@nombreArchivos, $procdir."/".$archDir);
				}
			}
		}

		#No se encontraron archivos para abrir
		if($#nombreArchivos == -1){
			print "No se han encontrado archivos con ese nombre\n";
			$ERROR = 1;
		}

		&borrarDuplicados(@nombreArchivos);
	}


	sub borrarDuplicados {
		my %hash = ();
		foreach my $elem (@_){
			$hash{$elem} ++;
		}
		@sinDuplicado = keys %hash;
	}

	#Abre el directorio, y almacena en @archSort los archivos validos
	sub abrirDirYMostrar {
		opendir(DIR,$procdir) or die print "No se encontro el directorio \"$procdir\"\n";
		@aD=readdir(DIR);
		close(DIR);
		@aDir=();
		foreach $ad (@aD){
			next unless ($ad =~ /^.*_[0-9]{4}[0-1][0-9]$/);
			push (@aDir, $ad);
			@archSort = sort(@aDir);
		}
		
		#Muestra los archivos disponibles y validos
		print "Archivos disponibles en \"$procdir\"\n";
		$i = 0;
		foreach $aD (@archSort){
			print $aD;
			if($i<3){
				$i++;
				print "\t";
			}
			else{
				$i=0;
				print "\n";
			}
		}
		print "\n";
	}

	# Obtiene las opciones ingresadas
	sub obtenerOpciones{
		my %opcionHash = ();
		my @opciones = ();
		print "Seleccione las opciones (-h: ayuda): ";
		@opciones = &respToken;
		foreach $opcion (@opciones){
			$opcionHash{$opcion} = 0;
		}
		%opcionHash;	
	}

	# Graba en un archivo un arreglo (Nombre archivo, Arreglo a imprimir)
	sub grabarEnArch{
		my $nombreArch = shift;
		my @aImprimir = @_;
		open (ARCHSAL,">$nombreArch") or die print "No se pudo guardar en $nombreArch\n\n";
		foreach $aI (@aImprimir){
			print ARCHSAL $aI;
		}
		close (ARCHSAL);
	}

	# Pide el ingerso de un nombre valido para guardar en un archivo
	sub validarNombreArch{
		my $nombre;
		my $var;
		opendir (REPODIR, $repodir) or die print "Falta directorio de salida \"$repodir\"\n";
		@archDir = readdir(REPODIR);
		close(REPODIR);
		do{
			print "Ingrese nombre del archivo de salida: ";
			$nombre = <STDIN>;
			chomp($nombre);
			my @a = grep {$_ =~ /^$nombre$/} @archDir;
			$var = $#a;
			if($var != -1){
				print "Ya existe un archivo con el nombre $nombre.\nIngrese otro nombre:";
			}	
		}until($var == -1);
		$nombre;
	}

	# Imprime un arreglo por pantalla 
	sub imprimirArreglo{
		foreach $a (@_){
			print $a;
		}
	}

	# Ordena las claves de un hash por su valor
	sub generarRanking{
		my %hash = @_;
		my @arreglo;
		
		foreach $h (sort{$hash{$b} <=> $hash{$a} } keys %hash){
			push(@arreglo,"$h;$hash{$h}");
		}
		@arreglo;
	}

	# Ordena un hash sin contar los valores con 1
	sub generarRankingUmbrales{
		my %hash = @_;
		my %hashSin1;
		my @arreglo;
		my @a;
		foreach $h (keys %hash){
			if($hash{$h}>1){
				$hashSin1{$h} = $hash{$h};
			}
		}
		foreach $h (sort{$hashSin1{$b} <=> $hashSin1{$a} } keys %hashSin1){		
			push(@arreglo,"$h;$hashSin1{$h}");
		}
		@arreglo;
	}

	# genera el ranking de un hash sin un archivo
	sub rankingSinArchivo{
		my @completo = ();
		my @arreglo = @_;
		my @splitA = ();
		foreach $a (@arreglo){
			@splitA = split (";",$a);
			push (@completo, "$splitA[1]\t$splitA[0]\n");	
		}
		@completo;
	}

	# Agrega al ranking de agentes la informacion del archivo
	sub rankingAgentesArchivo{
		my $archivo = $maedir."/agentes.mae";	
		my @arreglo = @_;
		my @splitA = ();
		my @completo = ();

		if(open (ARCH,$archivo)){
			my @archReg = <ARCH>;
			foreach $a (@arreglo){
				@splitA = split (";",$a);
				@regGrep = grep {$_ =~ /^.*;.*;$splitA[0];.*;.*$/} @archReg;
				$regGrep[0] =~ s/;/\t/g;
				if($regGrep[0] =~ m/.*\t(.*\t.*\t.*)$/){
					push (@completo, "$splitA[1]\t$1\n");
				}	
			}
		}
		else{
			print "No se encontro el archivo de agentes";
		}
		@completo;
	}

	# Argrega al ranking de centrales la informacion en el archivo centrales
	sub rankingCentralesArchivo{
		my $archivo = $maedir."/CdC.mae";	
		my @arreglo = @_;
		my @completo = ();
		my @splitA = ();
		if(open (ARCH,$archivo)){
			my @archReg = <ARCH>;
			foreach $a (@arreglo){
				@splitA = split(";",$a);
				@regGrep = grep {$_ =~ /^$splitA[0];.*$/} @archReg;
				$regGrep[0] =~ s/;/\t\t/g;
				push (@completo, "$splitA[1]\t$regGrep[0]");		
			}
		}
		else{
			print "No se encontro el archivo de centrales";
		}
		@completo;
	}

	# Consulta el directorio de archivos de salida y devuelve el numero de subllamada
	sub obtenerSubLlamadaNum{
		my @archDir = ();
		my @aNumSort = ();
		my $ultimoArch = "";
		my @ultimoNum = ();
		my $returnNum = "";
		my @splitArch = ();

		opendir(REPODIR,$repodir) or die print "Falta directorio de salida \"$repodir\"\n";
		@archDir = readdir (REPODIR);
		@aNum = grep {/^subllamada\.[0-9]*$/} @archDir;
		if($#aNum == -1){
			$num = 0;
		}
		else{
			@aNumSort = sort(@aNum);
			$ultimoArch = $aNumSort[$#aNumSort];
			@splitArch = split ('\.',$ultimoArch);
			$num = $splitArch[1] + 1;
		}
		$returnNum = sprintf("%03d",$num);
		$returnNum;
	}


	#
	# Comienzo del programa
	#-

	do{
		$consultaNro++;
		print "\n\n################################################################################\n\t\t\t\tCONSULTA NUMERO: $consultaNro\n################################################################################\n\n";
		%opcionHash = &obtenerOpciones; 
		

		#OPCION CONSULTAR
		if(exists $opcionHash{"-R"}){ 
			print "\n* CONSULTAR *\n\n";
			&abrirDirYMostrar;
			print "\n";	
			@a = ();
			@nombreArchSinDup = &oficinaYaniomes;
			if($ERROR == 0){
				@centrales = ();
				@agentes = ();
				@umbrales = ();
				@tipo = ();
				@numA = ();
				$codigosunidos = "";
				$regex = "^";#Va generando la expresion regular segun los filtros

				print "Desea filtrar centrales? (S/N): ";	
				if(&respSN eq 'S'){
					print "Ingrese codigos de centrales (separados por espacios): ";
					@centrales = &respToken;	
				}

				$codigosunidos = &unirCodigos (@centrales);
				$regex .= $codigosunidos; # "^centrales"

				print "Desea filtrar por agentes? (S/N): ";
				if(&respSN eq 'S'){
					print "Ingrese codigos de agentes (separados por espacios): ";
					@agentes = &respToken;
				}

				$codigosunidos = &unirCodigos (@agentes);
				$regex .= ";".$codigosunidos; # "^centrales;agentes"


				print "Desea filtrar por umbrales? (S/N): ";
				if(&respSN eq 'S'){
					print "Ingrese codigos de umbrales (separados por espacios): ";
					@umbrales = &respToken;
				}

				$codigosunidos = &unirCodigos (@umbrales);
				$regex .= ";".$codigosunidos; # "^centrales;agentes;umbrales"

				print "Desea filtrar por tipo de llamada? (S/N): ";
				if(&respSN eq 'S'){
					print "Ingrese codigos de llamada (separados por espacios): ";
					@tipo = &respToken;
				}

				$codigosunidos = &unirCodigos (@tipo);
				$regex .= ";".$codigosunidos;  # "^centrales;agentes;umbrales;tipo"

				$regex .= ";.*";  #Hora de llamada no se aplica filtro # "^centrales;agentes;umbrales;tipo;.*"

				print "Desea filtrar por tiempo de conversacion? (S/N): ";
				$codigosunidos = ".*";

				$filtroTiempo = 0;
				if(&respSN eq 'S'){
					$filtroTiempo = 1;
					print "Ingrese tiempo minimo: ";
					$Tmin = <STDIN>;
					chomp($Tmin);
					print "Ingrese tiempo maximo: ";
					$Tmax = <STDIN>;
					chomp($Tmax);
				}

				$regex .= ";".$codigosunidos; # "^centrales;agentes;umbrales;tipo;.*;[minimo-maximo]"

				print "Desea filtrar por numero de salida? (S/N): ";
				if(&respSN eq 'S'){
					print "Ingrese los numeros (sin codigos de area)(separados por espacios): ";
					@numA = &respToken;
				}

				$codigosunidos = &unirCodigos (@numA);
				$regex .= ".*;".$codigosunidos; # "^centrales;agentes;umbrales;tipo;.*;[minimo-maximo];.*;numeroA"

				$regex .= ";.*;.*;.*;.*\$";  # "^centrales;agentes;umbrales;tipo;.*;[minimo-maximo];numeroA;.*$;"

				foreach $arch (@nombreArchSinDup){
					open(ARCH, $arch);
					@registrosArch = <ARCH>;
					close (ARCH);
					foreach $regArch (@registrosArch){
						if($regArch =~ $regex){
							push(@a,$regArch);
						}
					}
				}

				@b = ();
				if($filtroTiempo==1){
					foreach $a (@a){
						@arrTiempo = split (';', $a);
						if($arrTiempo[5]>=$Tmin && $arrTiempo[5]<=$Tmax){
							push(@b,$a);
						}
					}
					@a = @b;
				}

				$cant = $#a + 1;
				if(exists $opcionHash{"-W"}){
					$subllamadaNro = &obtenerSubLlamadaNum;
					$subllamada = "subllamada.".$subllamadaNro;
					&grabarEnArch($repodir."/".$subllamada,@a);
					print "Se guardo el resultado en \"$subllamada\" y se obtuvieron $cant registros\n";
					$subllamadaNro++;
				}
				if(!exists $opcionHash{"-W"}){
					print "Se obtuvieron $cant registros en la consulta\n";
					&imprimirArreglo(@a);
				}
			}
		}

		#OOPCION ESTADISTICA

		if(exists $opcionHash{"-S"}){

			print "\n* ESTADISTICAS *\n\n";
			&abrirDirYMostrar;
			$ERROR = 0;
			@nombreArchivos = ();

			print "Ingrese anio mes separados por espacio de la forma (AAAAMM) ('enter': para consultar todos): ";
			@aniomes = &respToken;
			@aniomesValido = &validarAnioMes (@aniomes);
			foreach $am (@aniomesValido){
				push(@archivos, ".*_".$am);
			}

			#Genera una lista con el nombre completo del archivo si el archivo existe en el directorio
			foreach $archDir (@archSort){
				foreach $arch (@archivos){
					if($archDir =~ $arch){
						push(@nombreArchivos, $procdir."/".$archDir);
					}
				}
			}

			#No se encontraron archivos para abrir
			if($#nombreArchivos == -1){
				print "No se han encontrado archivos con ese nombre\n";
				$ERROR = 1;
			}
		
			if($ERROR == 0){
				@nombreArchivosSD = &borrarDuplicados(@nombreArchivos);

				%Hcentrales = ();
				%Hoficinas = ();
				%Hagentes = ();
				%Hdestinos = ();
				%Humbrales = ();
				%HofiTiempo = ();
				%HcentrTiempo = ();
				%agentTiempo = ();


				foreach $arch (@nombreArchivosSD){

					$cant=0;
					$tiempo=0;
					open (ARCH, $arch);
					if($arch =~ m/.*\/(.*)_[0-9]{6}$/){
						$ofi = $1;
					}

					@a = <ARCH>;
					foreach $a (@a){
						@tokens = split(";", $a);
						$Hcentrales {$tokens[0]} += 1;
						$Hagentes {$tokens[1]} += 1;
						$Humbrales {$tokens[2]} += 1;
						$HcentrTiempo {$tokens[0]} += $tokens[5];
						$HagentTiempo {$tokens[1]} += $tokens[5];
						$cant++;
						$tiempo += $tokens[5];
					}
					$Hoficinas{$ofi} += $cant;
					$HofiTiempo{$ofi} += $tiempo;
				}



				do{
					print "Menu de estadisticas:\n1-Mostrar ranking de oficinas por cantidad.\n2-Mostrar ranking de oficinas por tiempo de llamada.\n";
					print "3-Mostrar ranking de centrales por cantidad.\n4-Mostrar ranking de centrales por tiempo de llamada.\n";
					print "5-Mostrar ranking de agentes por cantidad.\n6-Mostrar ranking de agentes por tiempo de llamada.\n";
					print "7-Mostrar ranking de umbrales por cantidad.\n8-Finalizar\n\nIngrese opcion: ";
					$opcion = <STDIN>;
					chomp($opcion);
					@arregloAImprimir = ();	
					if($opcion<1 || $opcion >8){
					print "Ingreso incorrecto, ingrese una de las opciones del menu\n";
					}
					if($opcion == 1){
						print "Ranking de oficinas por cantidad:\n";
						@arreglo = &generarRanking (%Hoficinas);
						@arregloAImprimir = &rankingSinArchivo(@arreglo);
						unshift (@arregloAImprimir, "Cant\tOficina\n----------------\n");
					}
					if($opcion == 2){
						print "Ranking de oficinas por tiempo de llamadas:\n";
						@arreglo = &generarRanking (%HofiTiempo);
						@arregloAImprimir = &rankingSinArchivo(@arreglo);
						unshift (@arregloAImprimir, "Tiempo\tOficina\n----------------\n");
					}
					if($opcion == 3){
						print "Ranking de centrales por cantidad:\n";
						@arreglo = &generarRanking(%Hcentrales);
						@arregloAImprimir = &rankingCentralesArchivo(@arreglo);
						unshift (@arregloAImprimir, "Cant\tCod central\tNombre central\n------------------------------------\n");
					}
					if($opcion == 4){
						print "Ranking de centrales por tiempo de llamada:\n";
						@arreglo = &generarRanking(%HcentrTiempo);	
						@arregloAImprimir = &rankingCentralesArchivo(@arreglo);
						unshift (@arregloAImprimir, "Tiempo\tCod central\tNombre central\n-------------------------------------\n");
					}
					if($opcion == 5){
						print "Ranking de agentes por cantidad:\n";
						@arreglo = &generarRanking(%Hagentes);
						@arregloAImprimir = &rankingAgentesArchivo(@arreglo);
						unshift (@arregloAImprimir, "Cant\tAgente\t\tOficina\tEmail\n---------------------------------------------------\n");
					}
					if($opcion == 6){
						print "Ranking de agentes por tiempo de llamadas:\n";
						@arreglo = &generarRanking(%HagentTiempo);
						@arregloAImprimir = &rankingAgentesArchivo(@arreglo);
						unshift (@arregloAImprimir, "Tiempo\tAgente\t\tOficina\tEmail\n-------------------------------------------------------\n");
					}
					if($opcion == 7){
						print "Ranking de umbrales por cantidad:\n";
						@arreglo = &generarRankingUmbrales (%Humbrales);
						@arregloAImprimir = &rankingSinArchivo(@arreglo);
						unshift (@arregloAImprimir, "Cant\tUmbral\n----------------\n");
					}
					if($opcion == 8){
						print "Gracias, vuelva prontos\n";
					}
					if(exists $opcionHash{"-W"}&& $opcion < 8 && $opcion > 0){
						$nombreArch = &validarNombreArch;
						&grabarEnArch($repodir."/".$nombreArch,@arregloAImprimir);
						print "Se almaceno el resultado en el archivo \"$nombreArch\"\n";
					}
					if(!exists $opcionHash{"-W"}&& $opcion < 8 && $opcion > 0){
						&imprimirArreglo(@arregloAImprimir);
					}
				}until($opcion == 8);
			}		
		}

		#OPCION AYUDA
		if(exists $opcionHash{"-H"}){
 print "................................................................................
............................:AFRALIST MENU DE AYUDA:............................
................................................................................

El comando AFRALIST lo ayudara a usted a generar consultas y estadisticas 
rapidas sobre los archivos de llamadas sospechosas.

Menu inicial:
	(-r) Consultar uno, alguno o todos los archivos de llamadas sospechosas.
	(-s) Mostrar estadisticas sobre uno, alguno o todos los archivos de 
	llamadas sospechosas.
	(-w) Alamacenara la consulta o estadistica en un archivo segun 
	corresponda.
	(-h) Muestra este menu de ayuda.
	(-e) Finalizar consultas y salir.

Los comandos en profundidad:

CONSULTAR (-r):
	Con la opcion -r usted consultara los archivos de llamadas sospechosas,
	aplicando los filtros que usted desee.
	Instrucciones:

	1) Ingresar oficianas a filtrar, se le solicitara el ingreso 
	de las oficinas que desea consultar. Si desea consultar 
	todas las oficinas debe ingresar (-a). Si usted ingreso 
	algunas oficinas y desea finalizar el ingreso ingrese \"0\".

	2) Ingresar los anio mes que desea filtrar, es importante
	que el ingreso sea en el formato AAAAMM separados por espacios.
	Se consultaran todos los anio mes que ingrese de la oficina
	seleccionada anteriormente. Si desea que consultar todos los
	anio mes de una oficina simplemente ingrese la tecla enter.

	3) Generar el filtro: en este paso usted debe ingresar los
	filtros que desea aplicar a los archivos que ya fueron
	seleccionados.

	4) Se realizara la consulta. Recuerde que si usted selecciono
	la opcion (-w) el sistema almacenara el resultado en un 
	archivo \"subllamadas.XXX\", caso contrario se mostrara el 
	resultado por la pantalla de la consola.

ESTADISTICAS (-s):
	Con la opcion -s usted realizara estadisticas sobre los archivos de 
	llamadas sospechosas y realizar consultas especificas a criterio 
	del usuario.

	Intrucciones:

	1) Ingresar oficianas a filtrar, se le solicitara el ingreso
	de las oficinas que desea consultar. Si desea consultar todas
	las oficinas debe ingresar (-a). Si usted ingreso algunas
	oficinas y desea finalizar el ingreso ingrese \"0\".

	2) Ingresar los anio mes que desea filtrar, es importante que
	el ingreso sea en el formato AAAAMM separados por espacios. 
	Se consultaran todos los anio mes que ingrese de la oficina 
	seleccionada anteriormente. Si desea que consultar todos los
	anio mes de una oficina simplemente ingrese la tecla enter.

	3) Se realizaran las estadisticas pertinentes y el sistema
	dispondra de un menu para que usted seleccione la estadistica
	que desea ver o almacenar.

	4) Recuerde que si usted ingreso la opcion (-w) la estadistica
	generada por consulta sera almacenada en un archivo el cual 
	usted proporcionara el nombre.

GUARDAR (-w):
	Esta opcion debe ser utilizada en conjunto con (-r) o (-s) y almacenara
	el resultado en un archivo, segun corresponda, si es utilizada sin los
	otros comandos, sera ignarada la opcion y debera ingresar otra opcion.

	AYUDA (-h):
		Muestra por pantalla este menu de ayuda.;

	SALIR (-e):
		Salir del programa.



";
	}
	if(!exists $opcionHash{"-H"} && !exists $opcionHash{"-S"} && !exists $opcionHash{"-R"} && !exists $opcionHash{"-W"} && !exists $opcionHash{"-E"}){
		print "\nIngreso incorrecto\n";
	}

	}until(exists $opcionHash{"-E"});

	print "\n\nConsultas finalizadas\n\n";

