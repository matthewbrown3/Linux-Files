#####  CREATED BY MRB ON 10/16/2019  #####
#####  updated by mrb on 01/10/2020  #####
#####  updated by mrb on 3/3/2020  #####
#####  i had google save my username and password to log into the portal
#####  the sleep commands give me time to hi 'login' and for the csvs to Downloads

GRABBERS=()
GRABBERS+=(
"https://dmb.sicomasp.com/ShowDeviceInformationHelper.php"
"https://dmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1583281773_1ppq9M&display_name=spreadsheet.csv"
"https://popdmb.sicomasp.com/ShowDeviceInformationHelper.php"
"https://popdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1583283966_a94esQ&display_name=spreadsheet.csv"
"https://arbysdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756518_bjhdoU&display_name=spreadsheet.csv"
"https://bojanglesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1583277935_RtcWWH&display_name=spreadsheet.csv"
"https://jacksdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756643_y5LNMS&display_name=spreadsheet.csv"
"https://timhortonsdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756694_UqGar5&display_name=spreadsheet.csv"
"https://hardeesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1583281847_Tm27D5&display_name=spreadsheet.csv"
"https://yoshinoyadmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1580256155_czW2Gh&display_name=spreadsheet.csv"
"https://cumberlanddmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1584026216_BSugm5&display_name=spreadsheet.csv"
"https://pandaexpressdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1584108743_2dLVgL&display_name=spreadsheet.csv"
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

sleep 30

COUNT=0
LOOP_COUNT=0
while [ $COUNT -lt $(echo ${#FILES[@]}) ]; do
  open -g "${GRABBERS[$COUNT]}"
  sleep 10
  FILE=$(ls -rt spreadsheet* store* | tail -n 1)
  STRING=$(md5 "$FILE" | awk 'BEGIN {FS="="} {print$2}' | awk '{$1=$1;print}')
  while [[ $STRING != $TEST_STRING ]]; do
    TEST_STRING=$STRING
    sleep 5
    STRING=$(md5 "$FILE" | awk 'BEGIN {FS="="} {print$2}' | awk '{$1=$1;print}')
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

for CSV in bk.csv pop.csv bk_rvpn.csv pop_rvpn.csv arbys_rvpn.csv boj_rvpn.csv jacks_rvpn.csv th_rvpn.csv har_rvpn.csv yos_rvpn.csv jira.csv; do
  auto_go $CSV
done;
