-- s01_01_認知→初回取引_口座開設初期設定(karte)
with s01_01 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s01_01_segment_init_setting_history_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s01_01_segment_init_setting_history_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s01_03_認知→初回取引_商品選定(karte)
s01_03 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s01_03_segment_goods_select_history_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s01_03_segment_goods_select_history_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s02_03_初回取引(投信)→成長パス_損益確認_アップ&クロスセル訴求(karte)
s02_03 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s02_03_segment_upsell_history_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s02_03_segment_upsell_history_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s03_02_初回取引(投信)→成長パス_他サービス認知(karte)
s03_02 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s03_02_segment_other_service_history_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s03_02_segment_other_service_history_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s04_05_初回ログインを促し初心者ページへ誘導
s04_05 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s04_05_segment_account_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s04_05_segment_account_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s04_06_NISA口座_つみたてＮＩＳＡ訴求
s04_06 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s04_06_segment_account_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s04_06_segment_account_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s05_09_「お困りでしょうか」アンケート
s05_09 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s05_09_segment_foreign_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s05_09_segment_foreign_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s05_10_国内IPO興味顧客への「IPOスピードキャッチ！（米国・中国）」訴求
s05_10 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s05_10_segment_foreign_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s05_10_segment_foreign_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s06_09_「興味がある商品を教えてください」アンケート
s06_09 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s06_09_segment_domestic_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s06_09_segment_domestic_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s06_10_海外ETF関心顧客に対する国内株式ETF（米国指数等が対象）訴求
s06_10 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s06_10_segment_domestic_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s06_10_segment_domestic_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),

-- s07_01_画面の見方チュートリアルを見せて銘柄詳細画面へリンクして訴求
s07_01 as(
  select
      sitecatalys_hash_value as mkdb_id
  from
    ${database_name.l2}.s07_01_segment_investment_karte
  where
    td_time_range(
        time
      , (select max(time) from ${database_name.l2}.s07_01_segment_investment_karte)
      , null
      , 'JST'
   	)
    and group_flag = 'A'
),


-- 全施策のmkdb_idを集める(※施策追加時に要修正)
tt500 as(
  select mkdb_id from s01_01
  union all select mkdb_id from s01_03
  union all select mkdb_id from s02_03
  union all select mkdb_id from s03_02
  union all select mkdb_id from s04_05
  union all select mkdb_id from s04_06
  union all select mkdb_id from s05_09
  union all select mkdb_id from s05_10
  union all select mkdb_id from s06_09
  union all select mkdb_id from s06_10
  union all select mkdb_id from s07_01
),

-- 全施策のmkdb_idをユニーク処理
tt501 as(
  select
    mkdb_id
  from
    tt500
  group by
    mkdb_id
),

-- 全施策の実施有無(flag)を付与(※施策追加時に要修正)
tt502 as (
  select
      tt501.mkdb_id
    , case when s01_01.mkdb_id is not null then true else false end as flag_01
    , case when s01_03.mkdb_id is not null then true else false end as flag_02
    , case when s02_03.mkdb_id is not null then true else false end as flag_03
    , case when s03_02.mkdb_id is not null then true else false end as flag_04
    , case when s04_05.mkdb_id is not null then true else false end as flag_id_04_05
    , case when s04_06.mkdb_id is not null then true else false end as flag_id_04_06
    , case when s05_09.mkdb_id is not null then true else false end as flag_id_05_09
    , case when s05_10.mkdb_id is not null then true else false end as flag_id_05_10
    , case when s06_09.mkdb_id is not null then true else false end as flag_id_06_09
    , case when s06_10.mkdb_id is not null then true else false end as flag_id_06_10
    , case when s07_01.mkdb_id is not null then true else false end as flag_id_07_01
  from
    tt501
    left join s01_01 on tt501.mkdb_id = s01_01.mkdb_id
    left join s01_03 on tt501.mkdb_id = s01_03.mkdb_id
    left join s02_03 on tt501.mkdb_id = s02_03.mkdb_id
    left join s03_02 on tt501.mkdb_id = s03_02.mkdb_id
    left join s04_05 on tt501.mkdb_id = s04_05.mkdb_id
    left join s04_06 on tt501.mkdb_id = s04_06.mkdb_id
    left join s05_09 on tt501.mkdb_id = s05_09.mkdb_id
    left join s05_10 on tt501.mkdb_id = s05_10.mkdb_id
    left join s06_09 on tt501.mkdb_id = s06_09.mkdb_id
    left join s06_10 on tt501.mkdb_id = s06_10.mkdb_id
    left join s07_01 on tt501.mkdb_id = s07_01.mkdb_id
)

select * from tt502