-- hive
-- URLパラメータをパーシング処理
-- @TD enable_cartesian_product:true
with tt001 as(
  select
      td_time_parse(t1.ymd, 'JST') as time
    , t1.kaiin_seq
    , t1.ymd
    , t1.page_url
    , t1.page_title
    , t2.uid
    , split(regexp_replace(parse_url(t1.page_url, 'QUERY'), '[^&][A-Za-z0-9]*=', ''), '&') as query_array
    , parse_url(t1.page_url, 'QUERY', 'cid') as query_cid
    , parse_url(t1.page_url, 'QUERY', 'ggcd') as query_ggcd
  from
    ${database_name.l0_non_all_bdash}.bd_access_log as t1
    left join ${database_name.l1_pd_all_cdc}.cdc_id_master as t2 on array_contains(t2.member_seq_array, t1.kaiin_seq)
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_bdash}.bd_access_log)
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
insert overwrite table ${database_name.l1_non_all_bdash}.bd_access_log_add_category
select
    t1.kaiin_seq
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
<<<<<<< HEAD
  left join ${database_name.l1_non_all_hitmall}.hm_master_category_brand as t2 on t1.query_cid = t2.category_id
=======
  left join ${database_name.1_non_all_hitmall}.hm_master_category_brand as t2 on t1.query_cid = t2.category_id
>>>>>>> 59f3b06cd29a7d23bbb91b350567b585d1e85403
  left join tt002 as t3 on t1.query_cid = t3.category_id
  left join tt003 as t4 on t1.query_cid = t4.category_id
  left join tt004 as t5 on t1.query_cid = t5.category_id
  left join ${database_name.l1_non_all_hitmall}.hm_master_goods_cast as t6 on t1.query_ggcd = t6.shouhin_kanri_no
  left join ${database_name.l1_non_all_hitmall}.hm_master_category_brand as t7 on array_contains(t1.query_array, t7.category_id)
  left join tt002 as t8 on array_contains(t1.query_array, t8.category_id)
  left join tt002 as t9 on array_contains(t1.query_array, t9.category_id)
  left join tt002 as t10 on array_contains(t1.query_array, t10.category_id)
  