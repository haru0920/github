insert into ${td.each.col02}.${td.each.col03}

select
  "a"."account_open_date" as "account_open_date",
  '01_口座開設完了' as "funnel_name",
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id"
from "cdp_audience_218415"."customers" a
where a."account_open_date" is not null
