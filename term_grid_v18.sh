term_grid_v18.func(){

#####  CREATED BY MRB ON 6/29/2019  #####

#####  made the POOL variable look for 'insert_status_uid: $SQL_INS_STATUS_UID'  #####
#####  renamed the TERM variable TERMINAL  #####

POS=$(su sicom -c "/home/sicom/pos/pos -v" | awk '{print$2}' | cut -c 1);
NEW_POS=$(su sicom -c "/home/sicom/pos/pos -v" | awk '{print$2}' | cut -d '.' -f1,2 | sed 's/\.//g');
FP=$(mysql mgrng -sBe "select enabled from extras where name like 'fingerprint_reader'");
EMP=$(mysql mgrng -sBe "select fingerprint_clockin from global_pos_options");
MGR=$(mysql mgrng -sBe "select fingerprint_manager from global_pos_options");


######  ASSIGNING A NUMBER TO THE POS VERSION'S LETTER  #####

LETTER=$(su sicom -c '/home/sicom/pos/pos -v' | awk '{print $2}' | cut -c 5);
COUNT=0;
for i in {a..z}; do
COUNT=$(( COUNT + 1 ));
if [[ "$LETTER" == "$i" ]]; then
  VERSION=$(echo $COUNT);
fi;
done;

#####  MAKING ALL OF THE ECHO FILES  #####

if [ "$POS" = "3" ] || [ "$POS" = "2" ]; then

echo "
HOST=\$(hostname);
if [ \$HOST = '"term000"' ]; then
  df -h | grep /dev/sda6 | awk '{print \$5}';
else
  DS=\$(df -h | grep /dev/root | awk '{print \$5}');
fi;
echo \$DS" > /tmp/disk_space;

else
echo "HOST=\$(hostname);if [ \$HOST = '"term000"' ]; then df -h | grep /dev/sda6 | awk '{print \$5}';else DS=\$(df -h | egrep '/dev/sda1|/dev/sda2' | awk '{print \$5}');fi;echo \$DS" > /tmp/disk_space;

echo "
HOST=\$(hostname);
if [ \$HOST = '"term000"' ]; then
  INSERT_STATUS_UID=\$(mysql mgrng -sBe "'"select insert_status_uid from insert_status where status = 1 and terminal_number = 0 and which_side = 0"'");
  POOL=\$(cd /home/sicom/pos; su sicom -c "'"./pos INSERTPOOL.DAT 2>/dev/null | grep $INSERT_STATUS_UID 2>/dev/null"'");
  echo \$POOL;
else
  POOL=\$(su sicom -c "'"/home/sicom/pos/pos /var/sicom/INSERTPOOL.DAT 2>/dev/null | grep insert_status_uid"'");
  echo \$POOL;
fi" > /tmp/inserts;

fi;

echo "UPTIME=\$(uptime | awk '{print \$3, \$4, \$5}' | sed 's/[0-9] user,//g; s/[0-9] users,//g' | sed 's/ day, /d_/g; s/ days, /d_/g; s/ min,/m/g;s/\:/h_/g; s/,/m/g; s/ [0-9]//g');echo \$UPTIME" > /tmp/uptime;

echo "POS_V=\$(su sicom -c "'"/home/sicom/pos/pos -vv"'" | grep sha | awk '{print \$2}'); echo \$POS_V" > /tmp/pos_v;
echo "JSON=\$(md5sum /var/sicom/JSON_DATABASE.DAT | awk '{print \$1}'); echo \$JSON" > /tmp/json;

echo "TIME=\$(ls -alh /var/sicom/JSON_DATABASE.DAT 2>/dev/null | awk '{print \$6, \$7, \$8}' | sed 's/ /_/g');if [ -e /var/sicom/JSON_DATABASE.DAT ]; then echo "'"$TIME"'";else echo n/a;fi;" > /tmp/json_time;

echo "JSON_USER=\$(md5sum /var/sicom/JSON_DATABASE_USERS.DAT | awk '{print \$1}'); echo \$JSON_USER" > /tmp/json_user;
echo "TIME=\$(ls -alh /var/sicom/JSON_DATABASE_USERS.DAT 2>/dev/null | awk '{print \$6, \$7, \$8}' | sed 's/ /_/g');if [ -e /var/sicom/JSON_DATABASE_USERS.DAT ]; then echo "'"$TIME"'";else  echo n/a;fi;" > /tmp/json_user_time;

echo "JSON_EMP=\$(md5sum /var/sicom/JSON_DATABASE_EMPLOYEES.DAT | awk '{print \$1}'); echo \$JSON_EMP" > /tmp/json_emp;
echo "TIME=\$(ls -alh /var/sicom/JSON_DATABASE_EMPLOYEES.DAT 2>/dev/null | awk '{print \$6, \$7, \$8}' | sed 's/ /_/g');if [ -e /var/sicom/JSON_DATABASE_USERS.DAT ]; then echo "'"$TIME"'";else  echo n/a;fi;" > /tmp/json_emp_time;

echo "
TERM=\$(hostname);
if [ "'"$TERM"'" = 'term000' ]; then
  SERVER=\$(fdisk -l | egrep 'MB|GB' | awk '{print \$3, \$4}' | sed 's/,//g; s/ /_/g' | head -n 1);
  RESCUE=\$(fdisk -l | egrep 'MB|GB' | awk '{print \$3, \$4}' | sed 's/,//g; s/ /_/g' | tail -n 1);
  echo "'"PRIMARY $SERVER"'";
  echo "'"SECONDARY $RESCUE"'";
else
  DATASTORE=\$(fdisk -l | egrep 'MB|GB' | awk '{print \$3, \$4}' | sed 's/,//g; s/ /_/g');
  echo "'"PRIMARY $DATASTORE"'";
  echo 'SECONDARY n/a';
fi;" > /tmp/disk_size;

echo "
POS=\$(su sicom -c "'"/home/sicom/pos/pos -v"'" | awk '{print \$2}' | cut -c 1-4 | sed 's/\.//g');
NEW_POS=\$(su sicom -c "'"/home/sicom/pos/pos -v"'" | awk '{print \$2}' | cut -d '.' -f1,2 | sed 's/\.//g');

if [[ \$NEW_POS -ge 527 ]]; then
  VERSION=\$(su sicom -c "'"/home/sicom/pos/pos -v"'" | awk '{print\$2}' | cut -d '.' -f2);
else
  LETTER=\$(su sicom -c "'"/home/sicom/pos/pos -v"'" | awk '{print \$2}' | cut -c 5);
  COUNT=0;
  for i in {a..z}; do
    COUNT=\$(( COUNT + 1 ));
    if [[ "'"$LETTER"'" == "'"$i"'" ]]; then
      VERSION=\$(echo \$COUNT);
    fi;
  done;
fi;

if [[ \$POS -eq 505 && \$VERSION -ge 14 ]] || [[ \$POS -gt 505 && \$VERSION -ge 4 ]] || [[ \$NEW_POS -ge 600 ]] || [[ \$NEW_POS -ge 527 ]]; then
  if [[ -e /var/sicom/fingerprints.dat ]]; then
    RESULT=\$(md5sum /var/sicom/fingerprints.dat 2> /dev/null | awk '{print \$1}' | cut -c 29-32);
    echo \$RESULT;
  else
    echo 'missing_.dat';
  fi;
else
  echo 'n/a';
fi;" > /tmp/fingerprints;

echo "
TIME=\$(ls -alh /var/sicom/fingerprints.dat 2>/dev/null | awk '{print \$6, \$7, \$8}' | sed 's/ /_/g');
if [ -e /var/sicom/fingerprints.dat ]; then
  echo "'"$TIME"'";
else
  echo n/a;
fi;" > /tmp/fp_time;

echo "GUI=\$(md5sum /var/sicom/GUI_DATABASE.DAT | awk '{print \$1}'); echo \$GUI" > /tmp/gui;

echo "TIME=\$(ls -alh /var/sicom/GUI_DATABASE.DAT 2>/dev/null | awk '{print \$6, \$7, \$8}' | sed 's/ /_/g');
if [ -e /var/sicom/GUI_DATABASE.DAT ]; then
echo "'"$TIME"'";
else
  echo n/a;
fi;" > /tmp/gui_time;

chmod 755 /tmp/uptime /tmp/disk_space /tmp/disk_size /tmp/inserts /tmp/pos_v /tmp/json /tmp/json_time /tmp/json_user /tmp/json_user_time /tmp/json_emp /tmp/json_emp_time /tmp/fingerprints /tmp/fp_time /tmp/gui /tmp/gui_time;

#####  SETTING FUNCTIONS TO BE USED LATER  #####

behavior.func(){

  if [[ $BEHAVIOR -eq 0 ]]; then
  SETUP='nrml_fc';
elif [[ $BEHAVIOR -eq 1 ]]; then
  SETUP='dt_ot';
elif [[ $BEHAVIOR -eq 2 ]]; then
  SETUP='dt_cash';
elif [[ $BEHAVIOR -eq 3 ]]; then
  SETUP='dt_any';
elif [[ $BEHAVIOR -eq 4 ]]; then
  SETUP='fc_ot';
elif [[ $BEHAVIOR -eq 5 ]]; then
  SETUP='fc_cash';
elif [[ $BEHAVIOR -eq 6 ]]; then
  SETUP='dlvry';
  fi;
};

hardware.func(){

  if [ "$HARDWARE8" == '00:0c:d6' ]; then
    HARDWARE='sl_20';
  elif [ "$HARDWARE8" == '00:60:ef' ]; then
    HARDWARE='sl_21b';
  elif [ "$HARDWARE11" == '00:05:0b:a0' ]; then
    HARDWARE='sl_20';
  elif [ "$HARDWARE11" == '00:05:0b:b0' ]; then
    HARDWARE='sl_21';
  elif [ "$HARDWARE11" == '00:a0:a4:10' ]; then
    HARDWARE='mcs_t0';
  elif [ "$HARDWARE11" == '00:a0:a4:13' ] || [ "$HARDWARE11" == '00:a0:a4:14' ]; then
    HARDWARE='mcs_5';
  elif [ "$HARDWARE11" == '00:a0:a4:15' ]; then
    HARDWARE='mcs_4lx';
  elif [ "$HARDWARE11" == '00:a0:a4:17' ] || [ "$HARDWARE11" == '00:a0:a4:19' ]; then
    HARDWARE='mcs_5a';
  elif [[ "$HARDWARE3" -ge 407 ]]; then
    HARDWARE='sl_19';
  elif [[ "$HARDWARE3" -le 406 ]]; then
    HARDWARE='sl_18';
  fi;
};

order_history.func(){

CHECK_SHARED_OH=$(mysql mgrng -sBe "select shared_order_history from terminal_pos_options where terminal_number = $ID");
SHARED_OH=$(echo t$CHECK_SHARED_OH);
if [[ $CHECK_SHARED_OH -eq -1 ]]; then
  SHARED_OH='none';
fi;

CHECK_PICKUP_OH=$(mysql mgrng -sBe "select pickup_shared_history from terminal_pos_options where terminal_number = $ID");
PICKUP_OH=$(echo t$CHECK_PICKUP_OH);
if [[ $CHECK_PICKUP_OH -eq -1 ]]; then
  PICKUP_OH='none';
fi;

};

cc_test.func(){


  if [[ $SICOM_CREDIT =~ $NUMBER ]]; then
    CC_TYPE='sicom';
  else
    CC_TYPE='3rd_pty';
  fi;
};

pool.func (){

if [[ $POOL_INS_STATUS_UID != $SQL_INS_STATUS_UID ]]; then
  POOL="BAD_PL?";
elif [[ $SQL_INS_STATUS_UID = "" && $POOL_INS_STATUS_UID = "" ]];  then
  POOL="empty";
elif [[ $POOL_INS_STATUS_UID = $SQL_INS_STATUS_UID ]]; then
  POOL="good";
else
  POOL="?POOL?";
fi;
};

PROCESSOR=$(ls -alh --color=never /home/sicom/sbin/epaymentd/epayment_driver 2>/dev/null | awk '{print$11}' 2>/dev/null);
if [[ $PROCESSOR == 'ccdriver_processor' || -z $PROCESSOR ]]; then
  CC_STAT='CT_Stat';
else
  CC_STAT='Vf_Stat';
fi;

echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
printf "|%-7s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-7s |%-7s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-12s |%-7s |%-12s |%-7s |%-12s |\n" Term Setup HW Shrd\ OH Pkup\ OH Uptime Dsk\ Spc Rsc\ Spc Svr\ Sze Rsc\ Sze Insert# Ins\ Pl Json\ DB Lst\ Upd CC\ Type $CC_STAT Pos\ V GUI\ DB Lst\ Upd User\ DB Lst\ Upd Emp\ DB Lst\ Upd Fgpts Lst\ Upd | sed 's/_/ /g';
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";

for TERMINAL in `grep "host term0[0-3][0-9]" /etc/dhcpd.conf | awk '{print$2}' | sort`; do

ID=$(echo $TERMINAL | sed 's/term//g');
BEHAVIOR=$(mysql mgrng -sBe "select drive_thru_mode from terminal_pos_options where terminal_number = $ID");
SQL_INS=$(mysql mgrng -sBe "select insert_number from insert_status where status = 1 and terminal_number = $ID and which_side = 0");
SQL_INS_STATUS_UID=$(mysql mgrng -sBe "select insert_status_uid from insert_status where status = 1 and terminal_number = $ID and which_side = 0");

#####  TERM BEHAVIOR  #####

behavior.func;

#####  TERM HARDWARE  #####
HARDWARE3=$(grep $TERMINAL -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | sed 's/://g; s/;//g; s/\(.*\)/\L\1/g' | cut -c 7-9);
HARDWARE8=$(grep $TERMINAL -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | cut -c 1-8 | sed 's/\(.*\)/\L\1/g');
HARDWARE11=$(grep $TERMINAL -B1 /etc/dhcpd.conf | grep hardware | awk '{print $3}' | cut -c 1-11 | sed 's/\(.*\)/\L\1/g');

hardware.func;

#####  ORDER HISTORY  #####

order_history.func;

#####  CHECKING TO SEE IF TERMS ARE ONLINE FOR THE RSRUNNER COMMANDS  #####
ping -c 1 -W 5 $TERMINAL &>/dev/null;
ONLINE=$?;

if [ $ONLINE -ne 0 ]; then
  UPTIME="offln?";
  DISK="offln?";
  RDISK="offln?";
  PRIMARY="offln?";
  SECONDARY="offln?";
  POOL="offln?";
  JSON="offln?";
  JSON_TIME="offln?";
  FINGERPRINTS="offln?";
  FP_TIME="offln?";
  POS_V="offln?";
  JSON_USER="offln?";
  JSON_USER_TIME="offln?";
  JSON_EMP="offln?";
  JSON_EMP_TIME="offln?";
  GUI="offln?";
  GUI_TIME="offln?";

else

#####  TERMINAL IS ONLINE, NOW I CAN RUN ALL OF THE FILES I MADE EARLIER  #####

UPTIME=$(/sbin/rsrunner $TERMINAL /tmp/uptime 2>/dev/null | grep -v STDOUT);
DISK=$(/sbin/rsrunner $TERMINAL /tmp/disk_space 2>/dev/null | grep -v STDOUT);
RDISK=$(df -h | egrep "/dev/sdb|/dev/hdb" | awk '{print $5}');
PRIMARY=$(/sbin/rsrunner $TERMINAL /tmp/disk_size 2>/dev/null | grep -v STDOUT | grep PRIMARY | awk '{print $2}');
SECONDARY=$(/sbin/rsrunner $TERMINAL /tmp/disk_size 2>/dev/null | grep -v STDOUT | grep SECONDARY | awk '{print $2}');
POOL=$(/sbin/rsrunner $TERMINAL /tmp/inserts 2>/dev/null | grep -v STDOUT);
POS_V=$(/sbin/rsrunner $TERMINAL /tmp/pos_v 2>/dev/null | grep -v STDOUT);
T0_POS_V=$(su sicom -c '/home/sicom/pos/pos -vv' | grep sha | awk '{print $2}');
JSON_POS=$(su sicom -c "/home/sicom/pos/pos -v" | awk '{print$2}' | cut -c 1-4 | sed 's/\.//g');
JSON_TIME=$(/sbin/rsrunner $TERMINAL /tmp/json_time 2>/dev/null | grep -v STDOUT);
JSON_USER_TIME=$(/sbin/rsrunner $TERMINAL /tmp/json_user_time 2>/dev/null | grep -v STDOUT);
JSON_EMP_TIME=$(/sbin/rsrunner $TERMINAL /tmp/json_emp_time 2>/dev/null | grep -v STDOUT);
GUI_TIME=$(/sbin/rsrunner $TERMINAL /tmp/gui_time 2>/dev/null | grep -v STDOUT);

#####  CHECKING ON SERVER AND RESCUE CARDS  #####

if [ "$TERMINAL" != 'term000' ]; then
RDISK='n/a';
elif [[ $TERMINAL = 'term000' && $HARDWARE = 'sl_21' || $HARDWARE = 'sl_21b' ]]; then
RDISK='n/a';
elif [[ $TERMINAL = 'term000' && -z $RDISK && $HARDWARE != 'sl_21' && $HARDWARE != 'sl_21b' ]]; then
RDISK='RESCUE?';
fi;

  if [[ $HARDWARE = 'sl_21' || $HARDWARE = 'sl_21b' ]]; then
SECONDARY='n/a';
fi;

PRIMARY_CHECKER=$(echo $PRIMARY | egrep -c "MB|GB");
if [[ $PRIMARY_CHECKER -gt 1 ]]; then
PRIMARY="2_DRVS?";
fi;

#####  CHECKING ON fingerprints.dat  #####

  if [[ $JSON_POS -eq 506 && $VERSION -ge 8 ]] || [[ $JSON_POS -eq 505 && $VERSION -ge 21 ]] || [[ $JSON_POS -ge 527 ]]; then

    if [[ $FP -eq 0 ]]; then
      FINGERPRINTS='sw_dbld';
      FP_TIME='sw_dbld';
  elif [[ $FP -eq 1 ]]; then
    if [[ $MGR -eq 0 && $EMP -eq 0 ]]; then
   FINGERPRINTS='sw_nbld';
   FP_TIME='chk_gbl';
   else
      FINGERPRINTS=$(/sbin/rsrunner $TERMINAL /tmp/fingerprints 2>/dev/null | grep -v STDOUT);
    FP_TIME=$(/sbin/rsrunner $TERMINAL /tmp/fp_time 2>/dev/null | grep -v STDOUT);
   fi;
    else
      FINGERPRINTS='ck_xtrs';
      FP_TIME='ck_xtrs';
    fi;
  else
    FINGERPRINTS='n/a';
    FP_TIME='n/a';
  fi;

#####  CHECKING ON JSON DATABASE FILES  #####

if [[ $JSON_POS -ge 505 ]]; then
JSON=$(/sbin/rsrunner $TERMINAL /tmp/json 2>/dev/null | grep -v STDOUT);
  if [[ ! -f /var/sicom/JSON_DATABASE.DAT.CACHE ]]; then
    JSON=".CACHE?";
  else
    JSON_CHECK=$(md5sum /var/sicom/JSON_DATABASE.DAT.CACHE | awk '{print$1}' 2>/dev/null);
    if [ "$JSON" = "$JSON_CHECK" ]; then
      JSON="good";
    elif [ "$JSON" = "" ]; then
      JSON="no_JSON";
    else
      JSON="no_good";
    fi;
  fi;
else
  JSON="n/a";
fi;

#####  CHECKING ON USER DATABASE FILES  #####

if [[ $JSON_POS -ge 505 && $VERSION -ge 20 ]] || [[ $JSON_POS -ge 506 && $VERSION -ge 8 ]] || [[ $JSON_POS -ge 527 ]]; then
    JSON_USER=$(/sbin/rsrunner $TERMINAL /tmp/json_user 2>/dev/null | grep -v STDOUT);
    if [[ ! -f /var/sicom/JSON_DATABASE_USERS.DAT.CACHE ]]; then
      JSON_USER='.CACHE?';
    else
      JSON_USER_CHECK=$(md5sum /var/sicom/JSON_DATABASE_USERS.DAT.CACHE | awk '{print$1}' 2>/dev/null);
      if [[ -z $JSON_USER ]]; then
        JSON_USER='no_JSON';
      elif [ "$JSON_USER_CHECK" == "$JSON_USER" ]; then
        JSON_USER='good';
      else
        JSON_USER='no_good';
      fi;
  fi;
else
  JSON_USER='n/a';
  JSON_USER_TIME='n/a';
fi;

#####  CHECKING ON EMPLOYEE DATABASE FILES  #####

if [[ $JSON_POS -ge 506 && $VERSION -ge 8 ]] || [[ $JSON_POS -ge 600 ]]; then
    JSON_EMP=$(/sbin/rsrunner $TERMINAL /tmp/json_emp 2>/dev/null | grep -v STDOUT);
  if [[ ! -f /var/sicom/JSON_DATABASE_EMPLOYEES.DAT.CACHE ]]; then
    JSON_EMP='.CACHE?';
  else
    JSON_EMP_CHECK=$(md5sum /var/sicom/JSON_DATABASE_EMPLOYEES.DAT.CACHE | awk '{print$1}' 2>/dev/null);
    if [[ -z $JSON_EMP ]]; then
      JSON_EMP='no_JSON';
    elif [ "$JSON_EMP_CHECK" == "$JSON_EMP" ]; then
      JSON_EMP='good';
    else
      JSON_EMP='no_good';
    fi;
  fi;
else
  JSON_EMP='n/a';
  JSON_EMP_TIME='n/a';
fi;

#####  CHECKING ON GUI DATABASE FILES  #####

if [[ $JSON_POS -ge 506 && $VERSION -ge 8 ]] || [[ $JSON_POS -ge 600 ]]; then
    GUI=$(/sbin/rsrunner $TERMINAL /tmp/gui 2>/dev/null | grep -v STDOUT);
    if [[ ! -f /var/sicom/GUI_DATABASE.DAT.CACHE ]]; then
      GUI='.CACHE?';
    else
      GUI_CHECK=$(md5sum /var/sicom/GUI_DATABASE.DAT.CACHE | awk '{print$1}' 2>/dev/null);
      if [[ -z $GUI ]]; then
        GUI='no_JSON';
      elif [ "$GUI_CHECK" == "$GUI" ]; then
        GUI='good';
      else
        GUI='no_good';
      fi;
    fi;
  else
    GUI='n/a';
    GUI_TIME='n/a';
  fi;

#####  CHECKING THE POS BUILD VERSIONS  #####

if [[ $POS_V = "" ]]; then
  POS_V="DS?";
elif [[ $POS_V != $T0_POS_V ]]; then
  POS_V="POS_V?";
else
  POS_V=$(su -c '/home/sicom/pos/pos -v' | awk '{print$2}');
fi;

#####  THROWING OUT ANY VARIABLES THAT WOULD BE AFFECTED BY A MISSING DATASTORE  #####

if [ "$DISK" = "" ]; then
  UPTIME="DS?";
  DISK="DS?";
  RDISK="DS?";
  PRIMARY="DS?";
  SECONDARY="DS?";
  POOL="DS?";
  JSON="DS?";
  JSON_TIME="DS?";
  FINGERPRINTS="DS?";
  FP_TIME="DS?";
  JSON_USER="DS?";
  JSON_USER_TIME="DS?";
  JSON_EMP="DS?";
  JSON_EMP_TIME="DS?";
  GUI="DS?";
  GUI_TIME="DS?";

else

#####  IF THE DATASTORE IS PRESENT, CONTINUE CHECKING STUFF THAT NEEDS THE DS TO BE THERE  #####

sed -i 's/print\$6/print\$5/g' /tmp/disk_space;
POOL_INS_STATUS_UID=$(echo $POOL | awk '{print$2}');

pool.func;
fi;

fi;

ID=$(echo $TERMINAL | sed 's/term0//g');

if [ "$SQL_INS" = "" ]; then
SQL_INS="none";
fi;

#####  CHECKING ON THE CREDIT CARD/VERIFONE STATUS  #####

 CC_SOFTWARE=$(mysql mgrng -sBe "select enabled from extras where name = 'cc_software'");

 if [[ $CC_SOFTWARE -eq 0 ]]; then
   CC_TYPE='3rd_pty';
 else
   SICOM_CREDIT=$(ccutil -1 getstatus | grep Driver | awk '{print$3}');
   if [ "$PROCESSOR" == 'verifone_processor' ]; then
     CC_TYPE='vfone';
   elif [ "$PROCESSOR" == 'epayment_dotnet_processor' ]; then
     CC_TYPE='mono';
   elif [ "$PROCESSOR" == 'epayment_minder' ]; then
     CC_TYPE='epy_mdr';
   elif [ "$PROCESSOR" == 'ccdriver_processor' ]; then
     cc_test.func;
   else
     cc_test.func;
   fi;
fi;

if [[ $CC_TYPE != 'sicom' && $CC_TYPE != '3rd_pty' ]]; then

VERIFONE=$(echo $TERMINAL | sed 's/term/credit/g');
MONO_VFONE_CHECK=$(grep $VERIFONE /etc/dhcpd.conf);

if [[ "$SETUP" == 'fc_ot' || "$SETUP" == 'dt_ot' ]] || [[ "$CC_TYPE" == 'mono' && -z $MONO_VFONE_CHECK ]]; then
  VERIFONE_STATUS='n/a';
else
  ping -c 1 -W 5 $VERIFONE &>/dev/null;
  ONLINE=$?;

  if [[ $ONLINE -ne 0 ]]; then
   CC_TERM='OFFLN?';
  else

    VERIFONE_STATUS=$(echo "<TRANSACTION><FUNCTION_TYPE>SECONDARYPORT</FUNCTION_TYPE><COMMAND>STATUS</COMMAND></TRANSACTION>" | nc $VERIFONE 5016 | grep -c SUCCESS);
  if [[ $VERIFONE_STATUS -eq 1 ]]; then
    CC_TERM='good';
  else
    CC_TERM='CHK';
  fi;
 fi;
 fi;

else
CC1=$(mysql mgrng -sBe "select usedatastore from epayment_params");
CC_TERM=$(printf "%02d\n" "$CC1");
CC_STATUS=$(ccutil -1 getstatus | grep Driver | awk '{print $3}');

if [[ $CC_STATUS -eq 0 ]] && [[ $CC_SOFTWARE -eq 1 ]]; then
  CC_STATUS='ok';
elif [[ $CC_STATUS -eq 1 ]]; then
  CC_STATUS='n/a';
else
  CC_STATUS='CHK';
fi;

 if [ "$ID" == "$CC_TERM" ]; then
CC_TERM=$(echo -n "ys,_$CC_STATUS");
 else
  CC_TERM=$(echo -n "no,_$CC_STATUS");
 fi;

fi;

printf "|%-7s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-7s |%-7s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-12s |%-7s |%-12s |%-7s |%-12s |\n" $TERMINAL $SETUP $HARDWARE $SHARED_OH $PICKUP_OH $UPTIME $DISK $RDISK $PRIMARY $SECONDARY $SQL_INS $POOL $JSON $JSON_TIME $CC_TYPE $CC_TERM $POS_V $GUI $GUI_TIME $JSON_USER $JSON_USER_TIME $JSON_EMP $JSON_EMP_TIME $FINGERPRINTS $FP_TIME| sed 's/_/ /g';
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";

done;

rm /tmp/uptime /tmp/disk_space /tmp/inserts /tmp/disk_size /tmp/pos_v /tmp/json /tmp/json_time /tmp/fingerprints /tmp/json_user /tmp/json_user_time /tmp/json_emp /tmp/json_emp_time /tmp/fp_time /tmp/gui /tmp/gui_time 2>/dev/null;

};


kiosk+tablet+mobile_status.func(){
T0_INS_STATUS_UID=$(mysql mgrng -sBe "select insert_status_uid from insert_status where date is null and terminal_number = 0 and which_side = 0");
for ID in `(su sicom -c 'cd /home/sicom/pos;./pos INSERTPOOL.DAT 2>/dev/null' | grep -i term | awk '{print $7}';mysql mgrng -sBe "select terminal_number from terminal_pos_options where kiosk = 1; select terminal_number from terminal_pos_options where is_subtotal_override_enabled = 1" 2>/dev/null) | sort -u`; do

KIOSKS=$(echo -n term; printf "%03d" "$ID");BEHAVIOR=$(mysql mgrng -sBe "select drive_thru_mode from terminal_pos_options where terminal_number = $ID");
SQL_INS=$(mysql mgrng -sBe "select insert_number from insert_status where status = 1 and terminal_number = $ID and which_side !=0");

behavior.func;

MOBILE=$(mysql mgrng -sBe "select pickup_shared_history from terminal_pos_options where terminal_number = $ID");

if [ "$ID" -ge 40 -a "$ID" -le 49 ]; then
  HARDWARE='tablet';
elif [ "$ID" -ge 50 -a "$ID" -le 59 ]; then
  HARDWARE='kiosk';
elif [ "$MOBILE" != "-1" ]; then
  HARDWARE='mobile';
else
  HARDWARE='CONFIG?';
fi;

order_history.func;

if [[ -z $SQL_INS ]]; then
  SQL_INS='none';
fi;

if [[ -z $T0_INS_STATUS_UID ]]; then
  POOL_INS_STATUS_UID=$(cd /home/sicom/pos; su sicom -c './pos INSERTPOOL.DAT 2>/dev/null' 2>/dev/null | grep -A2 "Term $ID" | grep insert_status_uid | awk '{print $2}');
else
  POOL_INS_STATUS_UID=$(cd /home/sicom/pos; su sicom -c './pos INSERTPOOL.DAT 2>/dev/null' 2>/dev/null | grep -A2 "Term $ID" | grep insert_status_uid | grep -v "$T0_INS_STATUS_UID" | awk '{print $2}');
fi;

SQL_INS_STATUS_UID=$(mysql mgrng -sBe "select insert_status_uid from insert_status where insert_status_uid = $POOL_INS_STATUS_UID and status = 1" 2>/dev/null);

if [[ $POOL_INS_STATUS_UID != $SQL_INS_STATUS_UID ]]; then
  POOL="BAD_PL?";
elif [[ -z $SQL_INS_STATUS_UID && -z $POOL_INS_STATUS_UID ]]; then
  POOL="empty";
elif [[ $POOL_INS_STATUS_UID == $SQL_INS_STATUS_UID ]]; then
  POOL="good";
else
  POOL="?POOL?";
fi;

UPTIME='n/a';
DISK='n/a';
RDISK='n/a';
PRIMARY='n/a';
SECONDARY='n/a';
JSON='n/a';
JSON_TIME='n/a';
CC_TYPE='n/a';
CC_TERM='n/a';
POS_V='n/a';
FINGERPRINTS='n/a';
FP_TIME='n/a';
JSON_USER='n/a';
JSON_USER_TIME='n/a';
JSON_EMP='n/a';
JSON_EMP_TIME='n/a';
GUI='n/a';
GUI_TIME='n/a';
printf "|%-7s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-7s |%-7s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-7s |%-7s |%-7s |%-12s |%-7s |%-12s |%-7s |%-12s |%-7s |%-12s |\n" $KIOSKS $SETUP $HARDWARE $SHARED_OH $PICKUP_OH $UPTIME $DISK $RDISK $PRIMARY $SECONDARY $SQL_INS $POOL $JSON $JSON_TIME $CC_TYPE $CC_TERM $POS_V $GUI $GUI_TIME $JSON_USER $JSON_USER_TIME $JSON_EMP $JSON_EMP_TIME $FINGERPRINTS $FP_TIME | sed 's/_/ /g';
echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------";
done;
echo " ";
};

term_grid_v18.func;
kiosk+tablet+mobile_status.func;
