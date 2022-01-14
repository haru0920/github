insert into ${td.each.col02}.${td.each.col03}

select
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id",
  "a"."use_taxaccount_day" as "use_taxaccount_day",
  "a"."account_open_date" as "account_open_date"from "cdp_audience_218415"."customers" a
where a."cdp_customer_id" in (
  select
    _r1."cdp_customer_id"
  from "cdp_audience_218415"."behavior_m_trade_history" _r1
  where not coalesce(_r1."hitokutei_kbn" in ('4','7','A'), false)
  and (_r1."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
)
