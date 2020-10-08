#####  CREATED BY MRB ON 10/16/2019  #####
#####  updated by mrb on 01/10/2020  #####

#####  i had google save my username and password to log into the portal
#####  the sleep commands give me time to hi 'login' and for the csvs to Downloads
cd /Users/mrbrown/Downloads

open -na "Google Chrome" --args --new-window "https://dmb.sicomasp.com"
sleep 5
open -g https://popdmb.sicomasp.com/login.php
open -g https://arbysdmb.sicomasp.com/login.php
open -g https://bojanglesdmb.sicomasp.com/login.php
open -g https://jacksdmb.sicomasp.com/login.php
open -g https://timhortonsdmb.sicomasp.com/login.php

sleep 30

open -g https://dmb.sicomasp.com/ShowDeviceInformationHelper.php

sleep 10

FILE=$(ls -rt store_device_export* | tail -n 1)

mv $FILE bk.csv

open -g https://dmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756235_jHoKhG&display_name=spreadsheet.csv

sleep 10

FILE=$(ls -rt | tail -n 1)

mv $FILE bk_rvpn.csv

open -g https://popdmb.sicomasp.com/ShowDeviceInformationHelper.php

sleep 10

FILE=$(ls -rt | tail -n 1)

mv $FILE pop.csv

open -g https://popdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756406_ndUuiM&display_name=spreadsheet.csv

sleep 10

FILE=$(ls -rt | tail -n 1)

mv $FILE pop_rvpn.csv

open -g https://arbysdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756518_bjhdoU&display_name=spreadsheet.csv

sleep 5

FILE=$(ls -rt | tail -n 1)

mv $FILE arbys_rvpn.csv

open -g https://bojanglesdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756583_lEUx9R&display_name=spreadsheet.csv

sleep 5

FILE=$(ls -rt | tail -n 1)

mv $FILE boj_rvpn.csv

open -g https://jacksdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756643_y5LNMS&display_name=spreadsheet.csv

sleep 5

FILE=$(ls -rt | tail -n 1)

mv $FILE jacks_rvpn.csv

open -g https://timhortonsdmb.sicomasp.com/DataManipulatorSpreadsheetControl.php?filename=DataManipulator_CSV_File__1578756694_UqGar5&display_name=spreadsheet.csv

sleep 5

FILE=$(ls -rt | tail -n 1)

mv $FILE th_rvpn.csv

for CSV in bk.csv pop.csv bk_rvpn.csv pop_rvpn.csv arbys_rvpn.csv boj_rvpn.csv jacks_rvpn.csv th_rvpn.csv; do
  auto_go $CSV
done;

#ssh mrbrown@mrbrown-jb1.penguinpos.com /home/mrbrown/files/private/mrbrown/bin/auto_db_maker.sh
