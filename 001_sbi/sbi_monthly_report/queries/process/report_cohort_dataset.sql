drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- report_funnel_datamartのデータを取得
with tt001 as(
  select
      substr(account_open_date, 1, 7) as account_open_date
    , count(*) over(partition by substr(account_open_date, 1, 7)) as month_total_cnt
    , funnel01
    , funnel02
    , funnel03
    , funnel04
    , funnel05
  from
    ${database_name.l1}.report_funnel_datamart
  where
    account_open_date is not null
    and account_open_date >= '2021-08'
    and flag_exist = 'new'
)

-- account_open_dateで集約し、フェーズ毎後続フェーズの累積を集計
, tt002 as(
  select
      account_open_date
    , max(month_total_cnt) as month_total_cnt
    , count(funnel01) as funnel01_cnt
    , sum(case when funnel02 is not null or funnel03 is not null or funnel04 is not null or funnel05 is not null then 1 else 0 end) as funnel02_cnt
    , sum(case when funnel03 is not null or funnel04 is not null or funnel05 is not null then 1 else 0 end) as funnel03_cnt
    , sum(case when funnel04 is not null or funnel05 is not null then 1 else 0 end) as funnel04_cnt
    , sum(case when funnel05 is not null then 1 else 0 end) as funnel05_cnt
  from
    tt001
  group by
    account_open_date
)

-- 横持ち→縦持ち変換
, tt003 as(
  select
      t1.account_open_date
    , t1.month_total_cnt
    , t2.key as phase
    , t2.value as uu
  from
    tt002 as t1
  cross join unnest(
      array['1.口座開設', '2.初期設定', '3.入金', '4.初回取引', '5.継続取引']
    , array[funnel01_cnt, funnel02_cnt, funnel03_cnt, funnel04_cnt, funnel05_cnt]
  ) t2(key, value)

)

-- 比率の計算
, tt101 as(
  select
      account_open_date
    , phase
    , uu
    , round(cast(uu as double) / month_total_cnt, 5) as rate
  from
    tt003
)

-- 結果の出力
select
      concat(account_open_date, '-01') as account_open_date
    , phase
    , uu
    , rate
from
  tt101
order by 
  account_open_date, phase