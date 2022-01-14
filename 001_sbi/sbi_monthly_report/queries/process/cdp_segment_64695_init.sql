insert into ${td.each.col02}.${td.each.col03}

select
  "a"."account_open_date" as "account_open_date",
  '04_取引履歴あり' as "funnel_name",
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id"from "cdp_audience_218415"."customers" a
where (
  select
    count(*)
  from "cdp_audience_218415"."behavior_m_trade_date_mm" _r1
  where (_r1."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
  and _r1."cdp_customer_id" = a."cdp_customer_id"
) = 1
