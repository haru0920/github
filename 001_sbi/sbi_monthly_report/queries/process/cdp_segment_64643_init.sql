insert into ${td.each.col02}.${td.each.col03}

select
  "a"."account_open_date" as "account_open_date",
  '02_初期設定完了済み' as "funnel_name",
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id"from "cdp_audience_218415"."customers" a
where a."cdp_customer_id" in (
  select
    _r1."cdp_customer_id"
  from "cdp_audience_218415"."behavior_m_svc_acct_profile" _r1
  where _r1."profile_name" = 'ProvAccountKbn'
  and _r1."profile_value" = 'No'
  and (_r1."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
)
