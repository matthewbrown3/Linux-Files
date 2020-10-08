#!/bin/bash
## created by mrb on 4/17/2020
## version 2
## added the ability to search based on pos v and keywords
## next thought, make something that can search by date created/updated

if ! [[ -e $HOME/files/public/mrbrown/jira/jira.db ]]; then
  cd $HOME
  mount_userdata.sh
fi

if ! [[ -e $HOME/files/public/mrbrown/jira/jira.db ]]; then
  echo -e "-I cannot see the database files, try mounting you public directory, then try again"
  echo -e "-cd $HOME; mount_userdata.sh"
  exit 1
fi

## get to the db's directory
cd $HOME/files/public/mrbrown/jira

function help_screen {
echo "
---------------------------------------------------------------------------------------------------------------------------
|  SYNTAX                                                                                                                 |
---------------------------------------------------------------------------------------------------------------------------
|  store_query --flag1 arg1 arg2 --flag2 arg1 arg2                                                                        |
---------------------------------------------------------------------------------------------------------------------------
|  FLAGS                       |  DESCRIPTION                                                                             |
---------------------------------------------------------------------------------------------------------------------------
|  --d, --desc, --description  |  searches each jira description for the supplied string                                  |
---------------------------------------------------------------------------------------------------------------------------
|  --n, --name                 |  seaches for the jira by the name, ie: esc-801                                           |
---------------------------------------------------------------------------------------------------------------------------
|  --p, --pos                  |  --affected, --target and --fixed all at once                                            |
---------------------------------------------------------------------------------------------------------------------------
|  --a, --affected             |  searches for the jira by the affected pos version                                       |
---------------------------------------------------------------------------------------------------------------------------
|  --t, --target               |  searches for the jira by target version (version where R&D is trying to fix the issue)  |                     
---------------------------------------------------------------------------------------------------------------------------
|  --f, --fixed                |  searches for the jira by fixed version (version where R&D says the issue is resolved)   |
---------------------------------------------------------------------------------------------------------------------------
|  --h, --?, --help            |  displays this screen                                                                    |
---------------------------------------------------------------------------------------------------------------------------
"
   exit 1
} ##end of help_screen function

for OPTIONS in $*; do
  case $OPTIONS in
    --h|--help|--\?)
    help_screen
    ;;
  esac
done

if [[ -z $* ]]; then
  help_screen
fi

## SETTING UP FLAGS FOR THE OPTIONS

  DESC_FLAG=false
  NAME_FLAG=false
  POS_FLAG=false
  AFFECTED_FLAG=false
  TARGET_FLAG=false
  FIXED_FLAG=false

## SETTING UP COUNTS FOR THE OPTIONS

  DESC_COUNT=0
  NAME_COUNT=0
  POS_COUNT=0
  AFFECTED_COUNT=0
  TARGET_COUNT=0
  FIXED_COUNT=0

## SETTING UP THE DATA ARRAYS

  DESC_DATA=()
  NAME_DATA=()
  POS_DATA=()
  AFFECTED_DATA=()
  TARGET_DATA=()
  FIXED_DATA=()

## adding each argument into an array to be called on later
ARGS=()
ELEMENT=0
for ARGUMENTS in $*; do
  ARGS+=($ARGUMENTS)
done


#set -x

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
      #echo "data array ${DATA_ARRAY[@]}"
    done

## storing the data from the DATA_ARRAY into individual arrays, based on the flag submitted by the user
  case $STUFF in
    --d|--desc|--description)
      DESC_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        DESC_DATA+=($DATA)
        DESC_COUNT=$((DESC_COUNT+1))
      done
      ;;
    --n|--name)
      NAME_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        NAME_DATA+=($DATA)
        NAME_COUNT=$((NAME_COUNT+1))
      done
      ;;
      --p|--pos)
        POS_FLAG=true
        for DATA in ${DATA_ARRAY[@]}; do
          POS_DATA+=($DATA)
          POS_COUNT=$((POS_COUNT+1))
        done
        ;;
    --a|--affected)
      AFFECTED_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        AFFECTED_DATA+=($DATA)
        AFFECTED_COUNT=$((AFFECTED_COUNT+1))
      done
      ;;
    --t|--target)
      TARGET_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        TARGET_DATA+=($DATA)
        TARGET_COUNT=$((TARGET_COUNT+1))
      done
      ;;
    --f|--fixed)
      FIXED_FLAG=true
      for DATA in ${DATA_ARRAY[@]}; do
        FIXED_DATA+=($DATA)
        FIXED_COUNT=$((FIXED_COUNT+1))
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
COUNT=$((DESC_COUNT+NAME_COUNT+POS_COUNT+AFFECTED_COUNT+TARGET_COUNT+FIXED_COUNT))
CLAUSE=''

if [[ $DESC_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for DESCRIPTION in ${DESC_DATA[@]}; do
    if [[ $DESC_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE description like '%$DESCRIPTION%' and"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE description like '%$DESCRIPTION%')"
      else
        CLAUSE="$CLAUSE description like '%$DESCRIPTION%') and"
      fi
    fi
    DESC_COUNT=$((DESC_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $NAME_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for NAME in ${NAME_DATA[@]}; do
    if [[ $NAME_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE name like '%$NAME%' and"
    else
      if [[ $COUNT -gt 1 ]]; then
        CLAUSE="$CLAUSE name like '%$NAME%') and"
      else
        CLAUSE="$CLAUSE name like '%$NAME%')"
      fi
    fi
  NAME_COUNT=$((NAME_COUNT-1))
  COUNT=$((COUNT-1))
  done
fi

if [[ $POS_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for POS in `echo ${POS_DATA[@]}`; do
    if [[ $POS_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE affects_version like '%$POS%' or target_version like '%$POS%' or fix_version like '%$POS%' or"
    else
      if [[ COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE affects_version like '%$POS%' or target_version like '%$POS%' or fix_version like '%$POS%')"
      else
        CLAUSE="$CLAUSE affects_version like '%$POS%' or target_version like '%$POS%' or fix_version like '%$POS%') and"
      fi
    fi
    POS_COUNT=$((POS_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $AFFECTED_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for AFFECTED in `echo ${AFFECTED_DATA[@]}`; do
    if [[ $DEVICE_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE affects_version like '%$AFFECTED%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE affects_version like '%$AFFECTED%')"
      else
        CLAUSE="$CLAUSE affects_version like '%$DEVICE%') and"
      fi
    fi
      AFFECTED_COUNT=$((AFFECTED_COUNT-1))
      COUNT=$((COUNT-1))
    done
fi

if [[ $TARGET_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for TARGET in `echo ${TARGET_DATA[@]}`; do
    if [[ $TARGET_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE target_version like '%$TARGET%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE target_version like '%$TARGET%')"
      else
        CLAUSE="$CLAUSE target_version like '%$TARGET%') and"
      fi
    fi
    TARGET_COUNT=$((TARGET_COUNT-1))
    COUNT=$((COUNT-1))
  done
fi

if [[ $FIXED_FLAG == 'true' ]]; then
  CLAUSE="$CLAUSE ("
  for FIXED in `echo ${FIXED_DATA[@]}`; do
    if [[ $FIXED_COUNT -gt 1 ]]; then
      CLAUSE="$CLAUSE fix_version like '%$FIXED%' or"
    else
      if [[ $COUNT -eq 1 ]]; then
        CLAUSE="$CLAUSE fix_version like '%$FIXED%')"
      else
        CLAUSE="$CLAUSE fix_version like '%$FIXED%') and"
      fi
    fi
  FIXED_COUNT=$((FIXED_COUNT-1))
  COUNT=$((COUNT-1))
  done
fi

sqlite3 jira.db -header -column "select name, status, affects_version, target_version, fix_version, description from jira where $CLAUSE order by length(description) desc"
