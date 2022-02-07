-- hive
-- master_goodsの型変換
insert overwrite table ${database_name.l1_non_all_hitmall}.hm_master_goods_cast
select
    site_name
  , shouhin_name
  , shouhin_kanri_no
  , shouhin_no
  , shop_name
  , brand_name
  , item_category_name_1
  , item_category_name_2
  , item_category_name_3
  , td_time_format(unix_timestamp(koukai_kaishi_date_time_pc, 'yyyy/M/d H:mm'), 'yyyy-MM-dd HH:mm:ss') as koukai_kaishi_date_time_pc
  , td_time_format(unix_timestamp(koukai_shuryo_date_time_pc, 'yyyy/M/d H:mm'), 'yyyy-MM-dd HH:mm:ss') as koukai_shuryo_date_time_pc
  , td_time_format(unix_timestamp(hanbai_kaishi_date_time_pc, 'yyyy/M/d H:mm'), 'yyyy-MM-dd HH:mm:ss') as hanbai_kaishi_date_time_pc
  , td_time_format(unix_timestamp(hanbai_shuryo_date_time_pc, 'yyyy/M/d H:mm'), 'yyyy-MM-dd HH:mm:ss') as hanbai_shuryo_date_time_pc
  , cast(kakaku_zeinuki as int) as kakaku_zeinuki
  , cast(kakaku_zeikomi as int) as kakaku_zeikomi
from
  ${database_name.l0_non_all_hitmall}.hm_master_goods
