#! /usr/bin/perl

use Getopt::Long;
use List::MoreUtils;

GetOptions('r' => \$consultar, 'w' => \$grabar,'s' => \$estadistica,'h' => \$ayuda,);
$dir = ' '; #direccion donde esten los archivos a consultar

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

$bool = (($_[0] !~ /^[[:alnum:]]{3}$/)&&($_[0] ne "0"));

}

#sub validarAnioMes{
#$bool = 1;

#foreach $am (@_){
#	if($am !~ /[0-9]{4}[0-1][0-9]/){
#		print "El anio mes: $am es invalido\n";
#		$bool = 0;
#	}
#	if($bool == 0){
#		print "Desea reingresar los valores anio mes? (S/N): ";
#		if(&respSN eq 'S'){
#			$bool = 0;
#		}
#		else{
#			$bool = 1;
#		}
#	}
#}
#$bool;
#
#}

sub borrarDuplicados {
my %unique = ();
foreach my $item (@_)
{
    $unique{$item} ++;
}
@myuniquearray = keys %unique;

}
	 
	
if($consultar){
	
	do{
		print "Ingrese oficina (0 para terminar): ";
		$oficina = &respSimple;
		if(&validarOficina ($oficina)){
			print "Oficina invalida\n";
			$oficina = "-1";
		}
		if($oficina ne "0" && $oficina ne "-1"){
			print "Ingrese anio mes separados por espacio de la forma (AAAAMM): ";
			@aniomes = &respToken;
			foreach $am (@aniomes){
				push(@archivos, $oficina."_".$am);
			}
		}
	}until($oficina eq "0");
	
	

	if(opendir(DIR,"$dir")){
		@archivosDir=readdir(DIR);
		close(DIR);
	}

	foreach $archDir (@archivosDir){
		foreach $arch (@archivos){
			if($arch eq $archDir){
				push(@nombreArchivos, $dir."/".$arch);
			}
		}
	}

	@nombreArchSinDup = &borrarDuplicados(@nombreArchivos);

	if($#nombreArchSinDup == -1){
		print "No se han encontrado archivos esa descripcion\n";
		die;
	}

	$regex = "^";
	
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
		foreach $cod (@tipo){
			print "$cod\n";
		}
	}

	$codigosunidos = &unirCodigos (@tipo);
	$regex .= ";".$codigosunidos;

	$regex .= ";.*"  #Hora de llamada no se aplica filtro

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
