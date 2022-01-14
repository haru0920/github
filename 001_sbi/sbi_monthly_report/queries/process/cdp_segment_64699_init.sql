insert into ${td.each.col02}.${td.each.col03}

select
  "a"."account_open_date" as "account_open_date",
  '05_2回以上取引' as "funnel_name",
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id"from "cdp_audience_218415"."customers" a
where (
  a."flag_twice_or_more" = 'true'
)
or (
  a."cdp_customer_id" in (
    select
      _r4."cdp_customer_id"
    from (
      select
        _r2."cdp_customer_id",
        count(distinct row(_r2."goods")) as _c3
      from "cdp_audience_218415"."behavior_m_trade_date_mm" _r2
      where (_r2."timestamp" between to_unixtime(date_add('month', -1, date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo')))) and to_unixtime(date_trunc('month', from_unixtime(${session_unixtime}, 'Asia/Tokyo'))))
      group by _r2."cdp_customer_id"
    ) _r4
    left join "cdp_audience_218415"."customers" _r5 on _r4."cdp_customer_id" = _r5."cdp_customer_id"
    where coalesce(_r4._c3, 0) >= 2
  )
)
