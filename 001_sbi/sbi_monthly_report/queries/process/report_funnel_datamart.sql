drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- report_funnel_verticalのデータを取得しmkdb_idで集約
with tt001 as(
  select
      mkdb_id
    , max(account_open_date) as account_open_date
    , max(process_date) as process_date
    , map_agg(funnel_name, funnel_name) as kv
  from
    ${database_name.l1}.report_funnel_vertical
  where
    process_date is not null
  group by
    mkdb_id
)

-- 横持ち変換
, tt002 as(
  select
      mkdb_id
    , account_open_date
    , process_date
    , if(element_at(kv, '01_口座開設完了') is not null, kv['01_口座開設完了'], null) as funnel01
    , if(element_at(kv, '02_初期設定完了済み') is not null, kv['02_初期設定完了済み'], null) as funnel02
    , if(element_at(kv, '03_入金履歴あり') is not null, kv['03_入金履歴あり'], null) as funnel03
    , if(element_at(kv, '04_取引履歴あり') is not null, kv['04_取引履歴あり'], null) as funnel04
    , if(element_at(kv, '05_2回以上取引') is not null, kv['05_2回以上取引'], null) as funnel05
    , if(element_at(kv, '06_最終取引から一定期間経過') is not null, kv['06_最終取引から一定期間経過'], null) as funnel06
  from
    tt001
)

-- 前月の結果を取得
, tt003 as(
  select
      mkdb_id
    , account_open_date
    , process_date
    , funnel01
    , funnel02
    , funnel03
    , funnel04
    , funnel05
    , funnel06
  from
    ${database_name.l1}.tmp_report_funnel_datamart
  where
    td_time_range(
        time
      , td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
)

-- テーブルの結合と値の選択
, tt101 as(
  select
      case when t1.mkdb_id is not null then t1.mkdb_id else t2.mkdb_id end as mkdb_id
    , case when t1.mkdb_id is not null then t1.account_open_date else t2.account_open_date end as account_open_date
    , case when t1.mkdb_id is not null then t1.process_date else t2.process_date end as process_date
    , case when t1.mkdb_id is not null then t1.funnel01 else t2.funnel01 end as funnel01
    , case when t2.funnel02 is not null then t2.funnel02 else t1.funnel02 end as funnel02
    , case when t2.funnel03 is not null then t2.funnel03 else t1.funnel03 end as funnel03
    , case when t1.mkdb_id is not null then t1.funnel04 else t2.funnel04 end as funnel04
    , case when t1.mkdb_id is not null then t1.funnel05 else t2.funnel05 end as funnel05
    , case when t1.mkdb_id is not null then t1.funnel06 else t2.funnel06 end as funnel06
    , case when t1.mkdb_id is not null then 'new' else 'old' end as flag_exist
  from
    tt002 as t1
    full join tt003 as t2
    on t1.mkdb_id = t2.mkdb_id
)

-- 結果の出力
select
    mkdb_id
  , account_open_date
  , process_date
  , funnel01
  , funnel02
  , funnel03
  , funnel04
  , funnel05
  , funnel06
  , coalesce(funnel06, funnel05, funnel04, funnel03, funnel02, funnel01) as funnel_applicable
  , flag_exist
from
  tt101