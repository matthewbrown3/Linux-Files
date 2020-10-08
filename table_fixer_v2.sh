#!/bin/bash

# Andrew Clyde 4-11-18
# modified by MRB 9-27-18
# modified by Gary Hilbert 10-4-18 :)

if [ `whoami` != "root" ] ; then
       	echo "You must be root."
        exit 1
fi

read -p "which table would you like to fix? " TABLE

TABLE=$(echo $TABLE | sed 's/\(.*\)/\L\1/g')
CHECK=$(mysql mgrng -sBe "show tables like '$TABLE'")

if [ -z $CHECK ]; then
  echo "$TABLE does not exist or /var/lib/mysql/mgrng/$TABLE.frm is missing...here is a list of tables"
  sleep 3
  mysql mgrng -sBe "show tables"
  echo ""
  echo "exiting..."
  exit 1
fi

if [ ! -e /var/lib/mysql/mgrng/$TABLE.MYD ]; then
  echo "$TABLE.MYD is missing...exiting"
  exit 1
elif [ ! -e /var/lib/mysql/mgrng/$TABLE.MYI ]; then
  echo "$TABLE.MYI is missing...exiting"
  exit 1
else
  REVISIONS_OF_TABLE=$(mysql mgrng -e "show create table $TABLE\G" | grep revision | sed 's/[^0-9]//g');
  TABLE_REVISION=$(mysql mgrng -sBe "select revisions from table_revisions where name like '$TABLE'");
    if [ "$REVISIONS_OF_TABLE" != "$TABLE_REVISION" ]; then
      cd /var/lib/mysql/mgrng
      tar czvfp /tmp/old_"$TABLE"_$(date +%Y%m%d%H%M%S).tgz $TABLE.* &>/dev/null
      DATA=$(mysqldump -tc mgrng $TABLE | grep "INSERT INTO")
      mysql mgrng -e "UPDATE table_revisions SET revisions = -1 WHERE name ='$TABLE'"
      cd /home/sicom/public_html/mgrng/
      su sicom -c "php sanitycheck.php -w"
      sleep 1
      mysql mgrng -e "delete from $TABLE"
      mysql mgrng -e "$DATA"
    else
      echo "no issue here"
      echo "$TABLE revisions is $REVISIONS_OF_TABLE"
      echo "revisions table for $TABLE is $TABLE_REVISION"
      echo "exiting..."
      sleep 3
      exit 1
    fi
fi

#### os3


#!/bin/bash

# Andrew Clyde 4-11-18
# modified by MRB 9-27-18
# modified by Gary Hilbert 10-4-18 :)

if [ `whoami` != "root" ] ; then
       	echo "You must be root."
        exit 1
fi

read -p "which table would you like to fix? " TABLE

TABLE=$(echo $TABLE | sed 's/\(.*\)/\L\1/g')
CHECK=$(mysql mgrng -sBe "show tables like '$TABLE'")

if [ -z $CHECK ]; then
  echo "$TABLE does not exist or /var/lib/mysql/mgrng/$TABLE.frm is missing...here is a list of tables"
  sleep 3
  mysql mgrng -sBe "show tables"
  echo ""
  echo "exiting..."
  exit 1
fi

  REVISIONS_OF_TABLE=$(mysql mgrng -e "show create table $TABLE\G" | grep revision | sed 's/[^0-9]//g');
  TABLE_REVISION=$(mysql mgrng -sBe "select revisions from table_revisions where name like '$TABLE'");
    if [ "$REVISIONS_OF_TABLE" != "$TABLE_REVISION" ]; then
      cd /var/lib/mysql/mgrng
      tar czvfp /tmp/old_"$TABLE"_$(date +%Y%m%d%H%M%S).tgz $TABLE.* &>/dev/null
      DATA=$(mysqldump -tc mgrng $TABLE | grep "INSERT INTO")
      mysql mgrng -e "UPDATE table_revisions SET revisions = -1 WHERE name ='$TABLE'"
      cd /www/pages/public/mgrng
      su sicom -c "php sanitycheck.php -w"
      sleep 1
      mysql mgrng -e "delete from $TABLE"
      mysql mgrng -e "$DATA"
    else
      echo "no issue here"
      echo "$TABLE revisions is $REVISIONS_OF_TABLE"
      echo "revisions table for $TABLE is $TABLE_REVISION"
      echo "exiting..."
      sleep 3
      exit 1
    fi
