#!/bin/bash

rvpn="10.[7-9].*.*"
NUMBERS='^[0-9]+$'
NUMBERS_CHECK=$(echo $1 | cut -c 1)
LOGO=$(echo $1 | tr -d '[:digit:][:space:]')
STORE_NUMBER=$(echo $1 | tr -d '[:alpha:][:space:]')
RVPN='/home/mrbrown/files/public/mrbrown/rvpn'

if [ "$LOGO" = 'bk' ]; then
  TABLE='bk_rvpn'
elif [ "$LOGO" = 'pop' ]; then
  TABLE='pop_rvpn'
elif [ $LOGO = 'arb' ]; then
  TABLE='arbys_rvpn'
elif [ $LOGO = 'jac' ]; then
  TABLE='jacks_rvpn'
elif [ "$LOGO" = 'bo' ]; then
  TABLE='boj_rvpn'
elif [ "$LOGO" = 'th' ]; then
  TABLE='th_rvpn'
  STORE_NUMBER=$(printf "1%05d" $STORE_NUMBER)
fi

HOOK=$(echo $1)

if [[ $NUMBERS_CHECK =~ $NUMBERS ]]; then
  TYPE='rvpn'
  RVPN_CHECK=$(sqlite3 $RVPN/rvpn.db "select store_number from th_rvpn where term_rvpn = '$1'")
  if ! [[ -z $RVPN_CHECK ]]; then
    LOGO='th'
  fi
  HOOK=$(echo $1)
elif [[ $HOOK = $rvpn ]]; then
  HOOK=$(echo $1)
else
  TYPE='non-rvpn'
  HOOK=$(echo $1.penguinpos.com)
fi

for i in "$HOOK"
do

 if [[ $TYPE == 'non-rvpn' ]]; then
  IP=$(sqlite3 $RVPN/rvpn.db "select term_rvpn from $TABLE where store_number = '$STORE_NUMBER'")
 fi

 if [[ $IP == 'N/A' ]]; then
    IP=$(getent hosts $HOOK | awk '{printf $1}')
 fi

if [[ $LOGO == 'th' ]]; then
  if [[ $HOOK = $rvpn ]]; then
     sscp /home/mrbrown/files/private/mrbrown/scripts/TERMconnectOS3.tgz $HOOK:/tmp/
     ssshr_sicom_mrbrown_termOS3 $HOOK
  elif [[ $IP = $rvpn ]]; then
    sscp /home/mrbrown/files/private/mrbrown/scripts/TERMconnectOS3.tgz $IP:/tmp/
    ssshr_sicom_mrbrown_termOS3 $IP
  else
    sopenvpn $HOOK
    sscp /home/mrbrown/files/private/mrbrown/scripts/TERMconnectOS3.tgz t0:/tmp/
    ssshr_sicom_mrbrown_termOS3
  fi

else
  if [[ $HOOK = $rvpn ]]; then
	   sscp /home/mrbrown/files/private/mrbrown/scripts/TERMconnect.tgz $HOOK:/tmp/
	   ssshr_sicom_mrbrown_term $HOOK
  elif [[ $IP = $rvpn ]]; then
		sscp /home/mrbrown/files/private/mrbrown/scripts/TERMconnect.tgz $IP:/tmp/
		ssshr_sicom_mrbrown_term $IP
  elif [[ $(cat /home/mrbrown/files/private/mrbrown/lab/lab_state) == 'os3' ]] && [[ $1 == '10.60.159.245' ]]; then
    sscp /home/mrbrown/files/private/mrbrown/scripts/TERMconnectOS3.tgz $IP:/tmp/
    ssshr_sicom_mrbrown_termOS3 $IP
  else
		sopenvpn $HOOK
    sscp /home/mrbrown/files/private/mrbrown/scripts/TERMconnect.tgz t0:/tmp/
	  ssshr_sicom_mrbrown_term
  fi
fi
done
