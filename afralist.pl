#! /usr/bin/perl

use Getopt::Long;
GetOptions('r' => \$consultar, 'w' => \$grabar,'s' => \$estadistica,'h' => \$ayuda,);
$dir = 'PROCDIR/'; #direccion donde esten los archivos a consultar

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

# Pendiente
sub filtrar {
my ($line) = $_[0];
print $line;
}	 
	
if($consultar){
	
	do{
		print "Ingrese oficina (0 para terminar): ";
		$oficina = &respSimple;
		if($oficina ne "0"){
			print "Ingrese anio mes separados por espacio: ";
			@aniomes = &respToken;
			foreach $aniomes (@aniomes){
				push(@archivos,$oficina."_".$aniomes);
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

	if($#nombreArchivos == -1){
		print "No se han encontrado archivos esa descripcion\n";
		die;
	}

	print "Desea filtrar centrales? (S/N): ";	
	if(&respSN eq 'S'){
		print "Ingrese codigos de centrales (separados por espacios): ";
		@centrales = &respToken;
	}

	print "Desea filtrar por agentes? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese codigos de agentes (separados por espacios): ";
		@agentes = &respToken;
		foreach $cod (@agentes){
			print "$cod\n";
		}
	}

	print "Desea filtrar por umbrales? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese codigos de umbrales (separados por espacios): ";
		@umbrales = &respToken;
		foreach $cod (@umbrales){
		print "$cod\n";
		}
	}

	print "Desea filtrar por tipo de llamada? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese codigos de llamada (separados por espacios): ";
		@tipo = &respToken;
		foreach $cod (@tipo){
			print "$cod\n";
		}
	}

	print "Desea filtrar por tiempo de conversacion? (S/N): ";
	if(&respSN eq 'S'){

		print "Ingrese tiempo minimo: ";
		$Tmin = <STDIN>;
		chomp($Tmin);
		print "Ingrese tiempo maximo: ";
		$Tmax = <STDIN>;
		chomp($Tmax);
	}

	print "Desea filtrar por numero A? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese los numeros (separados por espacios): ";
		@numA = &respToken;
		foreach $cod (@numA){
			print "$cod\n";
		}
	}

	print "Desea filtrar por numero B? (S/N): ";
	if(&respSN eq 'S'){
		print "Ingrese los numeros (separados por espacios): ";
		@numB = &respToken;
		foreach $cod (@numB){
			print "$cod\n";
		}
	}

	

}

if($grabar){
	print "grabar\n";
}

if($estadistica){
	print "estadiciala\n";
}

if($ayuda){
	print "ayuda gato\n";
}
