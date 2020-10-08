#!/bin/bash

if ! [[ -e $HOME/files/public/mrbrown/stores/stores.db ]]; then
  echo -e "-I cannot see the database files, try mounting you public directory, then try again"
  echo -e "-cd $HOME; mount_userdata.sh"
fi

## get to the db's directory
cd $HOME/files/public/mrbrown/stores

function help_screen {
echo "
-----------------------------------------------------------------------------------------------
|  SYNTAX               |  store_query --option1 --option2 --option3 ...                      |
-----------------------------------------------------------------------------------------------
|  OPTIONS              |  DESCRIPTION                                                        |
-----------------------------------------------------------------------------------------------
|  --ownercode          |  searches for the specific ownercode: ie Rackson_King_Conn          |
-----------------------------------------------------------------------------------------------
|  --logo               |  searches for a specific store's logo (bk or pop)                   |
-----------------------------------------------------------------------------------------------
|  --store              |  seaches for the specific store number: ie bk101, pop7007           |
-----------------------------------------------------------------------------------------------
|  --ip                 |  searhes for the ip address of a device: ie 192.168.1.80            |
-----------------------------------------------------------------------------------------------
|  --mac                |  searches for the specific mac address: ie 00:05:0B:B0:43:5D        |
-----------------------------------------------------------------------------------------------
|  --device             |  searchs for the device name: ie term000, ks001                     |
-----------------------------------------------------------------------------------------------
|  --type               |  searches for the specific device type: ie SICOMsl21B, SICOMsl20P   |
-----------------------------------------------------------------------------------------------
|  --mgrng_v            |  searches for the software version: ie 2.800.30                     |
-----------------------------------------------------------------------------------------------
|  --pos_v              |  searches for the specific pos version: ie 6.28.0                   |
-----------------------------------------------------------------------------------------------
"
   exit 1
} ##end of help_screen function

for OPTIONS in $*; do
  case $OPTIONS in
    --help|--h|-help|-h)
    help_screen
    ;;
  esac
done

if [[ -z $* ]]; then
  help_screen
fi

## SETTING UP FLAGS FOR THE OPTIONS

  LOGO_FLAG=false
  STORE_FLAG=false
  IP_FLAG=false
  DEVICE_FLAG=false
  OWNEERCODE_FLAG=false
  TYPE_FLAG=false
  MGRNG_V_FLAG=false
  POS_V_FLAG=false
  MAC_FLAG=false

## SETTING UP COUNTS FOR THE OPTIONS

  LOGO_COUNT=0
  STORE_COUNT=0
  IP_COUNT=0
  DEVICE_COUNT=0
  OWNERCODE_COUNT=0
  TYPE_COUNT=0
  MGRNG_COUNT=0
  POS_COUNT=0
  MAC_COUNT=0

## SETTING UP THE DATA ARRAYS

LOGO_DATA=()
STORE_DATA=()
IP_DATA=()
DEVICE_DATA=()
OWNERCODE_DATA=()
TYPE_DATA=()
MGRNG_DATA=()
POS_DATA=()
MAC_DATA=()

## adding each argument into an array to be called on later
ARGS=()
ELEMENT=0
for ARGUMENTS in $*; do
  ARGS+=($ARGUMENTS)
  ELEMENT=$((ELEMENT+1))
done

for OPTIONS in $*; do
  case $OPTIONS in
    --logo)
      LOGO_FLAG=true
      for DATA in `echo $* | awk -F "--logo " '{print$NF}' | awk -F " --" '{print$1}'`; do
        LOGO_DATA+=($DATA)
        LOGO_COUNT=$((LOGO_COUNT+1))
      done
      ;;
    --store)
      STORE_FLAG=true
      LOGO_FLAG=true
      for DATA in `echo $* | awk -F "--store " '{print$NF}' | awk -F " --" '{print$1}' | tr -d '[:alpha:]'`; do
      	STORE_DATA+=($DATA)
        STORE_COUNT=$((STORE_COUNT+1))
      done
      for DATA in `echo $* | awk -F "--store " '{print$NF}' | awk -F " --" '{print$1}' | tr -d '[:digit:]'`; do
        LOGO_DATA+=($DATA)
        LOGO_COUNT=$((LOGO_COUNT+1))
      done
      ;;
    --ip)
      IP_FLAG=true
      for DATA in `echo $* | awk -F "--ip " '{print$NF}' | awk -F " --" '{print$1}'`; do
        IP_DATA+=($DATA)
        IP_COUNT=$((IP_COUNT+1))
      done
      ;;
    --device)
      DEVICE_FLAG=true
      for DATA in `echo $* | awk -F "--device " '{print$NF}' | awk -F " --" '{print$1}'`; do
        DEVICE_DATA+=($DATA)
        DEVICE_COUNT=$((DEVICE_COUNT+1))
      done
      ;;
    --ownercode)
      OWNERCODE_FLAG=true
      for DATA in `echo $* | awk -F "--ownercode " '{print$NF}' | awk -F " --" '{print$1}'`; do
        OWNERCODE_DATA+=($DATA)
        OWNERCODE_COUNT=$((OWNERCODE_COUNT+1))
      done
      ;;
    --type)
      TYPE_FLAG=true
      for DATA in `echo $* | awk -F "--type " '{print$NF}' | awk -F " --" '{print$1}'`; do
        TYPE_DATA+=($DATA)
        TYPE_COUNT=$((TYPE_COUNT+1))
      done
      ;;
    --mgrng_v)
      MGRNG_V_FLAG=true
      for DATA in `echo $* | awk -F "--mgrng_v " '{print$NF}' | awk -F " --" '{print$1}'`; do
        MGRNG_DATA+=($DATA)
        MGRNG_COUNT=$((MGRNG_COUNT+1))
      done
      ;;
    --pos_v)
      POS_V_FLAG=true
      for DATA in `echo $* | awk -F "--pos_v " '{print$NF}' | awk -F " --" '{print$1}'`; do
        POS_DATA+=($DATA)
        POS_COUNT=$((POS_COUNT+1))
      done
      ;;
    --mac)
      MAC_FLAG=true
      for DATA in `echo $* | awk -F "--mac " '{print$NF}' | awk -F " --" '{print$1}'`; do
        MAC_COUNT=$((MAC_COUNT+1))
        MAC_DATA+=($DATA)
      done
      ;;
  esac
done

## checking to see if any flag was used more than once
for COUNTS in $LOGO_COUNT $STORE_COUNT $IP_COUNT $DEVICE_COUNT $OWNERCODE_COUNT $TYPE_COUNT $MGRNG_COUNT $POS_COUNT $MAC_COUNT; do
  if [[ $COUNTS -gt 1 ]]; then
    echo -e "\n-ERROR!!!: you can only use a flag once!\n"
    echo -e "\n-put your parameters next to each flags\n"
    echo -e "\n-ie: store_query --store bk101 pop7007\n"
  fi
done

## count how many flags are true
COUNT=0
COUNT=$((LOGO_COUNT+STORE_COUNT+IP_COUNT+DEVICE_COUNT+OWNERCODE_COUNT+TYPE_COUNT+MGRNG_COUNT+POS_COUNT+MAC_COUNT))



## creating claues in the select statement based on user options and how many options the user picked
CLAUSES=''

if [[ $STORE_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for STORE_NUMBER in ${STORE_DATA[@]}; do
    if [[ $STORE_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE store_number = $STORE_NUMBER or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE store_number = $STORE_NUMBER)"
      else
        CLAUSE="$CLAUSE store_number = $STORE_NUMBER) and"
      fi
    fi
    STORE_COUNT=$((STORE_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $LOGO_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for LOGO in ${LOGO_DATA[@]}; do
    if [[ $LOGO_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE logo = '$LOGO' or"
    else
      if [[ $COUNT -gt 1 ]]; then
        CLAUSE="$CLAUSE logo = '$LOGO') and"
      else
        CLAUSE="$CLAUSE logo = '$LOGO')"
      fi
    fi
  LOGO_COUNT=$((LOGO_COUNT-1))
  COUNT=$((COUNT-1))
  done
fi

if [[ $IP_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for IP in `echo ${IP_DATA[@]}`; do
    if [[ $IP_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE device_ip_address like '%$IP%' or"
    else
      if [[ COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE device_ip_address like '%$IP%')"
      else
        CLAUSE="$CLAUSE device_ip_address like '%$IP%') and"
      fi
    fi
    IP_COUNT=$((IP_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $DEVICE_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for DEVICE in `echo ${DEVICE_DATA[@]}`; do
    if [[ $DEVICE_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE device_name like '%$DEVICE%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE device_name like '%$DEVICE%')"
      else
        CLAUSE="$CLAUSE device_name like '%$DEVICE%') and"
      fi
    fi
      DEVICE_COUNT=$((DEVICE_COUNT-1))
      COUNT=$((COUNT-1))
    done
fi

if [[ $OWNERCODE_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for OWNERCODE in `echo ${OWNERCODE_DATA[@]}`; do
    if [[ $OWNERCODE_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE ownercode like '%$OWNERCODE%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE ownercode like '%$OWNERCODE%')"
      else
        CLAUSE="$CLAUSE ownercode like '%$OWNERCODE%') and"
      fi
    fi
    OWNERCODE_COUNT=$((OWNERCODE_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $TYPE_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for TYPE in `echo ${TYPE_DATA[@]}`; do
    if [[ $TYPE_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE device_type like '%$TYPE%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE device_type like '%$TYPE%')"
      else
        CLAUSE="$CLAUSE device_type like '%$TYPE%') and"
      fi
    fi
  TYPE_COUNT=$((TYPE_COUNT-1))
  COUNT=$((COUNT-1))
  done
fi

if [[ $MGRNG_V_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for MGRNG_V in `echo ${MGRNG_DATA[@]}`; do
    if [[ $MGRNG_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE mgrng_v like '%$MGRNG_V%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE mgrng_v like '%$MGRNG_V%')"
      else
        CLAUSE="$CLAUSE mgrng_v like '%$MGRNG_V%') and"
      fi
    fi
    MGRNG_COUNT=$((MGRNG_COUNT-1))
    COUNT=$(($COUNT-1))
  done
fi

if [[ $POS_V_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for POS_V in `echo ${POS_DATA[@]}`; do
    if [[ $POS_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE pos_v like '%$POS_V%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE pos_v like '%$POS_V%')"
      else
        CLAUSE="$CLAUSE pos_v like '%$POS_V%') and"
      fi
    fi
    POS_COUNT=$((POS_COUNT-1))
    COUNT=$(($COUNT-1))
  done
fi

if [[ $MAC_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for MAC in `echo ${MAC_DATA[@]}`; do
    if [[ $MAC_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE device_mac_address like '%$MAC%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE device_mac_address like '%$MAC%')"
      else
        CLAUSE="$CLAUSE device_mac_address like '%$MAC%') and"
      fi
    fi
    MAC_COUNT=$((MAC_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

sqlite3 stores.db -header -column "select ownercode, logo, store_number, device_ip_address, device_mac_address, device_name, device_type, mgrng_v, pos_v from master_list where $CLAUSE order by length(ownercode) desc"
