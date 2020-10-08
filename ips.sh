IPS=$*
for IPS; do

LOGO=$(echo $IPS | tr -d '[:digit:][:space:]')
STORE_NUMBER=$(echo $IPS | tr -d '[:alpha:][:space:]')

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

RVPN='/home/mrbrown/files/public/mrbrown/rvpn'

echo -e "\n-ips for $IPS\n"

echo "-------------------------------------------------------------------------------------------------------"
printf "|%-15s |%-15s |%-15s |%-15s |%-15s |%-15s |\n" POS DMB DTD CHEF KIOSK OCU
echo "-------------------------------------------------------------------------------------------------------"


POS=$(sqlite3 $RVPN/rvpn.db "select term_rvpn from $TABLE where store_number = $STORE_NUMBER")

if [ "$POS" = "" ]; then
  POS=$(getent hosts $IPS.penguinpos.com | awk '{print $1}')
  if [ "$POS" = "" ]; then
    POS="none"
  fi
fi


DMB=$(sqlite3 $RVPN/rvpn.db "select dmb_rvpn from $TABLE where store_number = $STORE_NUMBER")

if [ "$DMB" = "" ]; then
  DMB=$(getent hosts $IPSdmb.penguinpos.com | awk '{print $1}')
  if [ "$DMB" = "" ]; then
    DMB="none"
  fi
fi

DTD=$(sqlite3 $RVPN/rvpn.db "select dtd_rvpn from $TABLE where store_number = $STORE_NUMBER")

if [ "$DTD" = "" ]; then
  DTD=$(getent hosts $IPSdtd.penguinpos.com | awk '{print $1}')
  if [ "$DTD" = "" ]; then
    DTD="none"
  fi
fi

CHEF=$(sqlite3 $RVPN/rvpn.db "select chef_rvpn from $TABLE where store_number = $STORE_NUMBER")

if [ "$CHEF" = "" ]; then
  CHEF=$(getent hosts $IPSchef.penguinpos.com | awk '{print $1}')
  if [ "$CHEF" = "" ]; then
    CHEF="none"
  fi
fi

KIOSK=$(sqlite3 $RVPN/rvpn.db "select kiosk_rvpn from $TABLE where store_number = $STORE_NUMBER")

if [ "$KIOSK" = "" ]; then
  KIOSK=$(getent hosts $IPSkiosk.penguinpos.com | awk '{print $1}')
  if [ "$KIOSK" = "" ]; then
    KIOSK="none"
  fi
fi

OCU=$(getent hosts $IPSocu.penguinpos.com | awk '{print $1}')
OCU=$(sqlite3 $RVPN/rvpn.db "select ocu_rvpn from $TABLE where store_number = $STORE_NUMBER")

if [ "$OCU" = "" ]; then
  OCU=$(getent hosts $IPSocu.penguinpos.com | awk '{print $1}')
  if [ "$OCU" = "" ]; then
    OCU="none"
  fi
fi

printf "|%-15s |%-15s |%-15s |%-15s |%-15s |%-15s |\n" $POS $DMB $DTD $CHEF $KIOSK $OCU
echo -e "-------------------------------------------------------------------------------------------------------\n"
done
