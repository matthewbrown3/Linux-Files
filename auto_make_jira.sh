#!/bin/bash

cd /home/mrbrown/files/public/mrbrown/jira

## the number of fields, should be one less than actual
FIELD_NUMBER_TOTAL=$(head -n1 jira.csv | grep -o '|' | wc -l)

## adding one to fix the variable
FIELD_NUMBER_TOTAL=$(($FIELD_NUMBER_TOTAL+1))

sqlite3 jira.db "create table tmp_jira (jira_uid INTEGER PRIMARY KEY AUTOINCREMENT)"

for FIELD_NUMBER in $(seq 1 $FIELD_NUMBER_TOTAL); do
 FIELD_NAME=$(head -n 1 jira.csv | cut -d '|' -f $FIELD_NUMBER | sed 's/ /_/g' | sed 's/\(.*\)/\L\1/g' | sed 's/[][()-]//g' | sed 's_\/__g' | sed 's/\://g')
 sqlite3 jira.db "alter table tmp_jira add $FIELD_NAME text" &>/dev/null
 RESULT=$?
 COUNT=0
 while [[ $RESULT -eq 1 ]]; do
  COUNT=$(($COUNT+1))
  FIELD_NAME=$(head -n 1 jira.csv | cut -d '|' -f $FIELD_NUMBER | sed 's/ /_/g' | sed 's/\(.*\)/\L\1/g' | sed 's/[][()-]//g' | sed 's_\/__g' | sed 's/\://g' | sed "s/$/$COUNT/g")
  sqlite3 jira.db "alter table tmp_jira add $FIELD_NAME text" &>/dev/null
  RESULT=$?
 done
done

## remove the header from the file
sed '1d' jira.csv > jira_inc.csv.tmp

## add the auto increment values
(awk '{printf("%01d\|%s\n", NR, $0)}' jira_inc.csv.tmp > jira_inc.csv) &>/dev/null

## import the csv file
sqlite3 jira.db ".import jira_inc.csv tmp_jira"

if [ $? -eq 1 ]; then

mv jira.db.1 jira.db
mv jira.db.2 jira.db.1
mv jira.db.3 jira.db.2
mv jira.db.4 jira.db.3

echo -e "\nfailed to add data to jira table\n"

else

## remove the old rows from jira table
sqlite3 jira.db "delete from jira"

## insert the new rows from tmp_jira into jira
sqlite3 jira.db "insert into jira (jira_uid, name, type, status, priority, affects_version, fix_version, description, assignee, reporter, created, last_updated, resolution) select jira_uid, issue_key, issue_type, status, priority, affects_versions1, fix_versions1, summary, assignee, reporter, created, updated, resolution from tmp_jira"

## remove the tmp_jira table
sqlite3 jira.db "drop table tmp_jira"

## remove the tmp increment file
rm jira_inc.csv.tmp

DATE=$(date +%F | sed "s/^/\'/; s/$/\'/")
TIME=$(date +%T | sed "s/^/\'/; s/$/\'/")

## update the last_update table
sqlite3 jira.db "delete from last_update"
sqlite3 jira.db "insert into last_update (message,date,time) values ('db made on',$DATE,$TIME)"

echo "jira complete."
fi
