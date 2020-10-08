#!/bin/bash

##updated 7/24/2020
##altered --store flag to account for th's store number scheme

if ! [[ -e $HOME/files/public/mrbrown/stores/stores.db ]]; then
  cd $HOME
  mount_userdata.sh
fi

if ! [[ -e $HOME/files/public/mrbrown/stores/stores.db ]]; then
  echo -e "-I cannot see the database files, try mounting you public directory, then try again"
  echo -e "-cd $HOME; mount_userdata.sh"
  exit 1
fi

## get to the db's directory
cd $HOME/files/public/mrbrown/stores

function help_screen {
echo "
--------------------------------------------------------------------------------------------------------
|  SYNTAX                    |  store_query --flag1 arg1 arg2 --flag2 arg1 arg2                        |
--------------------------------------------------------------------------------------------------------
|  FLAGS                     |  DESCRIPTION                                                            |
--------------------------------------------------------------------------------------------------------
|  --o, --ownercode          |  searches for the specific ownercode: ie --ownercode Rackson_King_Conn  |
--------------------------------------------------------------------------------------------------------
|  --l, --logo               |  searches for a specific store's logo: ie --logo bk (or pop)            |
--------------------------------------------------------------------------------------------------------
|  --s, --store              |  seaches for the specific store number: ie --store bk101                |
--------------------------------------------------------------------------------------------------------
|  --i, --ip                 |  searhes for the ip address of a device: ie --ip 192.168.1.80           |
--------------------------------------------------------------------------------------------------------
|  --m, --mac                |  searches for the specific mac address: ie --mac 00:05:0B:B0:43:5D      |
--------------------------------------------------------------------------------------------------------
|  --d, --device             |  searchs for the device name: ie --device term000                       |
--------------------------------------------------------------------------------------------------------
|  --t, --type               |  searches for the specific device type: ie --type SICOMsl20P            |
--------------------------------------------------------------------------------------------------------
|  --v, --mgrng_v            |  searches for the software version: ie --mgrng_v 2.800.30               |
--------------------------------------------------------------------------------------------------------
|  --p, --pos_v              |  searches for the specific pos version: ie --pos_v 6.28.0               |
--------------------------------------------------------------------------------------------------------
|  --help, --h, --?          |  shows the help screen (this screen)                                    |
--------------------------------------------------------------------------------------------------------
"
   exit 1
} ##end of help_screen function

for OPTIONS in $*; do
  case $OPTIONS in
    --help|--h|--\?)
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
done

## parsing through all of the user supplied flags and arguments
FOR_COUNTER=0
for STUFF in ${ARGS[@]}; do

  ## checking each argument for a '--' flag
  if [[ $(echo $STUFF | grep -c '\-\-') -eq 1 ]]; then
    FLAG=true
    DATA_ARRAY=()
    WHILE_COUNTER=1
    while [[ $FLAG == 'true' ]]; do
      ## checking to see if the user forgot to put in an argument
      if [[ $(echo ${ARGS[$((FOR_COUNTER+1))]}) == '' ]]; then
        echo -e "\n-missing argument after $STUFF\n"
        echo -e "-exiting... and displaying the help screen\n"
	      sleep 3
        help_screen
      fi
      ## adding the argument to the array if it's not a flag
      if [[ $(echo ${ARGS[$((FOR_COUNTER+WHILE_COUNTER))]} | grep -c '\-\-') -eq 0 ]]; then
        DATA_ARRAY+=(${ARGS[$((FOR_COUNTER+WHILE_COUNTER))]})
      fi
      ## exiting the loop if the next arguement is a flag or blank
      if [[ $(echo ${ARGS[$((FOR_COUNTER+WHILE_COUNTER+1))]} | grep -c '\-\-') -eq 1 || $(echo ${ARGS[$((FOR_COUNTER+WHILE_COUNTER+1))]}) == '' ]]; then
        FLAG=false
      fi
      WHILE_COUNTER=$((WHILE_COUNTER+1))
    done

## storing the data from the DATA_ARRAY into individual arrays, based on the flag submitted by the user
  case $STUFF in
    --l|--logo)
      LOGO_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        LOGO_DATA+=($DATA)
        LOGO_COUNT=$((LOGO_COUNT+1))
      done
      ;;
    --s|--store)
      STORE_FLAG=true
      LOGO_FLAG=true
      for DATA in `echo ${DATA_ARRAY[@]}`; do
        if [[ $(echo $DATA | grep -ic th) -eq 1 ]]; then
          STORE_NUMBER=$(echo $DATA | tr -d '[:alpha:]')
          if [[ $(echo $STORE_NUMBER | wc -m) -eq 7 ]]; then
            STORE_DATA+=($STORE_NUMBER)
          else
      	    STORE_DATA+=(`printf "1%05d" $STORE_NUMBER`)
          fi
        else
          STORE_DATA+=(`echo $DATA | tr -d '[:alpha:]'`)
        fi
        STORE_COUNT=$((STORE_COUNT+1))
      done
      for DATA in `echo ${DATA_ARRAY[@]} | tr -d '[:digit:]'`; do
        LOGO_DATA+=($DATA)
        LOGO_COUNT=$((LOGO_COUNT+1))
      done
      ;;
    --i|--ip)
      IP_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        IP_DATA+=($DATA)
        IP_COUNT=$((IP_COUNT+1))
      done
      ;;
    --d|--device)
      DEVICE_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        DEVICE_DATA+=($DATA)
        DEVICE_COUNT=$((DEVICE_COUNT+1))
      done
      ;;
    --o|--ownercode)
      OWNERCODE_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        OWNERCODE_DATA+=($DATA)
        OWNERCODE_COUNT=$((OWNERCODE_COUNT+1))
      done
      ;;
    --t|--type)
      TYPE_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        TYPE_DATA+=($DATA)
        TYPE_COUNT=$((TYPE_COUNT+1))
      done
      ;;
    --v|--mgrng_v)
      MGRNG_V_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        MGRNG_DATA+=($DATA)
        MGRNG_COUNT=$((MGRNG_COUNT+1))
      done
      ;;
    --p|--pos_v)
      POS_V_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        POS_DATA+=($DATA)
        POS_COUNT=$((POS_COUNT+1))
      done
      ;;
    --m|--mac)
      MAC_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        MAC_COUNT=$((MAC_COUNT+1))
        MAC_DATA+=($DATA)
      done
      ;;
    *)
      echo -e "\n-unrecognized flag: $STUFF\n"
      echo -e "-displaying help screen...\n"
      sleep 3
      help_screen
      ;;
  esac
fi
FOR_COUNTER=$((FOR_COUNTER+1))
done

## creating claues in the select statement based on user options and how many options the user picked
COUNT=0
COUNT=$((LOGO_COUNT+STORE_COUNT+IP_COUNT+DEVICE_COUNT+OWNERCODE_COUNT+TYPE_COUNT+MGRNG_COUNT+POS_COUNT+MAC_COUNT))
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

sqlite3 stores.db -header -column "select ownercode, logo, store_number, device_ip_address, device_mac_address, device_name, device_type, mgrng_v, pos_v, last_reported from master_list where $CLAUSE order by length(ownercode) desc, length(device_ip_address)"
