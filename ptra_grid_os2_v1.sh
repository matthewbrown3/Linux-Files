
ptra_grid_os2_v1(){

format.func(){
echo "";
echo -n "-----------------------------------------------------------------------------------------------------------------------------";
for FORMAT in `echo ${PTRA[@]}`;
do
  echo -n "-----------";
done;
echo "";
};

PTRA=();
PTRA+=(`grep 'host ptra' /etc/dhcpd.conf | awk '{print \$2}' | sort -u`);

format.func;

printf "|%-8s |%-11s |%-9s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |" Term Term\ Hw Setup Auto Default Customer ExpoReg ExpoBold ExpoGrp CC\ Rcpt DT\ Rcpt Order\ \#; printf "%-9s |" ${PTRA[@]} | sed -e "s/\b\(.\)/\u\1/g";

format.func;

for TERM in `(grep "host term" /etc/dhcpd.conf | awk '{print $2}' | sed 's/term0//g'; mysql mgrng -sBe "select terminal_number from terminal_pos_options where kiosk = 1 and terminal_number != 0; select terminal_number from terminal_pos_options where is_subtotal_override_enabled = 1 and terminal_number != 0" 2>/dev/null) | sort -u`; do

  TERMINAL=$(echo -n term; printf "%03d" "$TERM");

######  HARDWARE  ######

HARDWARE3=$(grep $TERMINAL -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | sed 's/://g; s/;//g; s/\(.*\)/\L\1/g' | cut -c 7-9);
HARDWARE8=$(grep $TERMINAL -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | cut -c 1-8 | sed 's/\(.*\)/\L\1/g');
HARDWARE11=$(grep $TERMINAL -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | cut -c 1-11 | sed 's/\(.*\)/\L\1/g');

if [ "$TERM" -ge 40 -a "$TERM" -le 49 ]; then
   HARDWARE='tablet';
 elif [ "$TERM" -ge 50 -a "$TERM" -le 59 ]; then
   HARDWARE='kiosk';
 elif [ "$HARDWARE8" == '00:0c:d6' ]; then
   HARDWARE='sl_20';
 elif [ "$HARDWARE8" == '00:60:ef' ]; then
   HARDWARE='sl_21b';
 elif [ "$HARDWARE11" == '00:05:0b:a0' ]; then
   HARDWARE='sl_20';
 elif [ "$HARDWARE11" == '00:05:0b:b0' ]; then
   HARDWARE='sl_21';
 elif [ "$HARDWARE11" == '00:a0:a4:10' ]; then
   HARDWARE='micros_2010';
 elif [ "$HARDWARE11" == '00:a0:a4:13' ]; then
   HARDWARE='micros_5';
 elif [ "$HARDWARE11" == '00:a0:a4:15' ]; then
   HARDWARE='micros_4lx';
 elif [ "$HARDWARE11" == '00:a0:a4:17' ]; then
   HARDWARE='micros_5a';
 elif [[ $HARDWARE3 -ge 407 ]]; then
  HARDWARE='sl_19';
 elif [[ $HARDWARE3 -le 406 ]]; then
   HARDWARE='sl_18';
 else
  HARDWARE='new_hw?';
fi;


#####  SET UP  #####

  SQL_TERM=$(mysql mgrng -sBe "select drive_thru_mode from terminal_pos_options where terminal_number = $TERM");

  if [ "$SQL_TERM" = "0" ]; then
    SETUP='normal_fc';
  elif [ "$SQL_TERM" = "1" ]; then
    SETUP='dt_ot';
  elif [ "$SQL_TERM" = "2" ]; then
    SETUP='dt_cash';
  elif [ "$SQL_TERM" = "3" ]; then
    SETUP='dt_any';
  elif [ "$SQL_TERM" = "4" ]; then
    SETUP='fc_ot';
  elif [ "$SQL_TERM" = "5" ]; then
    SETUP='fc_cash';
  elif [ "$SQL_TERM" = "6" ]; then
    SETUP='deliv';
  fi;

AUTO_PRINT=$(mysql mgrng -sBe "SELECT automatic_receipt_printing FROM terminal_pos_options WHERE terminal_number = '$TERM'");

if [[ $AUTO_PRINT -eq 0 ]]; then
AUTO_PRINT='off';
elif [[ $AUTO_PRINT -eq 1 ]]; then
AUTO_PRINT='on';
fi;

DEFAULT=$(mysql mgrng -sBe "SELECT default_printer_location FROM terminal_pos_options WHERE terminal_number = '$TERM'");

if [[ -z $DEFAULT ]]; then
        DEFAULT='none';
fi;

#### Variables necessary for customer receipt ####
CUSTOMER_RECEIPT_PATH=$(mysql mgrng -sBe "SELECT additional_routing_number FROM terminal_pos_options WHERE terminal_number = '$TERM'");
TERMINAL_1=$(echo $TERM | sed 's/^0//');
ROUTING_PATH_UID_1=$( echo "$(( $TERMINAL_1 * 20 + $CUSTOMER_RECEIPT_PATH ))");
CUSTOMER_RECEIPT=$(mysql mgrng -sBe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 2 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

if [[ -z $CUSTOMER_RECEIPT ]]; then
        CUSTOMER_RECEIPT='none';
fi;

#### Variables for all expo types ####

EXPO_REG=$(mysql mgrng -sBe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 5 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

if [[ -z $EXPO_REG ]]; then
        EXPO_REG='none';
fi;

EXPO_BOLD=$(mysql mgrng -sBe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 4 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

if [[ -z $EXPO_BOLD ]]; then
        EXPO_BOLD='none';
fi;

EXPO_GROUP=$(mysql mgrng -sBe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 6 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

if [[ -z $EXPO_GROUP ]]; then
        EXPO_GROUP='none';
fi;

#### Variables necessary for CC receipts ####
CC_RECEIPT_PATH=$(mysql mgrng -B -s -e "SELECT cc_receipt_routing_number FROM terminal_pos_options WHERE terminal_number = '$TERM'");
ROUTING_PATH_UID_2=$( echo "$(( $TERMINAL_1 * 20 + $CC_RECEIPT_PATH ))");
CC_RECEIPT=$(mysql mgrng -sBe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 2 AND routing_paths_uid = '$ROUTING_PATH_UID_2'");

if [[ -z $CC_RECEIPT ]]; then
CC_RECEIPT='none';
fi;

#### Variables necessary for addtional DT receipt when paid ####
DT_RECEIPT_PATH=$(mysql mgrng -sBe "SELECT additional_dt_routing_number FROM terminal_pos_options WHERE terminal_number = '$TERM'");
ROUTING_PATH_UID_3=$( echo "$(( $TERMINAL_1 * 20 + $DT_RECEIPT_PATH ))");
DT_RECEIPT=$(mysql mgrng -sBe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 2 AND routing_paths_uid = '$ROUTING_PATH_UID_3'");

if [[ -z $DT_RECEIPT ]]; then
        DT_RECEIPT='none';
fi;

#Order number receipt
NUM_RECEIPT=$(mysql mgrng -sBe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 3 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

if [[ -z $NUM_RECEIPT ]]; then
        NUM_RECEIPT='none';
fi;

printf "|%-8s |%-11s |%-9s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |" $TERMINAL $HARDWARE $SETUP $AUTO_PRINT $DEFAULT $CUSTOMER_RECEIPT $EXPO_REG $EXPO_BOLD $EXPO_GROUP $CC_RECEIPT $DT_RECEIPT $NUM_RECEIPT | sed 's/_/ /g';

  ping -c 1 -W 5 $TERMINAL &>/dev/null;
  ONLINE=$?;

  if [ $ONLINE -ne 0 ];
  then
    for PTRA in `echo ${PTRA[@]}`;
    do
      FILTER=();

      if [[ $TERM -gt 30 ]]; then
        FILTER+=(`echo n/a`);
      else
       FILTER+=(`echo offline?`);
      fi;

    printf "%-9s |" ${FILTER[@]};

    done;
  else
    for PTRA in `echo ${PTRA[@]}`;
    do

      echo "
        CHECK=\$(grep '$PTRA -w' /etc/printcap | tail -n 1 | awk '{print \$1}' | sed 's_:if=/var/spool/slpd/__g' | sed 's/filter//g');
        if [ -z \$CHECK ]; then CHECK='MISSING?'; fi;
        echo \$CHECK" > /tmp/filter;
      chmod 755 /tmp/filter;

      PTRA_HW=$(grep -A2 $PTRA /etc/dhcpd.conf | grep hardware | awk '{print$3}' | sed 's/;//g; s/://g; s/\(.*\)/\L\1/g' | cut -c 1-6);

  FILTER=();

      if [[ $TERM -gt 30 ]]; then
        FILTER+=(`echo n/a`);
      else
        TEST=$(/sbin/rsrunner $TERMINAL /tmp/filter 2>/dev/null | grep -v STDOUT);
if [[ "$TEST" == 'MISSING?' ]]; then
  FILTER+=(`echo MISSING?`);
  elif [[ $PTRA_HW == "00e070" ]] && [[ $TEST == "axiohm" ]] || [[ $PTRA_HW == '00d069' ]] && [[ $TEST == 'axiohm' ]];then
          FILTER+=("$TEST");
        elif [[ $PTRA_HW != "00e070" ]] && [[ $TEST = "epson" ]] || [[ $TEST = "epson44" ]];then
          FILTER+=("$TEST");
        else
          FILTER=(`echo BAD_FLTR?`);
        fi;
     fi;

   printf "%-9s |" "${FILTER[@]}" | sed 's/_/ /g';

   done;
  fi;

format.func;

done;

rm /tmp/filter 2>/dev/null;

echo "";
};
