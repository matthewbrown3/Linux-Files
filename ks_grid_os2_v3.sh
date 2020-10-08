ks_grid_os2_v3(){

##turned off the screen type and ors config functions
##added the auto serve check

function file_maker(){

  #####  CREATING ECHO FILES TO BE USED FOR RSRUNNER  #####


cat << EOF > /tmp/ks_v
#!/usr/bin/expect -f
set timeout 10
set KS [ lindex \$argv 0 ]
set PASS [ lindex \$argv 1 ]
spawn ssh sicom@\$KS /usr/sbin/kscreencontroller -v 2> /dev/null;
expect "Are you sure you want to continue connecting (yes/no)? " { send "yes\r" };
expect "Please type 'yes' or 'no':" { send "yes\r" };
expect "password:" { send "\$PASS\n" };
expect "\\ #";
exit;
EOF


cat << EOF > /tmp/ks_dmb_v
#!/usr/bin/expect -f
set KS [ lindex \$argv 0 ]
set PASS [ lindex \$argv 1 ]
set timeout 10
spawn ssh user013@\$KS cat /etc/sicom-kds-version | grep KDS;
expect "Are you sure you want to continue connecting (yes/no)? " { send "yes\r" };
expect "Please type 'yes' or 'no':" { send "yes\r" };
expect "assword:\$";
send "\$DAILY)\r";
expect "\\ #";
exit
EOF

cat << EOF > /tmp/ksd
POS=\$(su sicom -c "/home/sicom/pos/pos -v" | awk '{print \$2}' | cut -c 1-4 | sed 's/\.//g');

STATUS=\$(/etc/rc.d/init.d/sicdkscreend status | awk '{print \$3}');

if [ "\$STATUS" == 'stopped' ] && [[ \$POS -eq 506 || \$POS -ge 600 ]]; then
  echo 'stopped';
elif [ "\$STATUS" != 'stopped' ] && [[ \$POS -eq 506 || \$POS -ge 600 ]]; then
  echo 'STARTED!';
elif [ "\$STATUS" == 'stopped' ] && [[ \$POS -le 505 || \$POS -ge 527 && \$POS -le 528 ]]; then
  echo 'STOPPED!';
else
  echo 'running';
fi;
EOF

cat << EOF > /tmp/dtd_json

if [ -e /var/sicom/DTD_JSON.DAT ]; then
  DTD_JSON=\$(md5sum /var/sicom/DTD_JSON.DAT | awk '{print \$1}' | cut -c 29-32);
else
  DTD_JSON='no_.dat';
fi;
echo \$DTD_JSON
EOF

cat << EOF > /tmp/dtd_json_time

if [ -e /var/sicom/DTD_JSON.DAT ]; then
  DTD_JSON_TIME=\$(ls -alh /var/sicom/DTD_JSON.DAT | awk '{print \$6, \$7, \$8}');
else
  DTD_JSON_TIME='n/a';
fi;
echo \$DTD_JSON_TIME
EOF

chmod 755 /tmp/ks_v /tmp/ks_dmb_v /tmp/ksd /tmp/dtd_json /tmp/dtd_json_time;
}; ## end of file_maker function

function name(){
#####  GETTING THE NAMES OF THE KITCHEN SCREENS  ######

  NAME=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -vi DHCP | awk 'BEGIN {FS="NAME="} {print$2}' | cut -d' ' -f1 | sed 's/\(.*\)/\L\1/g');

  if [[ -z $NAME ]]; then
    NAME=$(grep -i $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -vi DHCP | grep -ic clock);
    if [[ $NAME -eq 1 ]]; then
      NAME='clock';
    else
      NAME='KS_NODES???';
    fi;
  fi;
};## end of name function

function config(){
  #####  ESTABLISHING THE SCREEN CONFIGS  #####

  CONFIG_TYPE=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -vi DHCP | grep "\*");

  if [ "$NAME" == "KS_NODES???" ]; then
    CONFIG_TYPE='KS_NODES???';
  elif [ "$NAME" == "clock" ]; then
    CONFIG_TYPE='clock';
  elif [[ -z $CONFIG_TYPE ]]; then
    CONFIG_TYPE="order";
  else
    CONFIG_TYPE="item";
  fi;
};## end of config function

function screen_type(){
  #####  ESTABLISHING THE SCREEN TYPES  #####

  SCREEN_TYPE=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -iv DHCP | awk 'BEGIN {FS="TYPE="} {print$2}' | cut -d' ' -f1 | sed 's/\(.*\)/\L\1/g');

  if [[ -z $SCREEN_TYPE || $SCREEN_TYPE='' ]]; then
    SCREEN_TYPE='n/a';
  fi;
};## end of screen_type function

function ctrl_term(){

  #####  DETERMINING THE CONTROLLING TERMINAL(S)  #####

  CTRL_TERM=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | head -n 1 | awk '{print $1}');
  CTRL_TERM=$(echo "term0$CTRL_TERM");
  if [ "$NAME" == "KS_NODES???" ]; then
    CTRL_TERM='KS_NODES???';
  fi;
};## end of ctrl_term function

function hardware() {
  #####  DETERMINING THE HARDWARE  #####
  HARDWARE=""
  case $MAC in

  00:05:0b:60)
    HARDWARE='60_series';
  ;;
  00:05:0b:62|00:05:0b:63|00:05:0b:64|00:05:0b:65)
    HARDWARE='62_series';
  ;;
  00:05:0b:68|00:05:0b:69)
    HARDWARE='clock';
  ;;
  a0:1e:0b)
    HARDWARE='minix';
  ;;
  esac

  case $DMB_MICROS_MAC in
    00:50:f6|44:8e:12|60:c7:98)
      HARDWARE='micros';
    ;;
    00:01:2e)
      HARDWARE='dmb_cntlr';
    ;;
  esac

  if [[ -z $HARDWARE ]]; then
    HARDWARE='new_hw?';
  fi;
};## end of hardware function

function version() {

  #####  GRABBING THE VERSION ON EACH CONTROLLER AND SEEING IF IT'S ONLINE  #####

   if [ -e /tmp/ks_v ] && [ -e /tmp/ks_dmb_v ]; then
    ping -c 1 -W 5 $KS &>/dev/null;
    ONLINE=$?;
    if [ $ONLINE -eq 0 ]; then
        if [ "$HARDWARE" == "62_series" ] || [ "$HARDWARE" == "micros" ]; then
          VERSION=$(/tmp/ks_v $KS $PASS | tail -n 1 | awk '{print $2}' | sed 's/[^0-9]*//g');
        elif [ "$HARDWARE" == "dmb_cntlr" ] || [ "$HARDWARE" == "minix" ]; then
          if [[ -z $DAILY ]]; then
            VERSION='n/a';
          else
            VERSION=$(/tmp/ks_dmb_v | egrep -v "version|password" | awk '{print $3}');
          fi;
        elif [ "$HARDWARE" == "60_series" ] || [ "$HARDWARE" == "clock" ]; then
          VERSION='none';
        else
          VERSION='new_hw?';
        fi;
        if [ -z $VERSION ]; then
          VERSION='n/a';
        elif [ "$HARDWARE" == "62_series" ] && [ $VERSION -lt 150522 ]; then
         VERSION='UPGRADE!';
        elif [ "$HARDWARE" == "micros" ] && [ $VERSION -lt 131031 ]; then
         VERSION='UPGRADE!';
        fi;
     else
      VERSION='offline?';
     fi;
   else
    VERSION='FILES?';
   fi;
}; ## end of version function

function ksd() {
  ######  DETERMINING IF THE KS D IS RUNNING  #####

   KSD=$(/sbin/rsrunner $CTRL_TERM /tmp/ksd 2> /dev/null | grep -v STDOUT);
    if [ "$NAME" == "KS_NODES???" ]; then
      KSD='KSNODES???';
    elif [[ -z $KSD ]]; then
      KSD=$(echo "$CTRL_TERM?");
    fi;
};## end of ksd function

function routing_option() {
  #####  CHECKING THE KITCHEN SCREEN ROUTING OPTION  #####

  if [ -e /home/sicom/posguidata/config/posgui.xml ]; then
    FILE="/home/sicom/posguidata/config/posgui.xml";
  else
    FILE="/home/sicom/posguidata/config/panels.csv";
  fi;

  BK_LOGO=$(grep -i "WHOPPER" $FILE);
  POS_LOG_CHECK=$(ls -al /var/sicom/pos.log | awk '{print$5}');
  if [ "$POS_LOG_CHECK" -le 50000000 ]; then
     ROUTING_OPTION=$(grep "SETTING ROUTING" -i /var/sicom/pos.log | tail -n 1 | awk '{print $9}');
     ROC_CHECK=$(grep -i video\" /home/sicom/posguidata/config/posgui.xml)
     if [ "$BK_LOGO" != "" ] && ! [[ -z $ROC_CHECK ]]; then
       ROC_HELP='1';

       case $ROUTING_OPTION in
        1)
          ROUTING_OPTION="1_video";
        ;;
        2)
          ROUTING_OPTION="2_video";
        ;;
        3)
         ROUTING_OPTION="3_video";
        ;;
        4)
         ROUTING_OPTION="4_video";
        ;;
        5)
          ROUTING_OPTION="all_to_spec";
        ;;
        6)
         ROUTING_OPTION="all_to_main_2";
        ;;
      esac
      if [[ -z $ROUTING_OPTION ]]; then
         ROUTING_OPTION='set_routing';
      fi;
     elif [ "$BK_LOGO" != "" ] && [[ -z $ROC_CHECK ]]; then
       case $ROUTING_OPTION in
        1)
          ROUTING_OPTION="all_to_whp";
        ;;
        2)
          ROUTING_OPTION="whp/spec";
        ;;
        3)
          ROUTING_OPTION="whp/burg/spec";
        ;;
        4)
          ROUTING_OPTION="fc/dt";
        ;;
        5)
          ROUTING_OPTION="all_to_burg";
        ;;
        6)
          ROUTING_OPTION="all_to_spec";
        ;;
      esac
       if [[ -z $ROUTING_OPTION ]]; then
         ROUTING_OPTION='set_routing';
       fi;
     elif [[ -z $BK_LOGO ]]; then
       if [[ -z $ROUTING_OPTION ]]; then
         ROUTING_OPTION='n/a';
       else
         ROUTING_OPTION=$(echo "option:_$ROUTING_OPTION");
       fi;
     else
       ROUTING_OPTION='n/a';
     fi;
  else
     ROUTING_OPTION="BIG_pos.log";
  fi;
};##end of routing_option function

function auto_serve(){
  #####  CHECKING FOR AN AUTO SERVER  #####

  for TERMINAL in `grep 'host term' /etc/dhcpd.conf | awk '{print$2}' | tr -d '[:alpha:]'`; do
    AUTO_SERVE=$(mysql mgrng -sNe "select auto_serve from terminal_pos_options where terminal_number = $TERMINAL")

    if [[ $AUTO_SERVE -eq 1 ]]; then
      AUTO_SERVE_PATH=$(mysql mgrng -sNe "select serve_routing_path from terminal_pos_options where terminal_number = $TERMINAL")
      if [[ $AUTO_SERVE_PATH -ne 0 ]]; then
        ROUTING_PATH_UID=$(echo "$TERMINAL * 20 + $AUTO_SERVE_PATH" | bc)
        TERM_NUM=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | head -n 1 | awk '{print$1}')
        SCREEN_NUMBER=$(grep "$TERM_NUM ks" /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -n $KS | cut -d ':' -f1)
        SCREEN_NUMBER=$((SCREEN_NUMBER+1))
        AUTO_SERVE_PATH_CONFIG=$(mysql mgrng -sNe "select count(*) from routing_devices where routing_paths_uid = $ROUTING_PATH_UID and location = $TERM_NUM and routing_channels_uid = $SCREEN_NUMBER")

        if [[ $AUTO_SERVE_PATH_CONFIG -eq 1 ]]; then
          AUTO_SERVE_FLAG='yes'
        fi
      fi
    fi

    if [[ $AUTO_SERVE_FLAG != 'yes' ]]; then
      AUTO_SERVE_FLAG='no'
    fi
  done
};##end of auto_serve function

function bumpserver() {
  #####  CHECKING FOR A BUMPSERVER  #####

  BUMPSERVER=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -vi DHCP | grep BUMPSERVER);

  if [[ -z $BUMPSERVER ]]; then
   BUMPSERVER='none';
  else
    BUMPSERVER='yes';
  fi;
};##end of bumpserver function

function sortmode() {

  #####  CHECKING FOR SORT MODE  #####

  SORT_MODE=$(grep -i $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -iv DHCP | awk 'BEGIN {FS="SORTMODE="} {print$2}' | cut -d' ' -f1);

  case $SORT_MODE in
    OLDESTNEWEST)
      SORT_MODE='old2new';
    ;;
    NEWESTOLDEST)
      SORT_MODE='new2old';
    ;;
    *)
      SORT_MODE='n/a';
    ;;
  esac
};##end of sortmode function

function beep_config() {
  #####  CHECKING FOR BEEP  #####

  BEEP=$(grep -i $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -iv DHCP | awk 'BEGIN {FS="BEEP="} {print$2}' | cut -d' ' -f1 | sed 's/\(.*\)/\L\1/g');

  if [[ -z $BEEP || $BEEP == '' ]]; then
   BEEP='n/a';
  fi;
};##end of beep_config function

function ors_config(){
  #####  CHECKING FOR AN ORS  #####

  ORS=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -vi DHCP | grep BUMPTLOG);

  if [[ -z $ORS ]]; then
   ORS='none';
  else
    ORS='yes';
  fi;
};##end of ors_config function


function dtd_file() {
  #####  CHECKING THE STATUS AND AGE OF THE DTD_JSON FILE ON THE CONTROLLING TERMINAL(S)  #####

  DTD_JSON=$(/sbin/rsrunner $CTRL_TERM /tmp/dtd_json 2>/dev/null | grep -v STDOUT);
  DTD_JSON_TIME=$(/sbin/rsrunner $CTRL_TERM /tmp/dtd_json_time 2>/dev/null | grep -v STDOUT | sed 's/ /-/g');

  if [[ -z $DTD_JSON ]]; then
    DTD_JSON=$(echo "$CTRL_TERM?");
  fi;

  if [[ -z $DTD_JSON_TIME ]]; then
    DTD_JSON_TIME=$(echo "$CTRL_TERM?");
  fi;

  if [ "$NAME" == "KS_NODES???" ]; then
    DTD_JSON='KS_NODES???';
    DTD_JSON_TIME='KS_NODES???';
  elif [ "$NAME" == "clock" ]; then
   DTD_JSON='n/a';
   DTD_JSON_TIME='n/a';
  fi;
};##end of dtd_file

function show_total() {
  SHOWTOTAL=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -v DHCP | awk -F "SHOWTOTAL=" '{print$2}' | tr '[:upper:]' '[:lower:]')

  case $SHOWTOTAL in
    onpaid)
      TOTAL='on_paid'
    ;;
    always)
      TOTAL='always'
    ;;
    never)
      TOTAL='never'
    ;;
    '')
      TOTAL='n/a'
    ;;
  esac

  if [[ -z $TOTAL ]]; then
    TOTAL='new_hw?'
  fi

};## end of show_total function

file_maker

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
printf "|%-11s |%-11s |%-11s |%-11s |%-12s |%-11s |%-13s |%-13s |%-11s |%-11s |%-11s |%-11s |%-7s |%-12s |%-13s |\n" Ktchn\ Scrn Name Config Ctrl\ Term Hardware Version KSD\ Status Routing\ Opt Auto\ Serve Bump\ Sever Sort\ Mode Beep Total? DTD\ JSON.DAT Last\ Update;
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

#####  ESTABLISHING PASSWORD FOR HTML SCREENS  #####
#####  ESTABLISHING PASSWORD FOR HTML SCREENS  #####
DAILY="\x68\x75\x73\x52\x46\x24\x54\x23\x0A"
PASS="\x64\x6F\x6E\x6F\x74\x67\x69\x76\x65\x6F\x\x74"

for KS in `grep ks0 /etc/dhcpd.conf | grep host | awk '{print $2}' | sort`; do

#####  THESE WILL BE USED TO DEFINE THE HARDWARE AND VERSION VARIABLES  #####

 MAC=$(grep -A1 $KS /etc/dhcpd.conf | grep hardware | awk '{print$3}' | cut -c 1-11 | sed 's/\(.*\)/\L\1/g');
 DMB_MICROS_MAC=$(grep -A1 $KS /etc/dhcpd.conf | grep hardware | awk '{print$3}' | cut -c 1-8 | sed 's/\(.*\)/\L\1/g');

 name
 config
# screen_type
 ctrl_term
 hardware
 version
 ksd
 routing_option
 auto_serve
 bumpserver
 sortmode
 beep_config
# ors_config
 dtd_file
 show_total

printf "|%-11s |%-11s |%-11s |%-11s |%-12s |%-11s |%-13s |%-13s |%-11s |%-11s |%-11s |%-11s |%-7s |%-12s |%-13s |\n" $KS $NAME $CONFIG_TYPE $CTRL_TERM $HARDWARE $VERSION $KSD $ROUTING_OPTION $AUTO_SERVE_FLAG $BUMPSERVER $SORT_MODE $BEEP $TOTAL $DTD_JSON $DTD_JSON_TIME | sed 's/-/ /g' | sed 's/_/ /g';
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

done;

rm /tmp/ks_v /tmp/ks_dmb_v /tmp/ksd /tmp/dtd_json /tmp/dtd_json_time 2>/dev/null;

if [[ $ROC_HELP -eq 1 ]]; then
echo -e "\n----------------------------------------------------------------------------------------------------------------
|  ROC Routing Option  |  Description  (route codes in lowercase, KS NAMES IN UPPERCASE)                       |
----------------------------------------------------------------------------------------------------------------
|  1 Video              |  whp + burg + spec -> MAIN                                                           |
----------------------------------------------------------------------------------------------------------------
|  2 Video              |  whp + burg -> MAIN, spec -> SPEC                                                    |
----------------------------------------------------------------------------------------------------------------
|  3 Video              |  FC whp + burg -> MAIN, DT whp + burg -> MAIN 2, spec -> SPEC                        |
----------------------------------------------------------------------------------------------------------------
|  4 Video              |  FC whp + burg -> MAIN, FC spec -> SPEC, DT whp + burg -> MAIN 2, DT spec -> SPEC 2  |
----------------------------------------------------------------------------------------------------------------
|  All to Spec          |  whp + burg + spec -> SPEC                                                           |
----------------------------------------------------------------------------------------------------------------
|  All to Main 2        |  whp + burg + spec -> MAIN 2                                                         |
----------------------------------------------------------------------------------------------------------------"
fi;

echo;


};
ks_grid_os2_v3
