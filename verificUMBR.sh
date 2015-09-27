#!/bin/bash
# Verificaciones para afraumbr

#4. Procesar un registro

#4.1 Validar los campos del registro

# Valida el id de agente 
# Devuelve 1 si no fue encontrado, 0 en caso contrario
idAgente() {
  ARCH=$1 # agentes.csv
  ID=$2
  if grep -q "^${ID};" $ARCH;
  then
    echo "Encontrado"
    echo -e "$(grep "^${ID};" $ARCH)\n"
    return 0 # fue encontrado
  else
    echo "No encontrado"
    return 1 # no fue encontrado
  fi
}

# Valida el codigo de area 
# Devuelve 1 si no fue encontrado, 0 en caso contrario
area() {
  ARCH=$1 #CdA.csv
  AREA=$2
  if grep -q $";${AREA}" $ARCH;
  then
    echo "Encontrado"
    echo -e "$(grep $";${AREA}" $ARCH)\n"
    return 0 # fue encontrado
  else
    echo "No encontrado"
    return 1 # no fue encontrado
  fi
}

# Valida el numero de linea
# Es 1 si cumple, 0 sino
numeroLinea() {
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
    echo "NUM contiene $DIG"
    return 1
  else
    echo "NUM contiene distinto num que DIG"
    return 0
  fi
}

# Valida el codigo de pais
# Devuelve 1 si no fue encontrado, 0 en caso contrario 
codigoPais() {
  ARCH=$1 #CdP.csv
  COD=$2
  if [ "$COD" = "" ]; then   # no es DDI si el campo esta vacio
    return 1
  fi
  # es DDI cuando contiene el codigo
  if grep -q "^${COD};" $ARCH;
  then
    echo "Encontrado"
    echo -e "$(grep "^${COD};" $ARCH)\n"
    return 0 # fue encontrado
  else
    echo "No encontrado"
    return 1 # no fue encontrado
  fi
}

# Valida el tiempo de conversacion
# Devuelve 1 si es mayor o igual a cero, 0 en caso contrario
tiempo() {
  TMP=$1
  if [ "$TMP" = "" ]; then
    echo "La llamada no fue contestada"
    return 0
  fi
  if [ "$TMP" -ge 0 ]; then
    echo "Es mayor o igual a cero"
    return 1
  fi
  "Es menor o igual a cero"
  return 0
}

########

idAgente "agentes.csv" "BONINO"

area "CdA.csv" "11"

numeroLinea "1002" "1113456"

# codigoPais "CdP.csv" "1441" # ESTA TENGO QUE REVISARLA

# falta codigo de area NUMB

# falta numero de linea NUMB

tiempo "20"
