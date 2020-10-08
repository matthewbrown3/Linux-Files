#####  CREATED BY MRB ON 10/16/2019  #####
#####  updated by mrb on 01/10/2020  #####
#####  updated by mrb on 3/3/2020  #####
#####  updated by mrb on 3/13/2020  #####
#####  i had google save my username and password to log into the portal
#####  the sleep commands give me time to hit 'login' and for the csvs to Downloads
#####  updated by mrb on 7/24/20220 #####
#####  added the device reports for arbys, bojangles, jacks, tim hortons, hardees, yoshinoya, cumberland and panda express  #####
#####  updated by mrb on 8/20/2020  #####
#####  added if block to catch if the url for the rvpn fails  #####

##  create a starting point for when you want to skip a few
##  create a way to run individual csv grabs

function websites {

open -na "Google Chrome" --args --new-window "https://dmb.sicomasp.com"
sleep 5
open -g "https://popdmb.sicomasp.com/login.php"
open -g "https://arbysdmb.sicomasp.com/login.php"
open -g "https://bojanglesdmb.sicomasp.com/login.php"
open -g "https://jacksdmb.sicomasp.com/login.php"
open -g "https://timhortonsdmb.sicomasp.com/login.php"
open -g "https://hardeesdmb.sicomasp.com/login.php"
open -g "https://yoshinoyadmb.sicomasp.com/login.php"
open -g "https://cumberlanddmb.sicomasp.com/login.php"
open -g "https://pandaexpressdmb.sicomasp.com/login.php"
open -g "https://sm.heartlandcommerce.com/issues/?filter=32634"

};


### updated bk_rvpn link on 8/27/2020

GRABBERS=()
GRABBERS+=(
"https://dmb.sicomasp.com/ShowDeviceInformationHelper.php"
"https://dmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1598536744_dBbTjl&display_name=spreadsheet.csv"
"https://popdmb.sicomasp.com/ShowDeviceInformationHelper.php"
"https://popdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1598626100_mD38bG&display_name=spreadsheet.csv"
"https://arbysdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1599326275_cMm9Kt&display_name=spreadsheet.csv"
"https://arbysdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1597934332_Jz2uFv&display_name=spreadsheet.csv"
"https://bojanglesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1598718648_ExLRL7&display_name=spreadsheet.csv"
"https://bojanglesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1598626391_QtAvSQ&display_name=spreadsheet.csv"
"https://jacksdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1598537255_qrr3Ts&display_name=spreadsheet.csv"
"https://jacksdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1598537753_9vKPkR&display_name=spreadsheet.csv"
"https://timhortonsdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1599326665_zIQb6w&display_name=spreadsheet.csv"
"https://timhortonsdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1599327246_Y3kNH3&display_name=spreadsheet.csv"
"https://hardeesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1599327363_6Cpjid&display_name=spreadsheet.csv
"https://yoshinoyadmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1599327503_3Vl2Jy&display_name=spreadsheet.csv"
"https://cumberlanddmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1599327572_xrgDvn&display_name=spreadsheet.csv"
"https://pandaexpressdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1599327783_oxfuHU&display_name=spreadsheet.csv"
)



FILES=()
FILES+=(
bk.csv
bk_rvpn.csv
pop.csv
pop_rvpn.csv
arb.csv
arb_rvpn.csv
boj.csv
boj_rvpn.csv
jac.csv
jac_rvpn.csv
th.csv
th_rvpn.csv
har_rvpn.csv
yos_rvpn.csv
cum_rvpn.csv
pan_rvpn.csv
)

cd /Users/mrbrown/Downloads

websites

sleep 30

COUNT=0

while [ $COUNT -lt $(echo ${#FILES[@]}) ]; do
  open -g "${GRABBERS[$COUNT]}"
  sleep 10
  FILE=$(ls -rt spreadsheet* store* 2>/dev/null | tail -n 1)
  FILE_CHECK=$(echo $FILE | cut -d '.' -f3)
  INNNER_LOOP_COUNT=0
  SKIP_FLAG="false"

  if [[ -z $FILE_CHECK ]]; then
    while ! [[ -z $FILE_CHECK ]]; do
      sleep 5
      FILE=$(ls -rt spreadsheet* store* | tail -n 1)
      FILE_CHECK=$(echo $FILE | cut -d '.' -f3)
      INNNER_LOOP_COUNT=$((INNNER_LOOP_COUNT+1))
      if [[  $INNNER_LOOP_COUNT -eq 3 ]]; then
        echo "-there is an issue with ${FILES[$COUNT]}"
        echo "-check on ${GRABBERS[$COUNT]}"
        FILE_CHECK='complete'
        SKIP_FLAG="true"
        break
      fi
    done

    if [[ "$SKIP_FLAG" == 'false' ]]; then
      SIZE=$(ls -alhrt "$FILE" | awk '{print$5}')
      while [[ $SIZE != $TEST_SIZE ]]; do
        TEST_SIZE=$SIZE
        sleep 5
        SIZE=$(ls -alhrt "$FILE" | awk '{print$5}')
      done
    mv "$FILE" "${FILES[$COUNT]}"

    ### catching a problem with the file
    if [[ $? -ne 0 ]]; then
      echo "problem with ${FILES[$COUNT]}"
      echo "-check on ${GRABBERS[$COUNT]}"
    else
      echo "-${FILES[$COUNT]} has been completed"
    fi
 fi
else
  echo "-there is an issue with ${FILES[$COUNT]}"
  echo "-check on ${GRABBERS[$COUNT]}"
fi
  ((COUNT=$COUNT+1))
  sleep 5
done

FILE=$(ls -rt Super* | tail -n 1)
mv "$FILE" jira.csv

PUBLIC='/home/mrbrown/files/public/mrbrown'

for CSV in ${FILES[@]} jira.csv; do

case $CSV in
bk.csv|pop.csv|arb.csv|boj.csv|jac.csv|th.csv|har.csv|yos.csv|cum.csv|pan.csv)
  scp $CSV mrbrown-jb1.penguinpos.com:$PUBLIC/stores
  ;;
*_rvpn.csv)
  scp $CSV mrbrown-jb1.penguinpos.com:$PUBLIC/rvpn
  ;;
jira.csv)
  scp $CSV mrbrown-jb1.penguinpos.com:$PUBLIC/jira
  ;;
*)
  scp $CSV mrbrown-jb1.penguinpos.com:/home/mrbrown
  ;;
esac
done;
