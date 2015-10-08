#! /usr/bin/perl

$procdir = "PROCDIR"; #direccion donde esten los archivos a consultar
$maedir = "MAEDIR";
$repodir = "REPODIR";

# Lee el ingreso validando que sea S o N
sub respSN {
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
$codString = <STDIN>;

split(' ', uc($codString));
}

# Lee un string y NO lo parsea
sub respSimple {
my $codString = <STDIN>;
chomp($codString);
$codString;
}

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

sub validarOficina{
	$bool = (($_[0] !~ /^[[:alnum:]]{3}$/)&&($_[0] ne "0")&&($_[0] ne "-a")&&($_[0] ne "-A"));
}

sub validarAnioMes{

foreach $am (@_){
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
	do{
		print "Ingrese oficina (0 para terminar): ";
		$oficina = &respSimple;
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
			@aniomes = &respToken;
			@aniomesValido = &validarAnioMes (@aniomes);
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

	opendir(DIR,$procdir) or die print "No se encontro el directorio\n";
	@aD=readdir(DIR);
	close(DIR);
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


sub obtenerOpciones{
	my %opcionHash = ();
	my @opciones = "";
	print "Seleccione las opciones: ";
	@opciones = &respToken;
	foreach $opcion (@opciones){
		$opcionHash{$opcion} = 0;
	}
%opcionHash;	
}

#
# Comienzo del programa
#

do{

	%opcionHash = &obtenerOpciones; 
	#Se selecciono la opcion de consultar	
if(exists $opcionHash{"-R"}){ 

	&abrirDirYMostrar;
	@nombreArchSinDup = &oficinaYaniomes;

	#Comienza a preguntar sobre los filtros al usuario
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
	
	print $regex;

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
	print @a;
	
}

if(exists $opcionHash{"-W"}){
	$subllamada = "subllamada.000";
	open ($archSub, '>', $subllamada);
	print $archSub @a;
	
}

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
		if($opcion<1 || $opcion >9){
			print "Ingreso incorrecto, ingrese una de las opciones del menu\n";
		}
		if($opcion == 1){
			print "Ranking de oficinas por cantidad:\n";
			@arregloAImprimir = &generarRanking (%Hoficinas);
		}
		if($opcion == 2){
			print "Ranking de oficinas por tiempo de llamadas:\n";
			&generarRanking (%HofiTiempo);
		}
		if($opcion == 3){
			print "Ranking de centrales por cantidad:\n";
			@arreglo = &generarRanking(%Hcentrales);
			&rankingCentralesArchivo(@arreglo);
		}
		if($opcion == 4){
			print "Ranking de centrales por tiempo de llamada:\n";
			@arreglo = &generarRanking(%HcentrTiempo);	
			&rankingCentralesArchivo(@arreglo);
		}
		if($opcion == 5){
			print "Ranking de agentes por cantidad:\n";
			@arreglo = &generarRanking(%Hagentes);
			&rankingAgentesArchivo(@arreglo);
		}
		if($opcion == 6){
			print "Ranking de agentes por tiempo de llamadas:\n";
			@arreglo = &generarRanking(%HagentTiempo);
			&rankingAgentesArchivo(@arreglo);
		}
		if($opcion == 7){
			print "Ranking de umbrales por cantidad:\n";
			&genararRankingUmbrales(%Humbrales);
		}
		if($opcion == 8){
			print "Ranking de destinos por cantidad:FALTA\n";
		}
		
		if($opcion == 9){
			print "Gracias, vuelva prontos\n";
		}
	}until($opcion == 9);
	
}

if(exists $opcionHash{"-H"}){
	print "ayuda \n";
}

print "Finalizo su consulta\n";
}until(exists $opcionHash{"-E"});

sub validarNombreArch{
	my $nombre = <STDIN>;
	my $val = 0;
}

sub imprimirArreglo{
	foreach $a (@_){
		print $a;
	}
}

sub generarRanking{
	my %hash = @_;
	my @arreglo;
	
	foreach $h (sort{$hash{$b} <=> $hash{$a} } keys %hash){
		push(@arreglo,$h);
	}
@arreglo;
}

sub genararRankingUmbrales{
	my %hash = @_;
	my @arreglo;
	foreach $h (sort{$hash{$b} <=> $hash{$a} } keys %hash){
		if($hash{$h}>1){		
			push(@arreglo,"$h\n");
		}
	}
@arreglo;
}


sub rankingAgentesArchivo{
	my $archivo = "agentes.csv";	
	my @arreglo = @_;
	my @completo;
	if(open (ARCH,$archivo)){
		my @archReg = <ARCH>;
		foreach $a (@arreglo){
			@regGrep = grep {$_ =~ /^.*;.*;$a;.*;.*$/} @archReg;
			$regGrep[0] =~ s/;/\t/g;
			if($regGrep[0] =~ m/.*\t(.*\t.*\t.*)$/){
				push (@completo, "$1\n");
			}	
		}
	}
	else{
		print "No se encontro el archivo de agentes";
	}

@completo;
}

sub rankingCentralesArchivo{
	my $archivo = "centrales.csv";	
	my @arreglo = @_;
	my @completo;
	if(open (ARCH,$archivo)){
		my @archReg = <ARCH>;
		foreach $a (@arreglo){
			@regGrep = grep {$_ =~ /^$a;.*$/} @archReg;
			$regGrep[0] =~ s/;/\t/g;
			push (@completo, "$regGrep[0]");		
		}
	}
	else{
		print "No se encontro el archivo de centrales";
	}
	
}

