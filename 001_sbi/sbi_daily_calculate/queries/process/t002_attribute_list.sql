drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- 顧客口座属性(全件)
-- 連携されない日を加味して最新日のデータを使用する
with tt001 as(
  select
      mkdb_id
    , case when cast(uai_birth_day as integer) > 0 then uai_birth_day else null end as uai_birth_day
  from
    ${database_name.l1}.m_user_attrbute_info_oneday
)

-- 口座開設資料(lk)請求データ【個人】(全件)EXPRESS口座開設顧客(全件)
-- 口座開設日を取得
, tt002 as(
  select
      t1.mkdb_id
    , case
        when t1.route = 'T' then t1.open_date
        when t1.route = 'E' then t2.yobi2
        else null
      end as account_open_date
  from
    ${database_name.l1}.m_open_acct_p_oneday as t1
    left join
    ${database_name.l1}.m_express_account_oneday as t2
    on t1.mkdb_id = t2.mkdb_id
)

-- s01_02_口座開設初期設定施策顧客履歴(spiral)
-- 全ユーザの最古のデータを使用する
, tt003 as(
  select
      mkdb_id
    , min(process_date) as process_date
  from
    ${database_name.l2}.s01_02_segment_init_setting_history_spiral
  group by
    mkdb_id
)

-- s01_04_入金顧客履歴(spiral)
-- 全ユーザの最古のデータを使用する
, tt004 as(
  select
      mkdb_id
    , min(process_date) as process_date
  from
    ${database_name.l2}.s01_04_segment_payment_history_spiral
  group by
    mkdb_id
)

-- s02_01_初回取引(投信)→成長パス_ステップアップ教示(国内株)(spiral)
-- 全ユーザの当該年最古のデータを使用する
, tt005 as(
  select
      mkdb_id
    , min(process_date) as process_date
    , min(process_year) as process_year
  from
    ${database_name.l2}.s02_01_segment_stepup_domestic_history_spiral
  where
    process_year = ${session_date_compact.substr(0, 4)}
  group by
    mkdb_id
)

-- s02_02_アップ&クロスセル訴求施策顧客(spiral)
-- 全ユーザの当該年最古のデータを使用する
, tt006 as(
  select
      mkdb_id
    , min(process_date) as process_date
    , min(process_year) as process_year
    , count(*) as send_count
  from
    ${database_name.l2}.s02_02_segment_upsell_history_spiral
  where
    process_year = ${session_date_compact.substr(0, 4)}
  group by
    mkdb_id  
)

-- s02_03_アップ&クロスセル訴求施策顧客(karte)
-- 全ユーザの当該年最古のデータを使用する
, tt007 as(
  select
      mkdb_id
    , min(process_date) as process_date
    , min(process_year) as process_year
    , count(*) as send_count
  from
    ${database_name.l2}.s02_03_segment_upsell_history_karte
  where
    process_year = ${session_date_compact.substr(0, 4)}
  group by
    mkdb_id  
)

-- s03_01_他サービス認知施策顧客(spiral)
-- 全ユーザの当該年・当該月最古のデータを使用する
, tt008 as(
  select
      mkdb_id
    , min(process_date) as process_date
    , min(process_year) as process_year
    , min(process_month) as process_month
    , count(*) as send_count
  from
    ${database_name.l2}.s03_01_segment_other_service_history_spiral
  where
    process_year = ${session_date_compact.substr(0, 4)}
    and process_month = '${session_date_compact.substr(4, 2)}'
  group by
    mkdb_id
)

-- s02_01_初回取引(投信)→成長パス_ステップアップ教示(米株)(spiral)
-- 全ユーザの当該年最古のデータを使用する
, tt009 as(
  select
      mkdb_id
    , min(process_date) as process_date
    , min(process_year) as process_year
  from
    ${database_name.l2}.s02_01_segment_stepup_foreign_history_spiral
  where
    process_year = ${session_date_compact.substr(0, 4)}
  group by
    mkdb_id
)

-- 国内株式現物預り明細
-- 最新のデータを使用する
, tt010 as(
  select
    mkdb_id
  from
    ${database_name.l0.mkdb_transaction}.m_bl_int_stock
  where 
    td_time_range(
        time
      , (select max(time) from ${database_name.l0.mkdb_transaction}.m_bl_int_stock)
      , null
      , 'JST'
    ) 
    and cast(exec_base_balance_t1 as integer) > 0
  group by
    mkdb_id
)

-- テーブルの結合
, tt101 as(
select
  t1.mkdb_id
  , concat(substr(t1.uai_birth_day, 1, 4), '-', substr(t1.uai_birth_day, 5, 2), '-01') as birth_month
  , t2.account_open_date
  , t3.process_date as s01_02_init_setting_spiral_send_date
  , t4.process_date as s01_04_payment_spiral_send_date
  , t5.process_date as s02_01_stepup_domestic_spiral_send_date
  , t6.process_year as s02_02_upsell_spiral_send_year
  , t6.process_date as s02_02_upsell_spiral_send_date
  , case when t6.send_count is not null then t6.send_count else 0 end as s02_02_upsell_spiral_send_count
  , t7.process_year as s02_03_upsell_karte_send_year
  , t7.process_date as s02_03_upsell_karte_send_date
  , case when t7.send_count is not null then t7.send_count else 0 end as s02_03_upsell_karte_send_count
  , t8.process_year as s03_01_other_service_spiral_send_year
  , t8.process_month as s03_01_other_service_spiral_send_month
  , t8.process_date as s03_01_other_service_spiral_send_date
  , case when t8.send_count is not null then t8.send_count else 0 end as s03_01_other_service_spiral_send_count
  , t9.process_date as s02_01_stepup_foreign_spiral_send_date
  , case when t10.mkdb_id is not null then 'true' else 'false' end as t002_domestic_stock_keep
from
  tt001 as t1
  left join tt002 as t2  on t1.mkdb_id = t2.mkdb_id
  left join tt003 as t3  on t1.mkdb_id = t3.mkdb_id
  left join tt004 as t4  on t1.mkdb_id = t4.mkdb_id
  left join tt005 as t5  on t1.mkdb_id = t5.mkdb_id
  left join tt006 as t6  on t1.mkdb_id = t6.mkdb_id
  left join tt007 as t7  on t1.mkdb_id = t7.mkdb_id
  left join tt008 as t8  on t1.mkdb_id = t8.mkdb_id
  left join tt009 as t9  on t1.mkdb_id = t9.mkdb_id
  left join tt010 as t10 on t1.mkdb_id = t10.mkdb_id
)

select
    mkdb_id
  , date_diff('year', cast(birth_month as timestamp), cast('${session_date}' as timestamp)) as t002_age
  , account_open_date as t002_account_open_date
  , date_diff('day', cast(account_open_date as timestamp), cast('${session_date}' as timestamp)) as t002_account_open_date_pass
  , '${session_date}' as t002_process_date
  , '${session_date.substr(0, 4)}' as t002_process_year
  , '${session_date.substr(5, 2)}' as t002_process_month
  , t002_domestic_stock_keep
  , s01_02_init_setting_spiral_send_date
  , s01_04_payment_spiral_send_date
  , s02_01_stepup_domestic_spiral_send_date
  , s02_01_stepup_foreign_spiral_send_date
  , s02_02_upsell_spiral_send_year
  , s02_02_upsell_spiral_send_date
  , date_diff('day', cast(s02_02_upsell_spiral_send_date as timestamp), cast('${session_date}' as timestamp)) as s02_02_upsell_spiral_send_date_pass
  , s02_02_upsell_spiral_send_count
  , s02_03_upsell_karte_send_year
  , s02_03_upsell_karte_send_date
  , date_diff('day', cast(s02_03_upsell_karte_send_date as timestamp), cast('${session_date}' as timestamp)) as s02_03_upsell_karte_send_date_pass
  , s02_03_upsell_karte_send_count
  , s03_01_other_service_spiral_send_year
  , s03_01_other_service_spiral_send_month
  , s03_01_other_service_spiral_send_date
  , s03_01_other_service_spiral_send_count
from
  tt101

