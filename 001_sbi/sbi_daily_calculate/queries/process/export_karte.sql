-- s01_01_認知→初回取引_口座開設初期設定(karte)
with tt001 as(
  select
      sitecatalys_hash_value as mkdb_id
    , true as flag_01
    , false as flag_02
    , false as flag_03
    , false as flag_04
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
)

-- s01_03_認知→初回取引_商品選定(karte)
, tt002 as(
  select
      sitecatalys_hash_value as mkdb_id
    , false as flag_01
    , true as flag_02
    , false as flag_03
    , false as flag_04
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
)

-- s02_03_初回取引(投信)→成長パス_損益確認_アップ&クロスセル訴求(karte)
, tt003 as(
  select
      sitecatalys_hash_value as mkdb_id
    , false as flag_01
    , false as flag_02
    , true as flag_03
    , false as flag_04
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
)

-- s03_02_初回取引(投信)→成長パス_他サービス認知(karte)
, tt004 as(
  select
      sitecatalys_hash_value as mkdb_id
    , false as flag_01
    , false as flag_02
    , false as flag_03
    , true as flag_04
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
)

-- 各施策データを連結
, tt101 as(
select mkdb_id, flag_01, flag_02, flag_03, flag_04 from tt001 union all
select mkdb_id, flag_01, flag_02, flag_03, flag_04 from tt002 union all
select mkdb_id, flag_01, flag_02, flag_03, flag_04 from tt003 union all
select mkdb_id, flag_01, flag_02, flag_03, flag_04 from tt004
)

-- データを集約
select
    mkdb_id
  , max(flag_01) as flag_01
  , max(flag_02) as flag_02
  , max(flag_03) as flag_03
  , max(flag_04) as flag_04
from
  tt101
group by
  mkdb_id