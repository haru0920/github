insert into ${td.each.col02}.${td.each.col03}

select
  'ATM' as "payment_name",
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id"from "cdp_audience_218415"."customers" a
where a."cdp_customer_id" in (
  select
    _r1."cdp_customer_id"
  from "cdp_audience_218415"."behavior_m_trade_history" _r1
  where _r1."search_trade_m_cd" = 'E3'
  and _r1."formal_brand_name" = 'ATM'
  and (_r1."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
)
or a."cdp_customer_id" in (
  select
    _r2."cdp_customer_id"
  from "cdp_audience_218415"."behavior_m_trade_history" _r2
  where _r2."search_trade_m_cd" = 'E3'
  and _r2."formal_brand_name" = 'ＡＴＭ'
  and (_r2."timestamp" between to_unixtime(date_add('day', -1, date_trunc('day', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('day', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
)
