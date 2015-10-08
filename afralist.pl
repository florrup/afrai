#! /usr/bin/perl

$procdir = "PROCDIR"; #direccion donde esten los archivos a consultar
$maedir = "MAEDIR";
$repodir = "REPODIR";

$subllamadaNro = 0;

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
split(' ', uc($codString));
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
foreach my $am (@anioMes){
	if($am !~ /^[0-9]{4}[0-1][0-9]$/){
		print "El anio mes: $am es invalido y no sera tenido en cuenta\n";
	}
	else{
		push(@aniomesValido, $am);
	}
}

if($#aniomesValido == -1){
	$aniomesValido[0] = "[0-9]{4}[0-1][0-9]\$";
	print "Se consultaran todos los anio mes del directorio\n";
}

@aniomesValido;
}

#Pregunta las oficinas y los anio mes al usuario validando ambos ingresos
sub oficinaYaniomes{
	my @archivos = ();
	my @nombreArchivos = ();
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
			print "Ingrese anio mes separados por espacio de la forma (AAAAMM): ";
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
		die;
	}
	print @nombreArchivos;

	&borrarDuplicados(@nombreArchivos);
}


sub borrarDuplicados {
my %hash = ();
foreach my $elem (@_)
{
    $hash{$elem} ++;
}
@sinDuplicado = keys %hash;

}

#Abre el directorio, y almacena en @archSort los archivos validos
sub abrirDirYMostrar {

	opendir(DIR,$procdir) or die print "No se encontro el directorio\n";
	@aD=readdir(DIR);
	close(DIR);
	@aDir=();
	foreach $ad (@aD){
		next unless ($ad =~ /^[0-9]{3}_[0-9]{4}[0-1][0-9]$/);
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
	my @opciones = "";
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
	my @arreglo;
	foreach $h (sort{$hash{$b} <=> $hash{$a} } keys %hash){
		if($hash{$h}>1){		
			push(@arreglo,"$h;$hash{$h}");
		}
	}
@arreglo;
}

sub rankingSinArchivo{
	my @completo = ();
	my @arreglo = @_;
	my @splitA = ();
	foreach $a (@arreglo){
		@splitA = split (";",$a);
		push (@completo, "$splitA[1] : $splitA[0]\n");	
	}
	@completo;
}

# Agrega al ranking de agentes la informacion del archivo
sub rankingAgentesArchivo{
	my $archivo = $maedir."/agentes.csv";	
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
				push (@completo, "$splitA[1] : $1\n");
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
	my $archivo = $maedir."/centrales.csv";	
	my @arreglo = @_;
	my @completo = ();
	my @splitA = ();
	if(open (ARCH,$archivo)){
		my @archReg = <ARCH>;
		foreach $a (@arreglo){
			@splitA = split(";",$a);
			@regGrep = grep {$_ =~ /^$splitA[0];.*$/} @archReg;
			$regGrep[0] =~ s/;/\t/g;
			push (@completo, "$splitA[1] : $regGrep[0]");		
		}
	}
	else{
		print "No se encontro el archivo de centrales";
	}
@completo;
}




#
# Comienzo del programa
#

do{

	%opcionHash = &obtenerOpciones; 

#OPCION CONSULTAR

if(exists $opcionHash{"-R"}){ 

	print "\n";
	&abrirDirYMostrar;
	print "\n";	
	@a = ();
	@nombreArchSinDup = &oficinaYaniomes;

	#Comienza a preguntar sobre los filtros al usuario
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

	if(&respSN eq 'S'){

		print "Ingrese tiempo minimo: ";
		$Tmin = <STDIN>;
		chomp($Tmin);
		print "Ingrese tiempo maximo: ";
		$Tmax = <STDIN>;
		chomp($Tmax);
		$codigosunidos = "[".$Tmin.".".$Tmax."]";
	}
	$regex .= ";".$codigosunidos; # "^centrales;agentes;umbrales;tipo;.*;[minimo-maximo]"

	print "Desea filtrar por numero A? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese los numeros (separados por espacios): ";
		@numA = &respToken;
	}

	$codigosunidos = &unirCodigos (@numA);
	$regex .= ";".$codigosunidos; # "^centrales;agentes;umbrales;tipo;.*;[minimo-maximo];numeroA"

	$regex .= ";.*\$";  # "^centrales;agentes;umbrales;tipo;.*;[minimo-maximo];numeroA;.*$;"
	

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
	if(exists $opcionHash{"-W"}){
		$subllamada = "subllamada.".$subllamadaNro;
		&grabarEnArch($repodir."/".$subllamada,@a);
		$cant = $#a++;
		print "Se guardo el resultado en \"$subllamada\" y se obtuvieron $cant registros\n";
		$subllamadaNro++;
	}
	if(!exists $opcionHash{"-W"}){
		print "Se obtuvieron $#a registros en la consulta\n";
		&imprimirArreglo(@a);
	} 
	
}

#OOPCION ESTADISTICA

if(exists $opcionHash{"-S"}){

	&abrirDirYMostrar;

	print "Ingrese anio mes separados por espacio de la forma (AAAAMM): ";
	@aniomes = &respToken;
	@aniomesValido = &validarAnioMes (@aniomes);
	foreach $am (@aniomesValido){
		push(@archivos, "[0-9]{3}_".$am);
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
		die;
	}
	
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
		if($arch =~ m/.*([0-9]{3})_[0-9]{6}$/){
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
	print "7-Mostrar ranking de umbrales por cantidad.\n8-Mostrar ranking de destinos de llamadas\n9-Finalizar\n\nIngrese opcion: ";
		$opcion = <STDIN>;
		chomp($opcion);
		@arregloAImprimir = 0;
		if($opcion<1 || $opcion >9){
			print "Ingreso incorrecto, ingrese una de las opciones del menu\n";
		}
		if($opcion == 1){
			print "Ranking de oficinas por cantidad:\n";
			@arreglo = &generarRanking (%Hoficinas);
			@arregloAImprimir = &rankingSinArchivo(@arreglo);
		}
		if($opcion == 2){
			print "Ranking de oficinas por tiempo de llamadas:\n";
			@arreglo = &generarRanking (%HofiTiempo);
			@arregloAImprimir = &rankingSinArchivo(@arreglo);
		}
		if($opcion == 3){
			print "Ranking de centrales por cantidad:\n";
			@arreglo = &generarRanking(%Hcentrales);
			@arregloAImprimir = &rankingCentralesArchivo(@arreglo);
		}
		if($opcion == 4){
			print "Ranking de centrales por tiempo de llamada:\n";
			@arreglo = &generarRanking(%HcentrTiempo);	
			@arregloAImprimir = &rankingCentralesArchivo(@arreglo);
		}
		if($opcion == 5){
			print "Ranking de agentes por cantidad:\n";
			@arreglo = &generarRanking(%Hagentes);
			@arregloAImprimir = &rankingAgentesArchivo(@arreglo);
		}
		if($opcion == 6){
			print "Ranking de agentes por tiempo de llamadas:\n";
			@arreglo = &generarRanking(%HagentTiempo);
			@arregloAImprimir = &rankingAgentesArchivo(@arreglo);
		}
		if($opcion == 7){
			print "Ranking de umbrales por cantidad:\n";
			@arreglo = &generarRanking (%Humbrales);
			@arregloAImprimir = &rankingSinArchivo(@arreglo);
		}
		if($opcion == 8){
			print "Ranking de destinos por cantidad:FALTA\n";
		}
		
		if($opcion == 9){
			print "Gracias, vuelva prontos\n";
		}
		if(exists $opcionHash{"-W"}&& $opcion != 9){
			$nombreArch = &validarNombreArch;
			&grabarEnArch($repodir."/".$nombreArch,@arregloAImprimir);
			print "Se almaceno el resultado en el archivo \"$nombreArch\"\n";
		}
		if(!exists $opcionHash{"-W"}&& $opcion != 9){
			&imprimirArreglo(@arregloAImprimir);
		}
	}until($opcion == 9);
		
}

#OPCION AYUDA

if(exists $opcionHash{"-H"}){
	open(HELP, "AFRALIST_help.txt") or die print "NO SE ENCONTRO EL ARCHIVO DE AYUDA\n";
	@help = <HELP>;
	close (HELP);
	&imprimirArreglo(@help);
}

print "Finalizo su consulta\n";

}until(exists $opcionHash{"-E"});



