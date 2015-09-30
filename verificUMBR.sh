#! /bin/bash
# ******************************************************************
# Verificacion de umbrales
#
# ******************************************************************
#Cdp.mae
#cdA.mae
#CdC.mae
#agentes.mae
#tllama.tab
#umbral.tab

SCRIPT=`basename "$0"`

GRALOG="./gralog.sh"
MOVER="./mover.sh"

ACEPDIR="ACEPDIR" 	# deben ser las variables de configuracion
RECHDIR="RECHDIR"
PROCDIR="PROCDIR"

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

  # Calculo la cantidad de archivos en ACEPDIR
  cantArchivos=$(ls "$ACEPDIR"/*csv | wc -l)

  MSJ="Cantidad de archivos a procesar: $cantArchivos"
  msjLog "${MSJ}" "INFO"
    
  # Parseo por fechas y lista ordenando cronologicamente
  # Desde el antiguo al mas reciente 
  inputFiles=$(ls $ACEPDIR | grep '[0-9]*[0-9]' | sort -k1.4)

  for fileName in $inputFiles;
  do
    echo $fileName
    procesarArchivo $fileName
    if [ "$?" = 0 ]; then	# si no fue procesado, sigo
      validarPrimerRegistro $fileName
      if [ "$?" = 0 ]; then
        # 3. Si se puede procesar el archivo
        msjLog "Archivo a procesar: $fileName" "INFO"

	# Empiezo a procesar cada registro
	procesarRegistro $fileName

      fi
    fi
  done  
}

##########################################################################################

# 2. Procesar un Archivo

# 2.1. Verificar que no sea un archivo duplicado
# Devuelve 1 si ya fue procesado, 0 en caso contrario
function procesarArchivo() {
  local ARCH=$1

  # Verifico si el archivo ya fue procesado
  if [ -s $PROCDIR/$ARCH ]; then
    MSJ="Se rechaza el archivo por estar DUPLICADO"
    msjLog "$MSJ" "ERR" 
    $MOVER "$ACEPDIR/$ARCH" "$RECHDIR" "${0}"
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
      msjLog "$MSJ" "ERR"
      echo $ACEPDIR/$ARCH
      $MOVER "$ACEPDIR/$ARCH" "$RECHDIR" "${0}"
      return 1
  fi
  return 0
}

##########################################################################################

# 4. Procesar un registro

procesarRegistro() {
  local ARCH=$1
  # id; fecha y hora; tiempo; origen area; origen numero; destino pais; destino area; destino numero
  IFS=";"
  while read f1 f2 f3 f4 f5 f6 f7 f8
  do
    validarCamposRegistro "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8"
    #determinarTipoDeLlamada "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8"
    #verificarLlamadaSospechosa 
  done < $ACEPDIR/$ARCH
}

# 4.1 Validar los campos del registro

# Valida el id de agente 
# Devuelve 1 si no fue encontrado, 0 en caso contrario
idAgente() {
  ARCH=$1 # agentes.csv
  ID=$2
  if grep -q ";${ID};" $ARCH;
  then
    #echo "Encontrado"
    #echo "$(grep ";${ID};" $ARCH)"
    return 0 # fue encontrado
  else
    #echo "No encontrado en AGENTES.CSV"
    return 1 # no fue encontrado
  fi
}

# Valida el codigo de area 
# Devuelve 1 si no fue encontrado, 0 en caso contrario
codigoAreaA() {
  ARCH=$1 #CdA.csv
  AREA=$2
  if grep -q $";${AREA}" $ARCH;
  then
    #echo "Encontrado en CDA"
    #echo "$(grep $";${AREA}" $ARCH)"
    return 0 # fue encontrado
  else
    #echo "No encontrado en CDA"
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
codigoPaisB() {
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
    if grep -q "^${CODPAIS};" $CDP;
    then
      echo "Encontrado"
      #echo "$(grep "^${CODPAIS};" $CDP)"
      #return 0  # fue encontrado
    else
      #echo "No encontrado\n\n"
      return 1 # no fue encontrado
    fi
  fi

  codigoArea "${CDA}" "${CODAREA}" "${DDI}"
  rtaArea=$?
  if [ "${rtaArea}" = 1 ]; then
    return 1
  else
    #return 0
    echo "Continuo verificando"
  fi

  numeroLineaB "${NUM}" "${DDI}" "${CODAREA}"
  rtaNum=$?
  if [ "${rtaNum}" = 1 ]; then
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
  if [ "$CODAREA" = "" ]; then
    #echo "CODAREA no esta\n\n"
    return 1
  fi
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
  local ID=$1
  local FECHA=$2
  local TIEMPO=$3
  local OAREA=$4
  local ONUM=$5
  local DPAIS=$6
  local DAREA=$7
  local DNUM=$8

  RECHAZO="false"
  idAgente "${AGENTES}" "${ID}"
  if [ "$?" = 1 ]; then
    #echo "Se rechaza"
    RECHAZO="true"
  else
    echo -e "\tNo se rechaza por idAgente"
  fi

  codigoAreaA "${CDA}" "${OAREA}"
  if [ "$?" = 1 ]; then
    RECHAZO="true"
  else
    echo -e "\tNo se rechaza por codigoAreaA"
  fi

  numeroLineaA "${OAREA}" "${ONUM}"
  if [ "$?" = 1 ]; then
    RECHAZO="true"
  else
    echo -e "\tNo se rechaza por numeroLineaA"
  fi

  codigoPaisB "${CDP}" "${DPAIS}" "${CDA}" "${DAREA}" "${DNUM}"
  if [ "$?" = 1 ]; then
    RECHAZO="true"
  else
    echo -e "\tNo se rechaza por codigoPaisB"
  fi

  tiempo "${TIEMPO}"
   if [ "$?" = 1 ]; then
    RECHAZO="true"
  else
    echo -e "\tNo se rechaza por tiempo"
  fi

  if [ "$RECHAZO" = "true" ]; then
    echo -e "\t\tSe rechaza\n\n"
    return 1
  fi
  echo -e "\t\tNo se rechaza\n\n"
  return 0
} 

# 4.2 Determinar el tipo de llamada
function determinarTipoDeLlamada(){
  local ID=$1
  local FECHA=$2
  local TIEMPO=$3
  local OAREA=$4
  local ONUM=$5
  local DPAIS=$6
  local DAREA=$7
  local DNUM=$8

  #Falta hacer pruebas 
  re='^[0-9]+$'

  #Si el Numero B llamado tiene código de país válido y un número de línea, la llamada es DDI.
  if [ "$DAREA"="" -a ![ $DNUM=~$re ] ]; then
    tipoLlamada="DDI"
  else
    #Si el Numero B llamado tiene código de área distinto al código de área de origen y un número de
    #línea con la cantidad adecuada de dígitos, la llamada es DDN.

    #Comprueba cantidad de digitos
    numeroLineaA  "${OAREA}" "${ONUM}"

    if [ $DAREA != $OAREA -a "$?" = 0 ]; then
       tipoLlamada="DDN"
    else
       #Si el Numero B llamado tiene código de área igual al código de área de origen y un número de línea
       #con la cantidad adecuada de dígitos, la llamada es LOC
       
       if [$DAREA = $OAREA -a "$?" = 0]; then
         tipoLlamada="LOC"
       else
	 #4.2.1
	 #Cualquier otra combinación ir a RECHAZAR REGISTRO, sino continuar
         echo -e "\t\tSe rechaza registro\n\n"
         return 1
       fi

    fi
  fi

  echo -e "\t\tNo se rechaza\n\n" 
  return 0

}

##########################################################################################


# 4.3 Determinar si la llamada debe ser considerada como sospechosa.

cantidadSinUmbral=0
cantidadConUmbral=0

#Campos de umbral.tab (umbrales.csv) separados por ;
#id umbral;Cod de Area Origen;Num de linea de Origen;Tipo de Llamada;Codigo destino;Tope;Estado

function verificarLlamadaSospechosa(){
  local ID=$1
  local FECHA=$2
  local TIEMPO=$3
  local OAREA=$4
  local ONUM=$5
  local DPAIS=$6
  local DAREA=$7
  local DNUM=$8


  #Se selecciona los campos que cumplen
  cantidadCampoSeleccionado=ls -1 | grep "^.*;"{OAREA}";"{ONUM}";.*Activo" umbrales.csv | wc -l
  campoSeleccionado=ls -1 | grep "^.*;"{OAREA}";"{ONUM}";.*Activo" umbrales.csv 
  
  if [[ $cantidadCampoSeleccionado == 0 ]]; then
     cantidadSinUmbral=$((cantidadSinUmbral+1))
  else
     #Aca se tiene que definir que se hace cuando hay mas de un umbral aplicable a la llamada
     cantidadConUmbral=$((cantidadSinUmbral+1))
  fi
}



##########################################################################################

inicio

#ARCH="BEL_20150703.csv" 
#AGENTES="agentes.csv"
#CDP="CdP.csv"
#CDA="CdA.csv"

# id; fecha y hora; tiempo; origen area; origen numero; destino pais; destino area; destino numero
#IFS=";"
#while read f1 f2 f3 f4 f5 f6 f7 f8
#do
  #validarCamposRegistro "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8"
  #determinarTipoDeLlamada "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8"
  #verificarLlamadaSospechosa 
#done < $ARCH
