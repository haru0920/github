insert into ${td.each.col02}.${td.each.col03}

-- report_funnel_datamartのデータを取得
with tt001 as(
  select
      funnel_applicable as phase
    , process_date as month
    , count(*) over () as total_uu
  from
    ${database_name.l1}.report_funnel_datamart
  where
    -- 当該月に存在する顧客を対象
    flag_exist = 'new'
    -- 口座開設が2021/08/01以降のユーザ
    and account_open_date >= '2021-08' --td_time_range(TD_TIME_PARSE(account_open_date, 'JST'), '2021-08-01', null, 'JST')
)

-- funnel毎に集計
, tt002 as(
  select
      case 
        when phase = '01_口座開設完了' then '1.口座開設'
        when phase = '02_初期設定完了済み' then '2.初期設定'
        when phase = '03_入金履歴あり' then '3.入金'
        when phase = '04_取引履歴あり' then '4.初回取引'
        when phase = '05_2回以上取引' then '5.継続取引'
        when phase = '06_最終取引から一定期間経過' then '6.休眠'
        else null
      end as phase 
    , max(month) month
    , count(*) as uu
    , max(total_uu) total_uu
  from
    tt001
  group by
    phase
)

-- 前月の結果を取得
, tt003 as(
  select
      phase
    , uu
  from
    ${td.each.col02}.${td.each.col03}
  where
    td_time_range(
        time
      , td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
)

-- 比率の計算
, tt101 as(
  select
      t1.phase
    , t1.month
    , t1.uu
    , round(case when t2.uu is not null then cast(t1.uu as double) / t2.uu else null end, 5) as prev_month_rate
    , round(cast(t1.uu as double) / t1.total_uu, 5) as this_month_rate
    , t1.total_uu
  from
    tt002 as t1
    left join tt003 as t2 on t1.phase = t2.phase
)

-- 結果の出力
select
    phase
  , month
  , uu
  , prev_month_rate
  , this_month_rate
  , total_uu
from
  tt101
order by 
  phase