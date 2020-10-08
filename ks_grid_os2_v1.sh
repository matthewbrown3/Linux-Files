ks_grid_os2_v1(){
#CREATED BY MRB ON 6/14/2019
#ADDED SORT_MODE AND BEEP VARIABLES
#RE-DID THE NAME VARIABLE
#RE-DID HOW SCREEN_TYPE IS EMPTY

echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
printf "|%-11s |%-11s |%-11s |%-11s |%-11s |%-12s |%-11s |%-13s |%-13s |%-11s |%-11s |%-11s |%-11s |%-32s |%-13s |\n" Ktchn\ Scrn Name Config Type Ctrl\ Term Hardware Version KSD\ Status Routing\ Opt Bump\ Sever Sort\ Mode Beep ORS DTD\ JSON.DAT Last\ Update;
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";

#####  ESTABLISHING PASSWORD FOR HTML SCREENS  #####
DAILY='HTU*TNux';
export DAILY;
rm /tmp/.sicomkey_today 2>/dev/null;

#####  CREATING ECHO FILES TO BE USED FOR RSRUNNER  #####

echo "
KS=\$KS expect << 'EOS';
set timeout 10" >> /tmp/ks_v;

echo "
spawn ssh sicom@\$::env(KS) /usr/sbin/kscreencontroller -v 2> /dev/null;
expect "'"Are you sure you want to continue connecting (yes/no)? "'" { send "'"yes\r"'" };
expect "'"Please type 'yes' or 'no':"'" { send "'"yes\r"'" };
expect "'"password:"'" { send "'"donotgiveout\n"'" };
expect "'"\\ #"'";
exit;EOS" >> /tmp/ks_v;

echo "
expect << 'EOS';set timeout 10" >> /tmp/ks_dmb_v;
echo "
spawn ssh user013@$::env(KS) cat /etc/sicom-kds-version | grep KDS;
expect "'"Are you sure you want to continue connecting (yes/no)? "'" { send "'"yes\r"'" };
expect "'"Please type 'yes' or 'no':"'" { send "'"yes\r"'" };
expect "'"assword:$"'";
send "'"$::env(DAILY)\r"'";
expect "'"\\ #"'";
exit;EOS" >> /tmp/ks_dmb_v;

echo "
POS=\$(su sicom -c "'"/home/sicom/pos/pos -v"'" | awk '{print \$2}' | cut -c 1-4 | sed 's/\.//g');

STATUS=\$(/etc/rc.d/init.d/sicdkscreend status | awk '{print \$3}');

if [ "'"$STATUS"'" == 'stopped' ] && [[ \$POS -eq 506 || \$POS -ge 600 ]]; then
  echo 'stopped';
elif [ "'"$STATUS"'" != 'stopped' ] && [[ \$POS -eq 506 || \$POS -ge 600 ]]; then
  echo 'STARTED!';
elif [ "'"$STATUS"'" == 'stopped' ] && [[ \$POS -le 505 || \$POS -ge 527 && \$POS -le 528 ]]; then
  echo 'STOPPED!';
else
  echo 'running';
fi;
" > /tmp/ksd;

echo "
if [ -e /var/sicom/DTD_JSON.DAT ]; then
  DTD_JSON=\$(md5sum /var/sicom/DTD_JSON.DAT | awk '{print \$1}');
else
  DTD_JSON='no_.dat';
fi;
echo \$DTD_JSON" > /tmp/dtd_json;

echo "if [ -e /var/sicom/DTD_JSON.DAT ]; then
  DTD_JSON_TIME=\$(ls -alh /var/sicom/DTD_JSON.DAT | awk '{print \$6, \$7, \$8}');
else
  DTD_JSON_TIME='n/a';
fi;
echo \$DTD_JSON_TIME" > /tmp/dtd_json_time;

chmod 755 /tmp/ks_v /tmp/ks_dmb_v /tmp/ksd /tmp/dtd_json /tmp/dtd_json_time;

for KS in `grep ks0 /etc/dhcpd.conf | grep host | awk '{print $2}' | sort`; do

#####  THESE WILL BE USED TO DEFINE THE HARDWARE AND VERSION VARIABLES  #####

 MAC=$(grep -A1 $KS /etc/dhcpd.conf | grep hardware | awk '{print$3}' | cut -c 1-11 | sed 's/\(.*\)/\L\1/g');
 DMB_MICROS_MAC=$(grep -A1 $KS /etc/dhcpd.conf | grep hardware | awk '{print$3}' | cut -c 1-8 | sed 's/\(.*\)/\L\1/g');

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

#####  ESTABLISHING THE SCREEN TYPES  #####

 SCREEN_TYPE=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -iv DHCP | awk 'BEGIN {FS="TYPE="} {print$2}' | cut -d' ' -f1 | sed 's/\(.*\)/\L\1/g');

 if [[ -z $SCREEN_TYPE || $SCREEN_TYPE='' ]]; then
  SCREEN_TYPE='n/a';
fi;

#####  DETERMINING THE CONTROLLING TERMINAL(S)  #####

 CTRL_TERM=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | head -n 1 | awk '{print $1}');
 CTRL_TERM=$(echo "term0$CTRL_TERM");
if [ "$NAME" == "KS_NODES???" ]; then
  CTRL_TERM='KS_NODES???';
fi;

#####  DETERMINING THE HARDWARE  #####

if [ "$MAC" == "00:05:0b:60" ]; then
  HARDWARE='60_series';
elif [ "$MAC" == "00:05:0b:62" ] || [ "$MAC" == "00:05:0b:63" ] || [ "$MAC" == "00:05:0b:64" ]; then
  HARDWARE='62_series';
elif [ "$MAC" == "00:05:0b:68" ] || [ $MAC == "00:05:0b:69" ]; then
  HARDWARE='clock';
elif [ "$DMB_MICROS_MAC" == "00:50:f6" ] || [[ "$DMB_MICROS_MAC" == "44:8e:12" ]] || [[ "$DMB_MICROS_MAC" == "60:c7:98" ]]; then
  HARDWARE='micros';
elif [ "$DMB_MICROS_MAC" == "00:01:2e" ]; then
  HARDWARE='dmb_cntlr';
elif [ "$MAC" == "a0:1e:0b" ]; then
  HARDWARE='minix';
else
  HARDWARE='new_hw?';
fi;

#####  GRABBING THE VERSION ON EACH CONTROLLER AND SEEING IF IT'S ONLINE  #####

 if [ -e /tmp/ks_v ] && [ -e /tmp/ks_dmb_v ]; then
  ping -c 1 -W 5 $KS &>/dev/null;
  ONLINE=$?;
  if [ $ONLINE -eq 0 ]; then
    export KS;
      if [ "$HARDWARE" == "62_series" ] || [ "$HARDWARE" == "micros" ]; then
        VERSION=$(/tmp/ks_v | tail -n 1 | awk '{print $2}' | sed 's/[^0-9]*//g');
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

######  DETERMINING IF THE KS D IS RUNNING  #####

 KSD=$(/sbin/rsrunner $CTRL_TERM /tmp/ksd 2> /dev/null | grep -v STDOUT);
  if [ "$NAME" == "KS_NODES???" ]; then
    KSD='KSNODES???';
  elif [[ -z $KSD ]]; then
    KSD=$(echo "$CTRL_TERM"_down?);
  fi;

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
     if [[ $ROUTING_OPTION -eq 1 ]]; then
       ROUTING_OPTION="1_video";
     elif [[ $ROUTING_OPTION -eq 2 ]]; then
       ROUTING_OPTION="2_video";
     elif [[ $ROUTING_OPTION -eq 3 ]]; then
       ROUTING_OPTION="3_video";
     elif [[ $ROUTING_OPTION -eq 4 ]]; then
       ROUTING_OPTION="4_video";
     elif [[ $ROUTING_OPTION -eq 5 ]];	then
       ROUTING_OPTION="all_to_spec";
     elif [[ $ROUTING_OPTION -eq 6 ]]; then
       ROUTING_OPTION="all_to_main_2";
    elif [[ -z $ROUTING_OPTION ]]; then
       ROUTING_OPTION='set_routing';
     fi;
   elif [ "$BK_LOGO" != "" ] && [[ -z $ROC_CHECK ]]; then
     if [[ $ROUTING_OPTION -eq 1 ]]; then
       ROUTING_OPTION="all_to_whp";
     elif [[ $ROUTING_OPTION -eq 2 ]]; then
       ROUTING_OPTION="whp/spec";
     elif [[ $ROUTING_OPTION -eq 3 ]]; then
       ROUTING_OPTION="whp/burg/spec";
     elif [[ $ROUTING_OPTION -eq 4 ]]; then
       ROUTING_OPTION="fc/dt";
     elif [[ $ROUTING_OPTION -eq 5 ]];	then
       ROUTING_OPTION="all_to_burg";
     elif [[ $ROUTING_OPTION -eq 6 ]]; then
       ROUTING_OPTION="all_to_spec";
     elif [[ -z $ROUTING_OPTION ]]; then
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

#####  CHECKING FOR A BUMPSERVER  #####

BUMPSERVER=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -vi DHCP | grep BUMPSERVER);

if [[ -z $BUMPSERVER ]]; then
 BUMPSERVER='none';
else
  BUMPSERVER='yes';
fi;

#####  CHECKING FOR SORT MODE  #####

SORT_MODE=$(grep -i $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -iv DHCP | awk 'BEGIN {FS="SORTMODE="} {print$2}' | cut -d' ' -f1);

if [ "$SORT_MODE" == 'OLDESTNEWEST' ]; then
  SORT_MODE='old_to_new';
elif [ "$SORT_MODE" == 'NEWESTOLDEST' ]; then
  SORT_MODE='new_to_old';
elif [[ -z $SORT_MODE || "$SORT_MODE" == '' ]]; then
  SORT_MODE='n/a';
else
  SORT_MODE="KSNODES??"
fi;

#####  CHECKING FOR BEEP  #####

BEEP=$(grep -i $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -iv DHCP | awk 'BEGIN {FS="BEEP="} {print$2}' | cut -d' ' -f1 | sed 's/\(.*\)/\L\1/g');

if [[ -z $BEEP || $BEEP == '' ]]; then
 BEEP='n/a';
fi;

#####  CHECKING FOR AN ORS  #####

ORS=$(grep $KS /home/sicom/public_html/mgrngdata/var/sicom/KSNODES.DAT | grep -vi DHCP | grep BUMPTLOG);

if [[ -z $ORS ]]; then
 ORS='none';
else
  ORS='yes';
fi;

#####  CHECKING THE STATUS AND AGE OF THE DTD_JSON FILE ON THE CONTROLLING TERMINAL(S)  #####

DTD_JSON=$(/sbin/rsrunner $CTRL_TERM /tmp/dtd_json 2>/dev/null | grep -v STDOUT);
DTD_JSON_TIME=$(/sbin/rsrunner $CTRL_TERM /tmp/dtd_json_time 2>/dev/null | grep -v STDOUT | sed 's/ /-/g');

if [[ -z $DTD_JSON ]]; then
  DTD_JSON=$(echo "$CTRL_TERM"_down?);
fi;

if [[ -z $DTD_JSON_TIME ]]; then
  DTD_JSON_TIME=$(echo "$CTRL_TERM"_down?);
fi;

if [ "$NAME" == "KS_NODES???" ]; then
  DTD_JSON='KS_NODES???';
  DTD_JSON_TIME='KS_NODES???';
elif [ "$NAME" == "clock" ]; then
 DTD_JSON='n/a';
 DTD_JSON_TIME='n/a';
fi;

printf "|%-11s |%-11s |%-11s |%-11s |%-11s |%-12s |%-11s |%-13s |%-13s |%-11s |%-11s |%-11s |%-11s |%-32s |%-13s |\n" $KS $NAME $CONFIG_TYPE $SCREEN_TYPE $CTRL_TERM $HARDWARE $VERSION $KSD $ROUTING_OPTION $BUMPSERVER $SORT_MODE $BEEP $ORS $DTD_JSON $DTD_JSON_TIME | sed 's/-/ /g' | sed 's/_/ /g';
echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
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

echo "";


};
ks_grid_os2_v1
