ocu_grid_os2_v2(){

#####  CREATED BY MRB ON 6/20/2020  #####

#####  set up the for loop to account for t0 controlling the ocu  #####

function file_maker {

cat << EOF > /tmp/ocu_v
#!/usr/bin/expect -f
set OCU [ lindex \$argv 0 ]
set PASS [ lindex \$argv 1 ]
set timeout 10;
spawn ssh sicom@\$OCU /home/sicom/sign/./sign -v 2>/dev/null;
expect "Are you sure you want to continue connecting (yes/no)? " { send "yes\r" };
expect "Please type 'yes' or 'no':" { send "yes\r" };
expect "password:" { send "\$PASS\n" };
expect "\\ #";
exit;
EOF

cat << EOF >/tmp/mb_v
#!/usr/bin/expect -f
set OCU [ lindex \$argv 0 ]
set PASS [ lindex \$argv 1 ]
set timeout 10
spawn ssh user013@\$OCU cat /etc/menuboard_release
expect "Are you sure you want to continue connecting (yes/no)? " { send "yes\r" };
expect "Please type 'yes' or 'no':" { send "yes\r" };
expect "*assword:" { send "\$PASS\r" }
expect "\\ #"
exit;
EOF

chmod 755 /tmp/ocu_v /tmp/mb_v
} ## end of file_maker function

function ocu_type {

#####  OCU TYPE  #####

  TYPE_MAC=$(grep -B1 $OCU /etc/dhcpd.conf | grep hard | awk '{print $3}' | sed 's/;//g' | sed 's/://g' | cut -c 1-6 | sed 's/\(.*\)/\L\1/');

  if [ -z $TYPE_MAC ]; then
    TYPE_MAC='n/a';
  elif [[ "$TYPE_MAC" == 'n/a' && $DT_OCU_TERM != 'n/a' ]]; then
    TYPE='td_serial';
  else
    TYPE='n/a';
  fi;

  case $TYPE_MAC in

  00050b)
    TYPE='sicom';
    ;;
  0050b6|3c18a0|00051b)
    TYPE='hyperactive';
    ;;
  00032d)
    TYPE='delphi';
    ;;
  000401)
    TYPE='techknow';
    ;;
  000192)
    TYPE='td ip';
    ;;
  1077b1|00012e)
    TYPE='samsung';
    ;;
  esac

} ## end of ocu_type function ##

function ocu_online {
  ##### OCU ONLINE?  #####

   ping -c 1 -W 5 $OCU &>/dev/null;

   OFFLINE=$?;

  if [ $OFFLINE -eq 0 ]; then
    ONLINE='online';
  elif [[ $OFFLINE -eq 1 && "$TYPE" == 'td_serial' ]]; then
    ONLINE='n/a';
  elif [[ $TYPE == 'n/a' ]]; then
    ONLINE='n/a';
  else
    ONLINE='offline';
  fi;
}  ## end of ocu_online function ##

function subnet {
  #####  SUBNET  #####

  IP=$(grep $OCU -i /etc/hosts | awk '{print $1}');

  if [[ $TYPE == 'td_serial' ]]; then
    IP='n/a';
  fi;
} ## end of subnet function ##

function fc_dt {

  #####  FC/DT  #####

  MAC=$(grep -B1 $OCU /etc/dhcpd.conf | grep hard | awk '{print $3}' | sed 's/;//g' | sed 's/://g' | cut -c 7-12);

  if [[ "$TYPE_MAC" == 'sicom' ]] && [[ $MAC -ge 703000 ]]; then
    DTFC='fc';
  elif [[ "$TYPE_MAC" == 'sicom' ]] && [[ $MAC -lt 703000 ]]; then
    DTFC='dt';
  else
    DTFC='dt';
  fi;
} ##  end of fc_dt function ##

function version {

  #####  VERSION  #####

  if [[ $TYPE == 'sicom' && $ONLINE == 'online' ]]; then
    SICOM_PASS=$(echo -e "$SICOM_PASS")
    VERSION=$(/tmp/ocu_v $OCU $SICOM_PASS 2>/dev/null | grep -vi ocu | awk '{print $2}' | cut -c 1-4);
  elif [[ $TYPE == 'samsung' && $ONLINE == 'online' ]]; then
    USER_PASS=$(echo -e "$USER_PASS")
    VERSION=$(/tmp/mb_v $OCU "$USER_PASS" | grep Built | awk '{print$1}')
  else
   VERSION='n/a';
  fi;

  if [[ -z $VERSION ]];then
   VERSION='n/a';
  fi;
}  ## end of version function ##

function port {

  #####  PORT  #####

cat << EOS > /tmp/ocu_port
OCU_PORT=\$(grep $OCU /etc/printcap | awk -F "$OCU" '{print \$NF}' | sed 's/://g');
echo \$OCU_PORT
EOS

  chmod 755 /tmp/ocu_port;

  #DT_OCU_TERM=$(mysql mgrng -sNe "select location from routing_devices where routing_paths_uid = $ROUTING_PATH_UID_MATH and routing_device_types_uid = 10;" | tail -n 1);

  if [ "$DT_OCU_TERM" != 'n/a' ]; then
    LEADING_ZERO=$(printf "%02d\n" "$DT_OCU_TERM");
  fi;

  if [ "$DT_OCU_TERM" == 'n/a' ]; then
    TERMLOAD_PORT='n/a';
    OCU_PORT='n/a';
  elif [[ $DT_OCU_TERM -eq 0 ]]; then
    TERMLOAD_PORT=$(grep $OCU /etc/printcap | awk '{print $3}' | sed 's/://g');
    OCU_PORT=$(/sbin/rsrunner term000 /tmp/ocu_port 2>/dev/null | grep -v STDOUT);
  elif [ "$TYPE" == 'td_serial' ]; then
    OCU_PORT='n/a';
    TERMLOAD_PORT='n/a';
  else
      TERMLOAD_PORT=$(grep $OCU /home/termload/term0$LEADING_ZERO/printcap | awk '{print $3}' | sed 's/://g');
    ping -c 1 -W 5 term0$LEADING_ZERO &>/dev/null;
    OFFLINE=$?;
    if [ $OFFLINE -eq 0 ]; then
      OCU_PORT=$(/sbin/rsrunner term0$LEADING_ZERO /tmp/ocu_port 2>/dev/null | grep -v STDOUT);
    else
      OCU_PORT="offline?";
    fi;
  fi;

  if [[ -z $OCU_PORT ]]; then
    OCU_PORT='missing?';
  fi;

  if [[ -z $TERMLOAD_PORT ]]; then
    TERMLOAD_PORT='missing?';
  fi;

  CTRL_TERM="term0$LEADING_ZERO";
};  ## end of port function ##

file_maker

echo "---------------------------------------------------------------------------------------------------------------------------"
printf "|%-11s |%-11s |%-16s |%-11s |%-11s |%-11s |%-11s |%-11s |%-11s |\n" OCU Status Ip Dt\/Fc Type Version Ctrl\ Term OCU\ Port Termload
echo "---------------------------------------------------------------------------------------------------------------------------"

USER_PASS="\x59\x5F\x66\x50\x4A\x76\x6B\x73\x0A"
SICOM_PASS="\x64\x6F\x6E\x6F\x74\x67\x69\x76\x65\x6F\x\x74"

DT_TERM_POS_OPTS_PATH=$(mysql mgrng -sNe "select subtotal_routing_path from terminal_pos_options where terminal_number = 10");
ROUTING_PATH_UID_MATH=$(echo "10*20+$DT_TERM_POS_OPTS_PATH" | bc);
DT_OCU_TERM=$(mysql mgrng -sNe "select location from routing_devices where routing_paths_uid = $ROUTING_PATH_UID_MATH and routing_device_types_uid = 10;" | tail -n 1);
LEADING_ZERO=$(printf "%02d\n" "$DT_OCU_TERM");

if [[ -z $DT_OCU_TERM ]]; then
  DT_OCU_TERM='n/a';
fi;

if [[ $LEADING_ZERO == '00' ]]; then
  PRINTCAP_PATH="/etc"
else
  PRINTCAP_PATH="/home/termload/term0$LEADING_ZERO"
fi

for OCU in `(grep 'host ocu' /etc/dhcpd.conf | awk '{print$2}'; grep 'mb' $PRINTCAP_PATH/printcap | awk '{print$2}') | sort -u`; do

  ocu_type;
  ocu_online;
  subnet;
  fc_dt;
  version;
  port;

printf "|%-11s |%-11s |%-16s |%-11s |%-11s |%-11s |%-11s |%-11s |%-11s |\n" $OCU $ONLINE $IP $DTFC $TYPE $VERSION $CTRL_TERM $OCU_PORT $TERMLOAD_PORT | sed 's/_/ /g';
echo "---------------------------------------------------------------------------------------------------------------------------";
done;

rm /tmp/ocu_v /tmp/mb_v /tmp/ocu_port 2>/dev/null;

echo "";
};
ocu_grid_os2_v2
