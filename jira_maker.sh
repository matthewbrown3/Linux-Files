 sed '1d' test_jira.csv > test_jira_inc.csv.tmp

 awk '{printf("%01d\|%s\n", NR, $0)}' test_jira_inc.csv.tmp > test_jira_inc.csv


CREATE TABLE "tmp_jira" (jira_uid INTEGER PRIMARY KEY AUTOINCREMENT, Issue_Type text, Issue_key text, Issue_id blob, Outward_issue_link_Cloners text, Outward_issue_link_Dependency text, Outward_issue_link_Duplicate text, Outward_issue_link_Duplicate2 text, Outward_issue_link_Duplicate3 text, Outward_issue_link_Issue_split text, Outward_issue_link_Relate text, Outward_issue_link_Relate2 text, Outward_issue_link_Relate3 text, Outward_issue_link_Relates, Outward_issue_link_Relates2, Outward_issue_link_Relates3 text, Outward_issue_link_Relates4 text, Outward_issue_link_Relates5 text, Outward_issue_link_Relates6 text, Outward_issue_link_Relates7 text, Outward_issue_link_multi_level_hierarchy_GANTT text, Severity text, Summary text, Priority text, Status text, Resolution text, Due_Date text, Assignee text, Created text, Reporter text, Affects_Versions1 text, Affects_Versions2 text, Affects_Versions3 text, Fix_Versions1 text, Fix_Versions2 text, Fix_Versions3 text, Updated text);

CREATE TABLE jira (jira_uid INTEGER PRIMARY KEY AUTOINCREMENT, issue_key text, issue_type text, status text, priority text, affects_version text, fix_version text, summary text, assignee text, reporter text, created text, last_updated text, resolution text);


sqlite> .import test_jira_inc.csv jira
