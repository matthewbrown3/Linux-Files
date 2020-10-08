#!/bin/bash

if ! [[ -e $HOME/files/public/mrbrown/ascii/ascii.db ]]; then
  cd $HOME
  mount_userdata.sh
fi

if ! [[ -e $HOME/files/public/mrbrown/ascii/ascii.db ]]; then
  echo -e "-I cannot see the database files, try mounting you public directory, then try again"
  echo -e "-cd $HOME; mount_userdata.sh"
  exit 1
fi

## get to the db's directory
cd $HOME/files/public/mrbrown/ascii

function help_screen {
echo "
-----------------------------------------------------------------------------------------
|  SYNTAX  |  ascii --flag1 arg1 arg2 --flag2 arg1 arg2                                 |
-----------------------------------------------------------------------------------------
|  FLAGS  |  DESCRIPTION                                                               |
-----------------------------------------------------------------------------------------
|  --bin   |  displays bin, oct, hex and char values of the provided binary value       |
-----------------------------------------------------------------------------------------
|  --oct   |  displays bin, oct, hex and char values of the provided octal value        |
-----------------------------------------------------------------------------------------
|  --hex   |  displays bin, oct, hex and char values of the provided hexidecimal value  |
-----------------------------------------------------------------------------------------
|  --char  |  displays bin, oct, hex and char values of the provided character value    |
-----------------------------------------------------------------------------------------
"

exit 1

}  ## end of help screen function

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

  BIN_FLAG=false
  OCTAL_FLAG=false
  HEX_FLAG=false
  CHAR_FLAG=false

## SETTING UP COUNTS FOR THE OPTIONS

  BIN_COUNT=0
  OCTAL_COUNT=0
  HEX_COUNT=0
  CHAR_COUNT=0

## SETTING UP THE DATA ARRAYS

  BIN_DATA=()
  OCTAL_DATA=()
  HEX_DATA=()
  CHAR_DATA=()


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
    --bin)
      BIN_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        BIN_DATA+=($DATA)
        BIN_COUNT=$((BIN_COUNT+1))
      done
      ;;
    --oct)
      OCTAL_FLAG=true
      for DATA in `echo ${DATA_ARRAY[@]}`; do
      	OCTAL_DATA+=($DATA)
        OCTAL_COUNT=$((OCTAL_COUNT+1))
      done
      ;;
    --dec)
      DEC_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        DEC_DATA+=($DATA)
        DEC_COUNT=$((DEC_COUNT+1))
      done
      ;;
    --hex)
      HEX_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        HEX_DATA+=($DATA)
        HEX_COUNT=$((HEX_COUNT+1))
      done
      ;;
    --char)
      CHAR_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        CHAR_DATA+=($DATA)
        CHAR_COUNT=$((CHAR_COUNT+1))
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
COUNT=$((BIN_COUNT+OCTAL_COUNT+DEC_COUNT+HEX_COUNT+CHAR_COUNT))
CLAUSE=''

if [[ $BIN_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for BIN in ${BIN_DATA[@]}; do
    if [[ $BIN_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE binary = $BIN or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE binary = $BIN)"
      else
        CLAUSE="$CLAUSE binary = $BIN) or"
      fi
    fi
    BIN_COUNT=$((STORE_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $OCTAL_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for OCTAL in ${OCTAL_DATA[@]}; do
    if [[ $OCTAL_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE octal = $OCTAL or"
    else
      if [[ $COUNT -gt 1 ]]; then
        CLAUSE="$CLAUSE octal = $OCTAL) or"
      else
        CLAUSE="$CLAUSE octal = $OCTAL)"
      fi
    fi
  OCTAL_COUNT=$((OCTAL_COUNT-1))
  COUNT=$((COUNT-1))
  done
fi

if [[ $DEC_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for DEC in ${DEC_DATA[@]}; do
    if [[ $DEC_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE decimal = $DEC or"
    else
      if [[ $COUNT -gt 1 ]]; then
        CLAUSE="$CLAUSE decimal = $DEC) or"
      else
        CLAUSE="$CLAUSE decimal = $DEC)"
      fi
    fi
    DEC_COUNT=$((DEC_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $HEX_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for HEX in `echo ${HEX_DATA[@]}`; do
    if [[ $HEX_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE hexidecimal like '%$HEX%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE hexidecimal like '%$HEX%')"
      else
        CLAUSE="$CLAUSE hexidecimal like '%$HEX%') or"
      fi
    fi
    HEX_COUNT=$((HEX_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $CHAR_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for CHAR in `echo ${CHAR_DATA[@]}`; do
    if [[ $CHAR_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE character like '$CHAR' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE character = '$CHAR')"
      else
        CLAUSE="$CLAUSE character like '$CHAR') or"
      fi
    fi
      CHAR_COUNT=$((CHAR_COUNT-1))
      COUNT=$((COUNT-1))
    done
fi

sqlite3 ascii.db -header -column "select description, binary, octal, decimal, hexidecimal, character from ascii where $CLAUSE order by length(description) desc"
