insert into ${td.each.col02}.${td.each.col03}

select
  "a"."account_open_date" as "account_open_date",
  '03_入金履歴あり' as "funnel_name",
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id"from "cdp_audience_218415"."customers" a
where (
  a."cdp_customer_id" in (
    select
      _r1."cdp_customer_id"
    from "cdp_audience_218415"."behavior_m_trade_history" _r1
    where _r1."search_trade_m_cd" = 'E3'
    and _r1."formal_brand_name" = '専用銀行口座　自動振替'
    and (_r1."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
  )
  or
  a."cdp_customer_id" in (
    select
      _r2."cdp_customer_id"
    from "cdp_audience_218415"."behavior_m_trade_history" _r2
    where _r2."search_trade_m_cd" = 'E3'
    and _r2."formal_brand_name" = '専用銀行口座 自動振替'
    and (_r2."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
  )
)
or (
  a."cdp_customer_id" in (
    select
      _r3."cdp_customer_id"
    from "cdp_audience_218415"."behavior_m_trade_history" _r3
    where _r3."search_trade_m_cd" = 'E3'
    and _r3."formal_brand_name" = '振込'
    and (_r3."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
  )
)
or (
  a."cdp_customer_id" in (
    select
      _r4."cdp_customer_id"
    from "cdp_audience_218415"."behavior_m_trade_history" _r4
    where _r4."search_trade_m_cd" = 'E3'
    and _r4."formal_brand_name" = 'ATM'
    and (_r4."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
  )
  or
  a."cdp_customer_id" in (
    select
      _r5."cdp_customer_id"
    from "cdp_audience_218415"."behavior_m_trade_history" _r5
    where _r5."search_trade_m_cd" = 'E3'
    and _r5."formal_brand_name" = 'ＡＴＭ'
    and (_r5."timestamp" between to_unixtime(date_add('day', -1, date_trunc('day', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('day', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
  )
)
or (
  a."cdp_customer_id" in (
    select
      _r6."cdp_customer_id"
    from "cdp_audience_218415"."behavior_m_trade_history" _r6
    where _r6."search_trade_m_cd" = 'E3'
    and _r6."formal_brand_name" = '投信積立クレジットカード入金'
    and (_r6."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
  )
)
