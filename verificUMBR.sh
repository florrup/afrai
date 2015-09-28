#!/bin/bash
# Verificaciones para afraumbr

#4. Procesar un registro

#4.1 Validar los campos del registro

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

########

ARCH="BEL_20150703.csv" 
AGENTES="agentes.csv"
CDP="CdP.csv"
CDA="CdA.csv"

# id; fecha y hora; tiempo; origen area; origen numero; destino pais; destino area; destino numero
IFS=";"
while read f1 f2 f3 f4 f5 f6 f7 f8
do
  validarCamposRegistro "$f1" "$f2" "$f3" "$f4" "$f5" "$f6" "$f7" "$f8"
done < $ARCH





