drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- report_payment_verticalのデータを取得しmkdb_idで集約
with tt001 as(
  select
      mkdb_id
    , max(process_date) as process_date
    , map_agg(payment_name, payment_name) as kv
  from
    ${database_name.l1}.report_payment_vertical
  where
    process_date is not null
  group by
    mkdb_id
)

-- 横持ち変換
, tt002 as(
  select
      mkdb_id
    , process_date
    , if(element_at(kv, 'ハイブリット預金') is not null, kv['ハイブリット預金'], null) as payment01
    , if(element_at(kv, '振込') is not null, kv['振込'], null) as payment02
    , if(element_at(kv, 'ATM') is not null, kv['ATM'], null) as payment03
    , if(element_at(kv, 'クレカ入金') is not null, kv['クレカ入金'], null) as payment04
  from
    tt001
)

-- 前月の結果を取得
, tt003 as(
  select
      mkdb_id
    , process_date
    , payment01
    , payment02
    , payment03
    , payment04
  from
    ${database_name.l1}.tmp_report_payment_datamart
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
    , case when t1.mkdb_id is not null then t1.process_date else t2.process_date end as process_date
    , case when t2.payment01 is not null then t2.payment01 else t1.payment01 end as payment01
    , case when t2.payment02 is not null then t2.payment02 else t1.payment02 end as payment02
    , case when t2.payment03 is not null then t2.payment03 else t1.payment03 end as payment03
    , case when t2.payment04 is not null then t2.payment04 else t1.payment04 end as payment04
    , case when t1.mkdb_id is not null then 'new' else 'old' end as flag_exist
  from
    tt002 as t1
    full join tt003 as t2
    on t1.mkdb_id = t2.mkdb_id
)

-- 結果の出力
select
    mkdb_id
  , process_date
  , payment01
  , payment02
  , payment03
  , payment04
  , flag_exist
from
  tt101