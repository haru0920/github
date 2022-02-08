insert into ${database_name.l1_non_all_bdash}.bd_access_log_add_category --

-- presto
-- id_masterと突合しuidを取得
with tt001 as(
  select
      t1.time
    , t1.kaiin_seq
    , t1.ymd
    , t1.page_url
    , t1.page_title
    , t2.uid
    , t1.query_array
    , t1.query_cid
    , t1.query_ggcd
  from
    ${database_name.l1_non_all_bdash}.tmp_bd_access_log_url_parse as t1
    left join ${database_name.l1_pd_all_cdc}.cdc_id_master as t2 on contains(t2.member_seq_array, t1.kaiin_seq)
),

tt002 as(
  select
      site_name
    , category_id
    , category_name_pc_item
    , categoru_item_no
  from
    ${database_name.l1_non_all_hitmall}.hm_master_category_item
  where
    categoru_item_no = 1
),

tt003 as(
  select
      site_name
    , category_id
    , category_name_pc_item
    , categoru_item_no
  from
    ${database_name.l1_non_all_hitmall}.hm_master_category_item
  where
    categoru_item_no = 2
),

tt004 as(
  select
      site_name
    , category_id
    , category_name_pc_item
    , categoru_item_no
  from
    ${database_name.l1_non_all_hitmall}.hm_master_category_item
  where
    categoru_item_no = 3
)

-- パーシング処理後のマスターとのマッピング処理
select
    t1.time
  , t1.kaiin_seq
  , t1.ymd
  , t1.page_url
  , t1.page_title
  , coalesce(t2.category_name_pc_brand, t6.brand_name, t7.category_name_pc_brand) as brand_name
  , t6.shouhin_name as shouhin_name
  , coalesce(t3.category_name_pc_item, t6.item_category_name_1, t8.category_name_pc_item) as item_category_name_1
  , coalesce(t4.category_name_pc_item, t6.item_category_name_2, t9.category_name_pc_item) as item_category_name_2
  , coalesce(t5.category_name_pc_item, t6.item_category_name_3, t10.category_name_pc_item) as item_category_name_3
  , t1.uid
  , t1.query_array
  , t1.query_cid
  , t1.query_ggcd
from
  tt001 as t1
  left join ${database_name.l1_non_all_hitmall}.hm_master_category_brand as t2 on t1.query_cid = t2.category_id
  left join tt002 as t3 on t1.query_cid = t3.category_id
  left join tt003 as t4 on t1.query_cid = t4.category_id
  left join tt004 as t5 on t1.query_cid = t5.category_id
  left join ${database_name.l1_non_all_hitmall}.hm_master_goods_cast as t6 on t1.query_ggcd = t6.shouhin_kanri_no
  left join ${database_name.l1_non_all_hitmall}.hm_master_category_brand as t7 on contains(t1.query_array, t7.category_id)
  left join tt002 as t8 on contains(t1.query_array, t8.category_id)
  left join tt002 as t9 on contains(t1.query_array, t9.category_id)
  left join tt002 as t10 on contains(t1.query_array, t10.category_id)
