#####  CREATED BY MRB ON 10/16/2019  #####
#####  updated by mrb on 01/10/2020  #####
#####  updated by mrb on 3/3/2020  #####
#####  updated by mrb on 3/13/2020  #####
#####  i had google save my username and password to log into the portal
#####  the sleep commands give me time to hi 'login' and for the csvs to Downloads
#####  added while loop for the changing file name  #####

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


GRABBERS=()
GRABBERS+=(
"https://dmb.sicomasp.com/ShowDeviceInformationHelper.php"
"https://dmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1588454336_FAAU26&display_name=spreadsheet.csv"
"https://popdmb.sicomasp.com/ShowDeviceInformationHelper.php"
"https://popdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1585956053_7vMZa4&display_name=spreadsheet.csv"
"https://arbysdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1585956258_oZ3ijc&display_name=spreadsheet.csv"
"https://bojanglesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1585956482_Ghb9jv&display_name=spreadsheet.csv"
"https://jacksdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1590761716_3fBfWN&display_name=spreadsheet.csv"
"https://timhortonsdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1587743108_mZema1&display_name=spreadsheet.csv"
"https://hardeesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1585957046_gmz8lZ&display_name=spreadsheet.csv"
"https://yoshinoyadmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1585957103_vVGAz2&display_name=spreadsheet.csv"
"https://cumberlanddmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1587823901_0xns2D&display_name=spreadsheet.csv"
"https://pandaexpressdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1585957256_DVB0X9&display_name=spreadsheet.csv"
)

FILES=()
FILES+=(
bk.csv
bk_rvpn.csv
pop.csv
pop_rvpn.csv
arbys_rvpn.csv
boj_rvpn.csv
jacks_rvpn.csv
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
LOOP_COUNT=0

while [ $COUNT -lt $(echo ${#FILES[@]}) ]; do
  open -g "${GRABBERS[$COUNT]}"
  sleep 10
  FILE=$(ls -rt spreadsheet* store* &>/dev/null | tail -n 1)
  FILE_CHECK=$(echo $FILE | cut -d '.' -f3)
  while ! [[ -z $FILE_CHECK ]]; do
    sleep 5
    FILE=$(ls -rt spreadsheet* store* &>/dev/null | tail -n 1)
    FILE_CHECK=$(echo $FILE | cut -d '.' -f3)
  done
  SIZE=$(ls -alhrt "$FILE" | awk '{print$5}')
  while [[ $SIZE != $TEST_SIZE ]]; do
    TEST_SIZE=$SIZE
    sleep 5
    SIZE=$(ls -alhrt "$FILE" | awk '{print$5}')
  done
  mv "$FILE" "${FILES[$COUNT]}"

  ### catching a problem with the file
  if [[ $? -ne 0 ]]; then
    echo "problem with ${FILES[$COUNT]}...exiting"
    sleep 3
    exit 1
  fi
  ((COUNT=$COUNT+1))
  sleep 5
done

FILE=$(ls -rt Super* | tail -n 1)
mv "$FILE" jira.csv

PUBLIC='/home/mrbrown/files/public/mrbrown'

for CSV in ${FILES[@]} jira.csv; do

case $CSV in
bk.csv|pop.csv)
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
