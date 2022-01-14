insert into ${td.each.col02}.${td.each.col03}

-- report_nisa_datamartのデータを取得
with tt001 as(
  select
      process_date
    , count(*) over () as over_nisa
    , flag_exclusion
  from
    ${database_name.l1}.report_nisa_datamart
  where
    -- 当該月NISA口座利用ユーザが対象
    flag_exist = 'new'
    -- 口座開設が2021/08/01以降のユーザ(NISAのデータが8/31以降となるため、次月の口座開設者からとする)
    and account_open_date >= '2021-09'
    -- NISA上限到達よりも先に課税口座を利用しているユーザは除外
    -- NISA上限到達していないユーザは対象外
    and flag_exclusion > 0
)

-- データの集計
,tt002 as(
  select
      process_date
    , max(over_nisa) as over_nisa
    , sum(case when flag_exclusion = 2 then 1 else 0 end) as over_nisa_to_use_tax
  from
    tt001
  group by
    process_date
)

-- 比率の計算
, tt101 as(
  select
      process_date as month
    , over_nisa
    , over_nisa_to_use_tax
    , round(cast(over_nisa_to_use_tax as double) / over_nisa, 5) as rate
  from
    tt002
)

-- 結果の出力
select
      month
    , over_nisa
    , over_nisa_to_use_tax
    , rate
from
  tt101
order by 
  month