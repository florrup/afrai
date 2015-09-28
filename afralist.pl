#! /usr/bin/perl

use Getopt::Long;

GetOptions('r' => \$consultar, 'w' => \$grabar,'s' => \$estadistica,'h' => \$ayuda,);
$dir = 'archivos_locos'; #direccion donde esten los archivos a consultar

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
split(' ',$codString);
}

# Lee un string y NO lo parsea
sub respSimple {
$codString = <STDIN>;
chomp($codString);
$codString;
}

sub unirCodigos{
@tokens = @_;
$codUni = ".*";
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


$bool = (($_[0] !~ /^[[:alnum:]]{3}$/)&&($_[0] ne "0")&&($_[0] ne "-a"));

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




sub borrarDuplicados {
my %unique = ();
foreach my $item (@_)
{
    $unique{$item} ++;
}
@myuniquearray = keys %unique;

}
	 
#Se selecciono la opcion de consultar	
if($consultar){ 

	#Abre el directorio, y almacena en @archSort los archivos validos
	if(opendir(DIR,"$dir")){ 
		@aD=readdir(DIR);
		close(DIR);
		foreach $ad (@aD){
			next unless ($ad =~ /^[0-9]{3}_[0-9]{4}[0-1][0-9]$/);
			push (@aDir, $ad);
			@archSort = sort(@aDir);
		}
	}
	
	#Muestra los archivos disponibles y validos
	print "Archivos disponibles en \"$dir\"\n";
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
	
	#Pregunta las oficinas y los anio mes al usuario validando ambos ingresos
	do{
		print "\nIngrese oficina (0 para terminar): ";
		$oficina = &respSimple;
		if(&validarOficina ($oficina)){
			print "Oficina invalida\n";
			$oficina = "-1";
		}
		if($oficina eq "-a"){
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
				push(@nombreArchivos, $dir."/".$archDir);
			}
		}
	}
	@nombreArchSinDup = &borrarDuplicados(@nombreArchivos);
	print "@nombreArchSinDup\n";

	#No se encontraron archivos para abrir
	if($#nombreArchSinDup == -1){
		print "No se han encontrado archivos con ese nombre\n";
		die;
	}


	#Comienza a preguntar sobre los filtros al usuario
	$regex = "^";#Va generando la expresion regular segun los filtros
	
	print "Desea filtrar centrales? (S/N): ";	
	if(&respSN eq 'S'){
		print "Ingrese codigos de centrales (separados por espacios): ";
		@centrales = &respToken;	
	}

	$codigosunidos = &unirCodigos (@centrales);
	$regex .= $codigosunidos;

	print "Desea filtrar por agentes? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese codigos de agentes (separados por espacios): ";
		@agentes = &respToken;
	}

	$codigosunidos = &unirCodigos (@agentes);
	$regex .= ";".$codigosunidos;


	print "Desea filtrar por umbrales? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese codigos de umbrales (separados por espacios): ";
		@umbrales = &respToken;
	}

	$codigosunidos = &unirCodigos (@umbrales);
	$regex .= ";".$codigosunidos;

	print "Desea filtrar por tipo de llamada? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese codigos de llamada (separados por espacios): ";
		@tipo = &respToken;
	}

	$codigosunidos = &unirCodigos (@tipo);
	$regex .= ";".$codigosunidos;

	$regex .= ";.*";  #Hora de llamada no se aplica filtro

	print "Desea filtrar por tiempo de conversacion? (S/N): ";
	$codigosunidos = ".*";

	if(&respSN eq 'S'){

		print "Ingrese tiempo minimo: ";
		$Tmin = <STDIN>;
		chomp($Tmin);
		print "Ingrese tiempo maximo: ";
		$Tmax = <STDIN>;
		chomp($Tmax);
		$codigosunidos = "[".$Tmin."-".$Tmax."]";
	}
	$regex .= ";".$codigosunidos;

	print "Desea filtrar por numero A? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese los numeros (separados por espacios): ";
		@numA = &respToken;
	}

	$codigosunidos = &unirCodigos (@numA);
	$regex .= ";".$codigosunidos;

	print "Desea filtrar por numero B? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese los numeros (separados por espacios): ";
		@numB = &respToken;
	}

	$codigosunidos = &unirCodigos (@numB);
	$regex .= ";".$codigosunidos."\$";
	
	print $regex;
}

if($grabar){
	print "grabar\n";
}

if($estadistica){
	print "estadiciala\n";
}

if($ayuda){
	print "ayuda \n";
}
