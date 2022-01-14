drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- report_nisa_verticalの課税利用者データを取得しmkdb_idで集約
with tt001 as(
  select
      mkdb_id
    , max(process_date) as process_date
    , max(use_taxaccount_day) as use_taxaccount_day
    , max(account_open_date) as account_open_date
  from
    ${database_name.l1}.report_nisa_vertical
  where
    process_date is not null
    and use_taxaccount_day is not null
  group by
    mkdb_id
)

-- report_nisa_verticalのつみたてNISA上限到達者データを取得しmkdb_idで集約
, tt002 as(
  select
      mkdb_id
    , max(process_date) as process_date
    , max(achievement_nisa_day) as achievement_nisa_day
    , max(account_open_date) as account_open_date
  from
    ${database_name.l1}.report_nisa_vertical
  where
    process_date is not null
    and achievement_nisa_day is not null
  group by
    mkdb_id
)

-- マスタに対して結合
, tt003 as(
  select
      t1.mkdb_id
    , case when t2.mkdb_id is not null then t2.process_date else t3.process_date end as process_date
    , case when t2.mkdb_id is not null then t2.account_open_date else t3.account_open_date end as account_open_date
    , t2.use_taxaccount_day as use_taxaccount_day_new
    , t3.achievement_nisa_day as achievement_nisa_day_new
  from
    ${database_name.l1}.report_master as t1
    left join tt001 as t2 on t1.mkdb_id = t2.mkdb_id
    left join tt002 as t3 on t1.mkdb_id = t3.mkdb_id
  where
    t2.use_taxaccount_day is not null or t3.achievement_nisa_day is not null
)

-- 処理年の前月の結果を取得
, tt004_sub as(
  select
      mkdb_id
    , process_date
    , account_open_date
    , use_taxaccount_day_min
    , achievement_nisa_day_min
  from
    ${database_name.l1}.tmp_report_nisa_datamart
  where
    td_time_range(
        time
      , td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
      , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
      , 'JST'
    )
), tt004 as(
  select
      mkdb_id
    , process_date
    , account_open_date
    , use_taxaccount_day_min
    -- 処理年と最小NISA達成年が同じか？
    , case
        when substr(achievement_nisa_day_min, 1, 4) = td_time_format(td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST'), 'yyyy', 'JST') then achievement_nisa_day_min
        else null
      end as achievement_nisa_day_min
  from
    tt004_sub
)

-- テーブルの結合と値の選択
, tt101 as(
  select
      case when t1.mkdb_id is not null then t1.mkdb_id else t2.mkdb_id end as mkdb_id
    , t1.process_date
    , case when t1.account_open_date is not null then t1.account_open_date else t2.account_open_date end as account_open_date
    , t1.use_taxaccount_day_new
    , t1.achievement_nisa_day_new
    , case when t2.use_taxaccount_day_min is not null then t2.use_taxaccount_day_min else t1.use_taxaccount_day_new end as use_taxaccount_day_min
    , case when t2.achievement_nisa_day_min is not null then t2.achievement_nisa_day_min else t1.achievement_nisa_day_new end as achievement_nisa_day_min
  from
    tt003 as t1
    full join tt004 as t2
    on t1.mkdb_id = t2.mkdb_id
)

-- データの整形
, tt102 as(
  select
      mkdb_id
    , process_date
    , account_open_date
    , use_taxaccount_day_new
    , achievement_nisa_day_new
    , use_taxaccount_day_min
    , achievement_nisa_day_min
    -- -1：NISA上限到達前に課税口座を利用(除外)　0:NISA上限到達前で課税口座も利用していない　1：NISA上限到達はしているが課税口座は利用してない(青棒)　2：NISA上限到達後に課税口座を利用(黄棒)
    , case
        when use_taxaccount_day_min is null and achievement_nisa_day_min is null then 0
        when use_taxaccount_day_min is null and achievement_nisa_day_min is not null then 1
        when use_taxaccount_day_min is not null and achievement_nisa_day_min is null then -1
        when date_diff('day', cast(achievement_nisa_day_min as timestamp), cast(use_taxaccount_day_min as timestamp)) >= 0 then 2
        else -1
      end as flag_exclusion
    , case when achievement_nisa_day_new is not null then 'new' else 'old' end as flag_exist
  from
    tt101
)

-- 結果の出力
select
    mkdb_id
  , process_date
  , account_open_date
  , use_taxaccount_day_new
  , achievement_nisa_day_new
  , use_taxaccount_day_min
  , achievement_nisa_day_min
  , flag_exclusion
  , flag_exist
from
  tt102