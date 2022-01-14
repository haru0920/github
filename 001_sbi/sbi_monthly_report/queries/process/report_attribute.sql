drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- report_masterからデータを取得
with tt001 as(
  select
    mkdb_id
    , td_time_format(td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST'), 'yyyy-MM-01', 'JST') as process_date
  from
    ${database_name.l1}.report_master
)

-- m_open_acct_pからデータを取得(口座開設用)
, tt002 as(
  select
      mkdb_id
    , max_by(route, time) as route
    , max_by(substr(replace(open_date, '/', '-'), 1, 10), time) as open_date
  from
    ${database_name.l0.mkdb_attribute}.m_open_acct_p
  where
    td_time_range(
        time
      ${tmp.start_date_commentout1}, null
      ${tmp.start_date_commentout2}, td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
  group by
    mkdb_id
)

-- m_express_accountからデータを取得(口座開設用)
, tt003 as(
  select
      mkdb_id
    , max_by(replace(yobi2, '/', '-'), time) as yobi2
  from
    ${database_name.l0.mkdb_attribute}.m_express_account
  where
    td_time_range(
        time
      ${tmp.start_date_commentout1}, null
      ${tmp.start_date_commentout2}, td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
  group by
    mkdb_id
)

-- m_trade_date_mmからデータを取得(2回以上取引(同一商品))
, tt004_sub as(
  select
      mkdb_id
    , goods
    , case when max(max_date) <> min(min_date) then 1 else 0 end as flag_twice_or_more
    , date_diff(
          'day'
        , cast(max(concat(substr(max_date, 1, 4), '-', substr(max_date, 5, 2), '-', substr(max_date, 7, 2))) as timestamp)
        , cast('${session_date}' as timestamp)
      ) as pass_last_transaction_day
  from
    ${database_name.l0.mkdb_transaction}.m_trade_date_mm
  where
    td_time_range(
        time
      ${tmp.start_date_commentout1}, null
      ${tmp.start_date_commentout2}, td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
  group by
      mkdb_id
    , goods
), tt004 as(
  select
      mkdb_id
    , case when max(flag_twice_or_more) = 1 then 'true' else 'false' end as flag_twice_or_more
    , min(pass_last_transaction_day) as pass_last_transaction_day
  from
    tt004_sub
  group by
    mkdb_id
)

-- m_nisa_reserveからデータを取得(利用金額閾値)
, tt005 as(
  select  
      mkdb_id
    , cast(max_by(isa_keiyaku_kbn, time) as integer) as isa_keiyaku_kbn
    , cast(max_by(isa_hkzwk_gendo_gk, time) as integer) as isa_hkzwk_gendo_gk
    , cast(max_by(isa_hkzwk_shiyo_gk, time) as integer) as isa_hkzwk_shiyo_gk
    , max(case 
        when cast(isa_hkzwk_shiyo_gk as integer) >= ${tmp.threshold_param} * cast(td_time_format(td_date_trunc('month', td_date_trunc('month', ${session_unixtime}, 'JST') - 1, 'JST'), 'MM', 'JST') as integer) then 'true'
        else null
      end) as flag_nisa_threshold
    , min(case 
        when cast(isa_hkzwk_shiyo_gk as integer) >= ${tmp.threshold_param} * cast(td_time_format(td_date_trunc('month', td_date_trunc('month', ${session_unixtime}, 'JST') - 1, 'JST'), 'MM', 'JST') as integer) then td_time_format(time, 'yyyy-MM-dd', 'JST')
        else null
      end) as achievement_nisa_day
  from
    ${database_name.l0.mkdb_transaction}.m_nisa_reserve
  where
    td_time_range(
        time
      ${tmp.start_date_commentout1}, null
      ${tmp.start_date_commentout2}, td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
    --and kaituke_y = cast(td_time_format(${session_unixtime}, 'yyyy', 'JST') as varchar)
    and kaituke_y = td_time_format(td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST'), 'yyyy', 'JST')
  group by
    mkdb_id
)

-- m_trade_historyからデータを取得(課税口座利用日)
, tt006 as(
  select
      mkdb_id
    , min(replace(substr(trade_date, 1, 10), '/', '-')) as use_taxaccount_day
  from
    ${database_name.l0.mkdb_transaction}.m_trade_history
  where
    td_time_range(
        time
      ${tmp.start_date_commentout1}, null
      ${tmp.start_date_commentout2}, td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
    and hitokutei_kbn not in ('4', '7', 'A')
  group by
    mkdb_id
)

-- 結合
select
    t1.mkdb_id
  , t1.process_date
  , case 
      when t2.route = 'E' then t3.yobi2
      when t2.route = 'T' then t2.open_date
      else t2.open_date
    end as account_open_date
  , t4.flag_twice_or_more
  , t4.pass_last_transaction_day
  , t5.isa_keiyaku_kbn
  , t5.isa_hkzwk_gendo_gk
  , t5.isa_hkzwk_shiyo_gk
  , case when t5.flag_nisa_threshold is not null then t5.flag_nisa_threshold else null end as flag_nisa_threshold
  , case when t5.achievement_nisa_day is not null then t5.achievement_nisa_day else null end as achievement_nisa_day
  , case when t6.use_taxaccount_day is not null then t6.use_taxaccount_day else null end as use_taxaccount_day
from
  tt001 as t1
  left join tt002 as t2 on t1.mkdb_id = t2.mkdb_id
  left join tt003 as t3 on t1.mkdb_id = t3.mkdb_id
  left join tt004 as t4 on t1.mkdb_id = t4.mkdb_id
  left join tt005 as t5 on t1.mkdb_id = t5.mkdb_id
  left join tt006 as t6 on t1.mkdb_id = t6.mkdb_id