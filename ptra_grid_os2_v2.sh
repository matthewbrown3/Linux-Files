### created by mrb on 6/5/2020

### put all columns into functions
### changed TERMINAL variable to ID
### changed TERM variable to TERMINAL
### changed a bunch of if statements to case statements
### added mobile column
### fixed issue where PTRA ARRAY tests the wrong printer

ptra_grid_os2_v2(){

format(){
echo;
echo -n "---------------------------------------------------------------------------------------------------------------------------------------";
for FORMAT in ${PTRA[@]};
do
  echo -n "-----------";
done;
echo;
};

function hardware(){
  ######  HARDWARE  ######

  HARDWARE3=$(grep $ID -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | sed 's/://g; s/;//g; s/\(.*\)/\L\1/g' | cut -c 7-9);
  HARDWARE8=$(grep $ID -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | cut -c 1-8 | sed 's/\(.*\)/\L\1/g');
  HARDWARE11=$(grep $ID -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | cut -c 1-11 | sed 's/\(.*\)/\L\1/g');
  HARDWARE=""

  case $TERMINAL in
    4[0-9])
      HARDWARE='tablet';
    ;;
    5[0-9])
      HARDWARE='kiosk'
    ;;
  esac

  case $HARDWARE8 in
    00:0c:d6)
     HARDWARE='sl_20';
    ;;
    00:60:ef)
      HARDWARE='sl_21b';
    ;;
  esac

  case $HARDWARE11 in
    00:05:0b:a0)
      HARDWARE='sl_20';
    ;;
    00:05:0b:b0)
      HARDWARE='sl_21';
    ;;
    00:a0:a4:10)
      HARDWARE='micros_2010';
    ;;
    00:a0:a4:13)
      HARDWARE='micros_5';
    ;;
    00:a0:a4:15)
      HARDWARE='micros_4lx';
    ;;
    00:a0:a4:17)
      HARDWARE='micros_5a';
    ;;
  esac

  case $HARDWARE3 in
    4[0-9][7-9])
      HARDWARE='sl_19';
    ;;
    40[0-6])
      HARDWARE='sl_18';
    ;;
  esac

   if [[ -z $HARDWARE ]]; then
    HARDWARE='new_hw?';
  fi;
};## end of hardware function

function setup(){
#####  SET UP  #####

  SQL_TERM=$(mysql mgrng -sNe "select drive_thru_mode from terminal_pos_options where terminal_number = $TERMINAL");

  case $SQL_TERM in
    0)
      SETUP='normal_fc';
    ;;
    1)
      SETUP='dt_ot';
    ;;
    2)
      SETUP='dt_cash';
    ;;
    3)
      SETUP='dt_any';
    ;;
    4)
      SETUP='fc_ot';
    ;;
    5)
      SETUP='fc_cash';
    ;;
    6)
      SETUP='deliv';
    ;;
  esac
};## end of setup function

function auto_print(){

  AUTO_PRINT=$(mysql mgrng -sNe "SELECT automatic_receipt_printing FROM terminal_pos_options WHERE terminal_number = '$TERMINAL'");

  case $AUTO_PRINT in
    0)
      AUTO_PRINT='off';
    ;;
    1)
      AUTO_PRINT='on';
    ;;
    *)
      AUTO_PRINT='AUTO?'
    ;;
  esac
};## end of auto_print function

function default(){
  DEFAULT=$(mysql mgrng -sNe "SELECT default_printer_location FROM terminal_pos_options WHERE terminal_number = '$TERMINAL'");

  if [[ -z $DEFAULT ]]; then
    DEFAULT='none';
  fi;
}; ##end of default function

function customer(){
  #### Variables necessary for customer receipt ####
  CUSTOMER_RECEIPT_PATH=$(mysql mgrng -sNe "SELECT additional_routing_number FROM terminal_pos_options WHERE terminal_number = '$TERMINAL'");
  TERMINAL_1=$(echo $TERMINAL | sed 's/^0//');
  ROUTING_PATH_UID_1=$( echo "$(( $TERMINAL_1 * 20 + $CUSTOMER_RECEIPT_PATH ))");
  CUSTOMER_RECEIPT=$(mysql mgrng -sNe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 2 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

  if [[ -z $CUSTOMER_RECEIPT ]]; then
    CUSTOMER_RECEIPT='none';
  fi;
};## end of customer function

function expo_reg(){
  #### Variables for all expo types ####

  EXPO_REG=$(mysql mgrng -sNe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 5 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

  if [[ -z $EXPO_REG ]]; then
    EXPO_REG='none';
  fi;
};## end of expo_reg

function expo_bold(){

  EXPO_BOLD=$(mysql mgrng -sNe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 4 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

  if [[ -z $EXPO_BOLD ]]; then
          EXPO_BOLD='none';
  fi;
};## end of expo_bold function

function expo_group() {

  EXPO_GROUP=$(mysql mgrng -sNe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 6 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

  if [[ -z $EXPO_GROUP ]]; then
    EXPO_GROUP='none';
  fi;
};## end of expo_group function

function cc_receipt() {
  #### Variables necessary for CC receipts ####
  CC_RECEIPT_PATH=$(mysql mgrng -sNe "SELECT cc_receipt_routing_number FROM terminal_pos_options WHERE terminal_number = '$TERMINAL'");
  ROUTING_PATH_UID_2=$( echo "$(( $TERMINAL_1 * 20 + $CC_RECEIPT_PATH ))");
  CC_RECEIPT=$(mysql mgrng -sNe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 2 AND routing_paths_uid = '$ROUTING_PATH_UID_2'");

  if [[ -z $CC_RECEIPT ]]; then
    CC_RECEIPT='none';
  fi;
};## end of cc_receipt function

function dt_receipt() {

  #### Variables necessary for addtional DT receipt when paid ####
  DT_RECEIPT_PATH=$(mysql mgrng -sNe "SELECT additional_dt_routing_number FROM terminal_pos_options WHERE terminal_number = '$TERMINAL'");
  ROUTING_PATH_UID_3=$( echo "$(( $TERMINAL_1 * 20 + $DT_RECEIPT_PATH ))");
  DT_RECEIPT=$(mysql mgrng -sNe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 2 AND routing_paths_uid = '$ROUTING_PATH_UID_3'");

  if [[ -z $DT_RECEIPT ]]; then
    DT_RECEIPT='none';
  fi;
};## end of dt_receipt function

function order_number() {
  #Order number receipt
  NUM_RECEIPT=$(mysql mgrng -sNe "SELECT location FROM routing_devices WHERE routing_device_types_uid = 2 AND routing_items_uid = 3 AND routing_paths_uid = '$ROUTING_PATH_UID_1'");

  if [[ -z $NUM_RECEIPT ]]; then
    NUM_RECEIPT='none';
  fi;
};## end of order_number function

function mobile(){
  ### mobile receipts

  MOBILE_PATH=$(mysql mgrng -sNe "select mobile_routing_number from terminal_pos_options where terminal_number = $TERMINAL")
  ROUTING_PATH_UID_4=$(echo "$ID * 20 + $MOBILE_PATH" | bc)
  MOBILE_RECEIPT_NUMBER=$(mysql mgrng -sNe "select location from routing_devices where routing_paths_uid = $ROUTING_PATH_UID_4 and routing_device_types_uid = 2")
  MOBILE_RECEIPT_TYPE=$(mysql mgrng -sNe "select routing_items_uid from routing_devices where routing_paths_uid = $ROUTING_PATH_UID_4 and routing_device_types_uid = 2")

  case $MOBILE_RECEIPT_TYPE in
    2)
      MOBILE_RECEIPT_TYPE='cust';
    ;;
    3)
      MOBILE_RECEIPT_TYPE='ord';
    ;;
    4)
      MOBILE_RECEIPT_TYPE='xbld';
    ;;
    5)
      MOBILE_RECEIPT_TYPE='xreg';
    ;;
    6)
      MOBILE_RECEIPT_TYPE='xgrp'
    ;;
    12)
      MOBILE_RECEIPT_TYPE='xgrl'
    ;;
  esac

  MOBILE_RECEIPT=$(echo "$MOBILE_RECEIPT_NUMBER $MOBILE_RECEIPT_TYPE" | tr ' ' '_')

  if [[ -z $MOBILE_RECEIPT_NUMBER ]]; then
    MOBILE_RECEIPT="none"
  fi
};## end of mobile function

function filter(){
  ping -c 1 -W 5 $ID &>/dev/null;
  ONLINE=$?;

  if [ $ONLINE -ne 0 ];
  then
    for PTRA in ${PTRA[@]};
    do
      FILTER=();

      if [[ $TERMINAL -gt 30 ]]; then
        FILTER+=(`echo n/a`);
      else
       FILTER+=(`echo offline?`);
      fi;

    printf "%-9s |" ${FILTER[@]};

    done;
  else
    for PTRA in ${PTRA[@]};
    do

      echo "
        CHECK=\$(grep '$PTRA -w' /etc/printcap | tail -n 1 | awk '{print \$1}' | sed 's_:if=/var/spool/slpd/__g' | sed 's/filter//g');
        if [ -z \$CHECK ]; then CHECK='MISSING?'; fi;
        echo \$CHECK" > /tmp/filter;
      chmod 755 /tmp/filter;

      PTRA_HW=$(grep -A2 $PTRA /etc/dhcpd.conf | grep hardware | awk '{print$3}' | sed 's/;//g; s/://g; s/\(.*\)/\L\1/g' | cut -c 1-6);

  FILTER=();

      if [[ $TERMINAL -gt 30 ]]; then
        FILTER+=(`echo n/a`);
      else
        TEST=$(/sbin/rsrunner $ID /tmp/filter 2>/dev/null | grep -v STDOUT);
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
};## end of filter function

PTRA=();
PTRA+=(`grep 'host ptra' /etc/dhcpd.conf | awk '{print \$2}' | sort -u`);

format;

printf "|%-8s |%-11s |%-9s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |" Term Term\ Hw Setup Auto Default Customer ExpoReg ExpoBold ExpoGrp CC\ Rcpt DT\ Rcpt Order\ \# Mobile; printf "%-9s |" ${PTRA[@]} | sed -e "s/\b\(.\)/\u\1/g";

format;

for TERMINAL in `(grep "host term" /etc/dhcpd.conf | awk '{print $2}' | sed 's/term0//g'; mysql mgrng -sNe "select terminal_number from terminal_pos_options where kiosk = 1 and terminal_number != 0; select terminal_number from terminal_pos_options where is_subtotal_override_enabled = 1 and terminal_number != 0" 2>/dev/null) | sort -u`; do

  PTRA=();
  PTRA+=(`grep 'host ptra' /etc/dhcpd.conf | awk '{print \$2}' | sort -u`);
  ID=$(echo -n term; printf "%03d" "$TERMINAL");

  hardware
  setup
  auto_print
  default
  customer
  expo_reg
  expo_bold
  expo_group
  cc_receipt
  dt_receipt
  order_number
  mobile

  printf "|%-8s |%-11s |%-9s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |%-8s |" $ID $HARDWARE $SETUP $AUTO_PRINT $DEFAULT $CUSTOMER_RECEIPT $EXPO_REG $EXPO_BOLD $EXPO_GROUP $CC_RECEIPT $DT_RECEIPT $NUM_RECEIPT $MOBILE_RECEIPT | sed 's/_/ /g';

  filter;

  format;

done;

rm /tmp/filter 2>/dev/null;

echo;
};
ptra_grid_os2_v2
