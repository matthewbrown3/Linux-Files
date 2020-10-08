#!/bin/bash

ARGS=$*

function help_screen() {
  echo "
---------------------------------------------------------------------------------
|  Syntax           |  ips storeNumber1 storeNumber2 storeNumber3 storeNumberN  |
---------------------------------------------------------------------------------
|  Example          |  ips bk101 pop7007 arb6522 jac217 th599                   |
---------------------------------------------------------------------------------
|  Available Logos  |  bk, pop, arb, jac, th                                    |
---------------------------------------------------------------------------------
"
exit 1
}

case $ARGS in
  --help|--h|--\?)
  help_screen
  ;;
esac

if [[ -z $ARGS ]]; then
  help_screen
fi

echo -e "\n--------------------------------------------------------------------------------------------------"
printf "|%-10s |%-15s |%-15s |%-15s |%-15s |%-15s |\n" Store External\ Ip DMB\ Rvpn Pos\ Rvpn DTD\ Rvpn Chef\ Rvpn
echo "--------------------------------------------------------------------------------------------------"

for ARGS; do

  LOGO=$(echo $ARGS | tr -d '[:digit:]' | tr '[:lower:]' '[:upper:]')
  STORE=$(echo $ARGS | tr -d '[:alpha:]')
  if [[ $LOGO == 'TH' ]]; then
    STORE=$(printf "1%05d" $STORE)
  fi
  echo "curl 'http://192.168.110.101/ip/main.php?draw=31&columns%5B0%5D%5Bdata%5D=&columns%5B0%5D%5Bname%5D=&columns%5B0%5D%5Bsearchable%5D=true&columns%5B0%5D%5Borderable%5D=false&columns%5B0%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B0%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B1%5D%5Bdata%5D=store_id&columns%5B1%5D%5Bname%5D=store_id&columns%5B1%5D%5Bsearchable%5D=true&columns%5B1%5D%5Borderable%5D=true&columns%5B1%5D%5Bsearch%5D%5Bvalue%5D=STORE&columns%5B1%5D%5Bsearch%5D%5Bregex%5D=true&columns%5B2%5D%5Bdata%5D=brand&columns%5B2%5D%5Bname%5D=&columns%5B2%5D%5Bsearchable%5D=true&columns%5B2%5D%5Borderable%5D=true&columns%5B2%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B2%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B3%5D%5Bdata%5D=dg_extip&columns%5B3%5D%5Bname%5D=&columns%5B3%5D%5Bsearchable%5D=true&columns%5B3%5D%5Borderable%5D=true&columns%5B3%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B3%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B4%5D%5Bdata%5D=vpn_dmb&columns%5B4%5D%5Bname%5D=&columns%5B4%5D%5Bsearchable%5D=true&columns%5B4%5D%5Borderable%5D=true&columns%5B4%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B4%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B5%5D%5Bdata%5D=vpn_pos&columns%5B5%5D%5Bname%5D=&columns%5B5%5D%5Bsearchable%5D=true&columns%5B5%5D%5Borderable%5D=true&columns%5B5%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B5%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B6%5D%5Bdata%5D=vpn_dtd&columns%5B6%5D%5Bname%5D=&columns%5B6%5D%5Bsearchable%5D=true&columns%5B6%5D%5Borderable%5D=true&columns%5B6%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B6%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B7%5D%5Bdata%5D=vpn_chef&columns%5B7%5D%5Bname%5D=&columns%5B7%5D%5Bsearchable%5D=true&columns%5B7%5D%5Borderable%5D=true&columns%5B7%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B7%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B8%5D%5Bdata%5D=&columns%5B8%5D%5Bname%5D=&columns%5B8%5D%5Bsearchable%5D=true&columns%5B8%5D%5Borderable%5D=false&columns%5B8%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B8%5D%5Bsearch%5D%5Bregex%5D=false&columns%5B9%5D%5Bdata%5D=hiddendata&columns%5B9%5D%5Bname%5D=&columns%5B9%5D%5Bsearchable%5D=true&columns%5B9%5D%5Borderable%5D=true&columns%5B9%5D%5Bsearch%5D%5Bvalue%5D=&columns%5B9%5D%5Bsearch%5D%5Bregex%5D=false&order%5B0%5D%5Bcolumn%5D=1&order%5B0%5D%5Bdir%5D=asc&start=0&length=18&search%5Bvalue%5D=&search%5Bregex%5D=false&brand=LOGO&_=1601068094424' -H 'Connection: keep-alive' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://192.168.110.101/ip/' -H 'Accept-Language: en-US,en;q=0.9' --compressed --insecure" > query.sh
  sed -i "s/LOGO/$LOGO/; s/STORE/$STORE/" query.sh

  EXT_IP=$(sh query.sh 2>/dev/null | awk -F "dg_extip" '{print$2}' | cut -d '"' -f3)
  if [[ $EXT_IP == 'no portal' ]]; then
     EXT_IP='n/a'
  fi

  DMB_RVPN=$(sh query.sh 2>/dev/null | awk -F "vpn_dmb" '{print$2}' | cut -d '"' -f3)
  if [[ -z $DMB_RVPN ]];then
    DMB_RVPN='none'
  fi

  POS_RVPN=$(sh query.sh 2>/dev/null | awk -F "vpn_pos" '{print$2}' | cut -d '"' -f3)
    if [[ -z $POS_RVPN ]];then
    POS_RVPN='none'
  fi

  DTD_RVPN=$(sh query.sh 2>/dev/null | awk -F "vpn_dtd" '{print$2}' | cut -d '"' -f3)
  if [[ -z $DTD_RVPN ]];then
    DTD_RVPN='none'
  fi

  CHEF_RVPN=$(sh query.sh 2>/dev/null | awk -F "vpn_chef" '{print$2}' | cut -d '"' -f3)
   if [[ -z $CHEF_RVPN ]];then
    CHEF_RVPN='none'
  fi

  LINK="curl 'http://192.168.110.101/ip/child.php?store_id=STORE&brand=LOGO' -H 'Connection: keep-alive' -H 'Accept: */*' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://192.168.110.101/ip/' -H 'Accept-Language: en-US,en;q=0.9' --compressed --insecure"
  echo $LINK | sed "s/LOGO/$LOGO/g; s/STORE/$STORE/g" > portal_path.sh

  DMB_PORTAL_PATH=$(sh portal_path.sh 2>/dev/null | awk -F "<span>DMB hierarchy</span>" '{print$2}' | awk -F "$LOGO #$STORE" '{print$1}' | sed "s/<UL><LI>/ -> /2g" | sed 's/<UL><LI>//')
  DTD_PORTAL_PATH=$(sh portal_path.sh 2>/dev/null | awk -F "<span>DTD hierarchy</span>" '{print$2}' | awk -F "$LOGO #$STORE" '{print$1}' | sed "s/<UL><LI>/ -> /2g" | sed 's/<UL><LI>//')
  CHEF_PORTAL_PATH=$(sh portal_path.sh 2>/dev/null | awk -F "<span>CHEF hierarchy</span>" '{print$2}' | awk -F "$LOGO #$STORE" '{print$1}' | sed "s/<UL><LI>/ -> /2g" | sed 's/<UL><LI>//')

  STORE=$(echo $LOGO$STORE | tr '[:upper:]' '[:lower:]')

  printf "|%-10s |%-15s |%-15s |%-15s |%-15s |%-15s |\n" $STORE $EXT_IP $DMB_RVPN $POS_RVPN $DTD_RVPN $CHEF_RVPN
  echo "--------------------------------------------------------------------------------------------------"
done

echo

echo -n "-dmb portal path: $DMB_PORTAL_PATH"; echo $STORE
echo -n "-dtd portal path: $DTD_PORTAL_PATH"; echo $STORE
echo -n "-chef portal path: $CHEF_PORTAL_PATH"; echo $STORE
