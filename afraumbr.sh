#! /bin/bash
# ******************************************************************
# Verificacion de umbrales
#
# ******************************************************************


#Observaciones importantes
# -Para que este script funciona hice una prueba seteando las variables de ambientes desde la carpeta ACEPDIR en la cual puse como pruebas,
#  los archivos con fechas en el nombre
# -Por alguna razon los archivos con fechas en el nombre tienen un campo que esta vacio en absolutamente todas las filas
# 
#

GRALOG="gralog.sh"
MOVER="mover.sh"
AGENTES=$MAEDIR/"agentes.mae"
CDP=$MAEDIR/"CdP.mae"
CDA=$MAEDIR/"CdA.mae"
UMBRALES=$MAEDIR/"umbral.tab"

tipoLlamada=""

function msjLog() {
  local MOUT=$1
  local TIPO=$2
  echo "${MOUT}"
  $GRALOG "$0" "$MOUT" "$TIPO"
}


# 1. Procesar todos los archivos
function inicio() {
  MSJ="Inicio de AFRAUMBR"
  msjLog "${MSJ}" "INFO"
  cantidadRechazados=0;

  # Calculo la cantidad de archivos en ACEPDIR
  cantArchivos=$(ls $ACEPDIR | wc -l)
    
  # Parseo por fechas y lista ordenando cronologicamente
  # Desde el antiguo al mas reciente 
  inputFiles=$(ls $ACEPDIR | grep '[0-9]*[0-9]' | sort -k1.4)

  for fileName in $inputFiles;
  do
	echo "Procesar Archivo: $fileName 1"
    procesarArchivo $fileName
    if [ "$?" = 0 ]; then	# si no fue procesado, sigo
      validarPrimerRegistro $fileName
      if [ "$?" = 0 ]; then
        # 3. Si se puede procesar el archivo
        msjLog "Archivo a procesar: $fileName" "INFO"
	# Empiezo a procesar cada registro
	procesarRegistro $fileName
	finDeArchivo $fileName
      fi
    fi
  done  

  MSJ="Cantidad de archivos procesados: $cantArchivos"
  msjLog "${MSJ}" "INFO"
  MSJ="Cantidad de archivos rechazados: $cantidadRechazados"
  msjLog "${MSJ}" "INFO"


  MSJ="Fin de AFRAUMBR"
  msjLog "${MSJ}" "INFO"
}

##########################################################################################

# 2. Procesar un Archivo

# 2.1. Verificar que no sea un archivo duplicado
# Devuelve 1 si ya fue procesado, 0 en caso contrario
function procesarArchivo() {
  local archivo=$1
  # Verifico si el archivo ya fue procesado
  if [ -s $PROCDIR/proc/$archivo ]; then
    MSJ="Se rechaza el archivo por estar DUPLICADO"
    msjLog "$MSJ" "ERR"
    $MOVER "$ACEPDIR/$archivo" "$RECHDIR" "${0}"
    cantidadRechazados=$((cantidadRechazados+1))
    return 1
  fi
  return 0
}

##########################################################################################

# 2.2 Verificar la cantidad de campos del primer registro
# Devuelve 1 si no es valido, 0 en caso contrario
function validarPrimerRegistro() {
  local ARCH=$1

  # Leo la primera linea y calculo la cantidad de campos
  read -r primeraLinea < $ACEPDIR/$ARCH
  local cantidadDeCampos=$(echo "$primeraLinea" | sed 's/[^;]//g' | wc -c)

  # Los archivos en ACEPDIR deben tener ocho campos
  local cantidad=8

  # Compruebo que la cantidad de campos del primer registro coincida con el formato establecido, sino lo muevo
  if (($cantidadDeCampos != $cantidad))
  then
      MSJ="Se rechaza el archivo porque su estructura no se corresponde con el formato esperado"
      #TODO Los archivos rechazados que van a RECHDIR deben tener el formato .rech
      msjLog "$MSJ" "ERR"
      $MOVER "$ACEPDIR/$ARCH" "$RECHDIR" "${0}"
      cantidadRechazados=$((cantidadRechazados+1))
      return 1
  fi
  return 0
}

##########################################################################################

# 4. Procesar un registro
fileNameAProcesar=""
procesarRegistro() {
  local ARCH=$1
  fileNameAProcesar=$1

  # id; fecha y hora; tiempo; origen area; origen numero; destino pais; destino area; destino numero
  local IFS=";"
  cantRegistrosLeidos=0
  cantidadRegistrosRechazados=0
  cantidadSinUmbral=0
  cantidadConUmbral=0
  cantLlamadasSospechosas=0
  cantLlamadasNoSospechosas=0
  while read idAgente inicioLlamada tiempoConversacion origenArea origenNumero destinoPais destinoArea destinoNumero 
  do
    # Incremento en uno la cantidad de registros leidos
    cantRegistrosLeidos=$((cantRegistrosLeidos+1))
    motivo="";
    #TODO   validarCamposRegistro "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8"
    validarCamposRegistro
    if [ "$?" = 1 ]; then
      echo "SE RECHAZA EL REGISTRO - IR AL PUNTO SIGUIENTE"
      rechazarRegistro
    else
      # id; fecha y hora; tiempo; origen area; origen numero; destino pais; destino area; destino numero
      determinarTipoDeLlamada
      if [ "$?" = 1 ]; then
        echo "SE RECHAZA EL REGISTRO"
	motivo="No se ha podido determinar el tipo de llamada"
        rechazarRegistro
      else
        #TODO verificarLlamadaSospechosa  "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8"
	verificarLlamadaSospechosa
      fi
    fi
  done < $ACEPDIR/$ARCH
}

# 4.1 Validar los campos del registro

# Valida el id de agente 
# Devuelve 1 si no fue encontrado, 0 en caso contrario
idAgente() {
  local ARCH=$1 # agentes.csv
  local ID=$2
  if grep -q ";${ID};" $ARCH;
  then
    #echo "Encontrado"
    #echo "$(grep ";${ID};" $ARCH)"
    return 0 # fue encontrado
  else
    #echo "No encontrado en AGENTES.CSV"mart
    return 1 # no fue encontrado
  fi
}

# Valida el codigo de area 
# Devuelve 1 si no fue encontrado, 0 en caso contrario
codigoAreaA() {
  local ARCH=$1 #CdA.csv
  local AREA=$2
  if grep -q $";${AREA}" $ARCH;
  then
    #echo "Encontrado en CDA"
    #echo "$(grep $";${AREA}" $ARCH)"
    return 0 # fue encontrado
  else
    echo "No encontrado en CDA"
    return 1 # no fue encontrado
  fi
}

# Valida el numero de linea
# Es 0 si cumple, 1 sino
numeroLineaA() {
  AREA=$1
  NUM=$2
  DIG=0
  if [ "${#AREA}" = "2" ]; then  # muestra la cantidad de digitos del area
    DIG=8
  elif [ "${#AREA}" = "3" ]; then
    DIG=7
  elif [ "${#AREA}" = "4" ]; then
    DIG=6
  fi   
  if [ "${#NUM}" = "$DIG" ]; then
    #echo "NUM contiene $DIG"
    return 0
  else
    #echo "NUM contiene distinto num que DIG"
    return 1
  fi
}

# Valida el codigo de pais, codigo de area y numero de linea
# Devuelve 1 si no fue encontrado, 0 en caso contrario 
checkearNumeroB() {
  CDP=$1
  CODPAIS=$2
  CDA=$3
  CODAREA=$4
  NUM=$5
  DDI="false"
  if [ "$CODPAIS" = "" ]; then  # no es DDI si CODPAIS esta vacio
    DDI="false"
  else
    DDI="true"  # es DDI cuando contiene el codigo
    if ! grep -q "^${CODPAIS};" $CDP;
    then
      RECHAZO="true"
      msj="el codigoPaisB no coincide"
      return 1 # no fue encontrado
    fi
  fi

  codigoArea "${CDA}" "${CODAREA}" "${DDI}"
  rtaArea=$?
  if [ "${rtaArea}" = 1 ]; then
    RECHAZO="true"
    msj="el codigoAreaB no coincide"
    return 1
  fi

  numeroLineaB "${NUM}" "${DDI}" "${CODAREA}"
  rtaNum=$?
  if [ "${rtaNum}" = 1 ]; then
    RECHAZO="true"
    msj="el numeroLineaB no coincide"
    return 1
  else
    return 0
  fi
}

# Valida el codigo de area
# Devuelve 1 si no viene, 0 en caso contrario
codigoArea() {
  CDA=$1
  CODAREA=$2
  DDI=$3


  # CODAREA esta
  # Verifico DDI
  if [ "$DDI" = "false" ]; then
    #echo "DDI es false"
    if grep -q $";${CODAREA}" $CDA;
    then
      #echo "CODAREA Encontrado"
      #echo "$(grep $";${CODAREA}" $CDA)"
      return 0  # fue encontrado
    else
      #echo "CODAREA No encontrado"
      return 1 # no fue encontrado
    fi
  fi
  #echo -e "DDI es true\n\n"
  return 0
}

# Verifica numero de linea B
# Devuelve 1 si no cumple
numeroLineaB() {
  NUM=$1
  DDI=$2
  CODAREA=$3
  re='^[0-9]+$'
  if ! [[ $NUM =~ $re ]]; then
    #echo "No es un numero"
    return 1
  fi

  SUMA=0
  if [ "$DDI" = "false" ]; then
    SUMA=$((${#CODAREA} + ${#NUM}))
  else
    #echo "DDI es true"
    return 0
  fi

  if [ "$SUMA" -ne 10 ]; then
    #echo "La suma no es 10"
    return 1
  fi
  #echo "La suma es 10, todo OK"
  return 0
}

# Valida el tiempo de conversacion
# Devuelve 0 si es mayor o igual a cero, 1 en caso contrario
tiempo() {
  TMP=$1
  if [ "$TMP" = "" ]; then
    #echo "La llamada no fue contestada"
    return 1
  fi
  if [ "$TMP" -ge 0 ]; then
    #echo "Es mayor o igual a cero"
    return 0
  fi
  #"Es menor o igual a cero"
  return 1
}

# Determina si un registro cumple con las verificaciones
# Devuelve 0 si todo OK
validarCamposRegistro() {
  local ID=$idAgente
  local FECHA=$inicioLlamada
  local TIEMPO=$tiempoConversacion
  local OAREA=$origenArea
  local ONUM=$origenNumero
  local DPAIS=$destinoPais
  local DAREA=$destinoArea
  local DNUM=$destinoNumero
      
  RECHAZO="false"
  idAgente "${AGENTES}" "${ID}"
  if [ "$?" = 1 ]; then
    RECHAZO="true"
    msj="el idAgente no coincide"
  fi

  codigoAreaA "${CDA}" "${OAREA}"
  if [ "$?" = 1 ]; then
    RECHAZO="true"
    msj="el codigoAreaA no coincide"
  fi

  numeroLineaA "${OAREA}" "${ONUM}"
  if [ "$?" = 1 ]; then
    RECHAZO="true"
    msj="el numeroLineaA no coincide"
  fi

  checkearNumeroB "${CDP}" "${DPAIS}" "${CDA}" "${DAREA}" "${DNUM}"

  tiempo "${TIEMPO}"
  if [ "$?" = 1 ]; then
    RECHAZO="true"
    msj="el tiempo no coincide"
  fi

  if [ "$RECHAZO" = "true" ]; then
    echo "Se rechaza el registro $idAgente porque "$msj
    motivo=$msj
    return 1
  fi

  return 0
} 

# 4.2 Determinar el tipo de llamada
# Devuelve 1 si se rechaza el registro
function determinarTipoDeLlamada() {
  local OAREA=$origenArea
  local DPAIS=$destinoPais
  local DAREA=$destinoArea
  local DNUM=$destinoNumero

  tipoLlamada=""
  
  llamadoValido="false"   
  
  # Si el Numero B llamado tiene código de país válido y un número de línea, la llamada es DDI.

  if [ "$DAREA" = "" ]; then
        if [[ ! -z $DNUM && `grep -c "${DPAIS}" $CDP` != 0 ]]; then
            tipoLlamada="DDI"
            llamadoValido="true"
        fi
  else
    # Si el Numero B llamado tiene código de área distinto al código de área de origen y un número de
    # línea con la cantidad adecuada de dígitos, la llamada es DDN.

    # Comprueba cantidad de digitos
    numeroLineaB "${DNUM}" "false" "${DAREA}"

    if [[ $DAREA != $OAREA && "$?" = 0 ]]; then
      tipoLlamada="DDN"
      llamadoValido="true"
    fi

    # Si el Numero B llamado tiene código de área igual al código de área de origen y un número de línea
    # con la cantidad adecuada de dígitos, la llamada es LOC
    if [[ $DAREA = $OAREA && "$?" = 0 ]]; then
       tipoLlamada="LOC"
       llamadoValido="true"
    fi
  fi  
  # 4.2.1
  # Cualquier otra combinación ir a RECHAZAR REGISTRO, sino continuar
  if [ $llamadoValido != "true" ] ; then
    echo -e "\t\tSe rechaza registro\n\n"
    return 1
  fi


  echo $idAgente $tipoLlamada
  #echo -e "\t\tNo se rechaza\n\n" 
  return 0

}

##########################################################################################

# 4.3 Determinar si la llamada debe ser considerada como sospechosa
# Campos de umbral.tab separados por ;
# id umbral;Cod de Area Origen;Num de linea de Origen;Tipo de Llamada;Codigo destino;Tope;Estado

function verificarLlamadaSospechosa() {
  IDAGENTE=$idAgente
  FECHAINICIO=$inicioLlamada
  TIEMPO=$tiempoConversacion
  OAREA=$origenArea
  ONUM=$origenNumero
  DPAIS=$destinoPais
  DAREA=$destinoArea
  DNUM=$destinoNumero

  # Se selecciona los campos que cumplen
# id umbral;Cod de Area Origen;Num de linea de Origen;Tipo de Llamada;Codigo destino;Tope;Estado

  local hayUmbral="false"
  local esSospechosa="false"
  local codDestino=""
  if [ $tipoLlamada = "DDI" ] ;then
    #id umbral;Cod de Area Origen;Num de linea de Origen;Tipo de Llamada;Codigo destino;Tope;Estado
    #165;341;30000112;DDI;27;88;Activo
    codDestino="${DPAIS}"
  else
    codDestino="${DAREA}"
  fi
  echo "$OAREA - $ONUM - $tipoLlamada - $codDestino"
  
  campoSeleccionado=$(grep "^.*;"${OAREA}";"${ONUM}";"${tipoLlamada}";"${codDestino}";.*Activo" $UMBRALES | head -n 1 )
  tope=$(echo $campoSeleccionado | cut -d' ' -f6 )
 
  if [ ${#campoSeleccionado} -gt 0 ];then
    #Llamadas con umbral
    cantidadConUmbral=$((cantidadConUmbral+1))
    if [ $tope -lt $TIEMPO ]; then
      cantLlamadasSospechosas=$((cantLlamadasSospechosas+1))
      IDUMBRAL=$(echo $campoSeleccionado | cut -d' ' -f1 )
      grabarLlamadaSospechosa 
    else
      cantLlamadasNoSospechosas=$((cantLlamadasNoSospechosas+1))
    fi
  else
    #Llamadas sin umbral
    cantidadSinUmbral=$((cantidadSinUmbral+1))
  fi

#id Central;idAgente;idUmbral;tipoDeLlamada;inicioDeLlamada;tiempoDeConversacion;codigoDeAreaA,numeroDeLineaA,
#codigoDePaisB,codigoDeAreaB,numeroDeLineaB,fechaDelArchivo
}
##########################################################################################

# 4.4 Grabar Llamadas Sospechosas

function grabarLlamadaSospechosa(){
  echo "Archivo con llamada sospechosa: $fileNameAProcesar"
 
  idDelcentral=$(echo $fileNameAProcesar | cut -d'_' -f1 )
  fechaDelArchivo=$(echo $fileNameAProcesar | cut -d'_' -f2 )
  
  echo "IdCentral y fecha de Archivo $idDelcentral - $fechaDelArchivo"
  
  #Busco agente en agentes.mae y luego la oficina
  local oficina=$(grep  "^.*;${IDAGENTE};" $AGENTES | cut -d';' -f4)

  local anioMesLlamada=$(echo $FECHAINICIO | sed "s/^.*\/\([0-9]\{2\}\)\/\([0-9]\{4\}\).*$/\2\1/")

  echo "oficina $oficina - $anioMesLlamada - $fechaFinal"
  local PROCARCH=$PROCDIR/$oficina"_"$anioMesLlamada

  #id Central;idAgente;idUmbral;tipoDeLlamada;inicioDeLlamada;tiempoDeConversacion;codigoDeAreaA,numeroDeLineaA,
  #codigoDePaisB,codigoDeAreaB,numeroDeLineaB,fechaDelArchivo
 echo  $idDelcentral";"$IDAGENTE";"$IDUMBRAL";"$tipoLlamada";"$FECHAINICIO";"$TIEMPO";"$OAREA";"$ONUM";"$DPAIS";"$DAREA";"$DNUM";"$fechaDelArchivo>>$PROCARCH
}


##########################################################################################

# 4.5 Rechazar registro

function rechazarRegistro() {
  # Aumento en uno el contador
  cantidadRegistrosRechazados=$((cantidadRegistrosRechazados+1))
  local CODCENTRAL=$(echo $ARCH | cut -d'_' -f1)
  local RECHARCH="$RECHDIR/llamadas/$CODCENTRAL.rech"

  # id; fecha y hora; tiempo; origen area; origen numero; destino pais; destino area; destino numero

  echo  "$ARCH" ";" "$motivo" ";" "$idAgente" ";" "$inicioLlamada" ";" "$tiempoConversacion" ";" "$origenArea" ";" "$origenNumero" ";" "$destinoPais" ";" "$destinoArea" ";" "$destinoNumero" >> $RECHARCH 
}

##########################################################################################

# 6. Fin de archivo

function finDeArchivo() {
	local archivo=$1
	echo "Procesar Archivo: $archivo 2"
  $MOVER "$ACEPDIR/$archivo" "$PROCDIR"/proc "${0}"

  MSJ="Cantidad de llamadas: $cantRegistrosLeidos"
  msjLog "${MSJ}" "INFO"

  MSJ="Rechazadas: $cantidadRegistrosRechazados, Con umbral: $cantidadConUmbral, Sin umbral: $cantidadSinUmbral"
  msjLog "${MSJ}" "INFO"

  MSJ="Cantidad de llamadas sospechosas: $cantLlamadasSospechosas generaron llamadas sospechosas, no sospechosas: $cantLlamadasNoSospechosas"
  msjLog "${MSJ}" "INFO"
}
##########################################################################################

inicio

