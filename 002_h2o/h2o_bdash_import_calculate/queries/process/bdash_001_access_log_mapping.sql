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
    , ROW_NUMBER() over() as row_number
  from
    ${database_name.l0_non_all_bdash}.bd_access_log as t1
    left join ${database_name.l1_pd_all_cdc}.cdc_id_master as t2 on array_contains(t2.member_seq_array, t1.kaiin_seq)
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_bdash}.bd_access_log)
),

-- パーシング処理後のマスターとのマッピング処理
tt101 as(
  select
      t1.kaiin_seq
    , t1.ymd
    , t1.page_url
    , t1.page_title
    , coalesce(t2.category_name_pc_brand, t4.brand_name, t5.category_name_pc_brand) as brand_name
    , t4.shouhin_name as shouhin_name
    , coalesce(t3.category_name_pc_item_1, t4.item_category_name_1, t6.category_name_pc_item_1) as item_category_name_1
    , coalesce(t3.category_name_pc_item_2, t4.item_category_name_2, t6.category_name_pc_item_2) as item_category_name_2
    , coalesce(t3.category_name_pc_item_3, t4.item_category_name_3, t6.category_name_pc_item_3) as item_category_name_3
    , t1.uid
    , t1.query_array
    , t1.query_cid
    , t1.query_ggcd
    , row_number
    , length(t5.category_id) as len_brand
    , length(t6.category_id) as len_item
  from
    tt001 as t1
    left join ${database_name.l1_non_all_hitmall}.hm_master_category_brand as t2 on t1.query_cid = t2.category_id
    left join ${database_name.l1_non_all_hitmall}.hm_master_category_item as t3 on t1.query_cid = t3.category_id
    left join ${database_name.l1_non_all_hitmall}.hm_master_goods_cast as t4 on t1.query_ggcd = t4.shouhin_kanri_no
    -- left join ${database_name.l1_non_all_hitmall}.hm_master_category_brand as t5 on array_contains(t1.query_array, t5.category_id)
    left join ${database_name.l1_non_all_hitmall}.hm_master_category_brand as t5 on t1.page_url like concat('%', t5.category_id, '%')
    -- left join ${database_name.l1_non_all_hitmall}.hm_master_category_item as t6 on array_contains(t1.query_array, t6.category_id)
    left join ${database_name.l1_non_all_hitmall}.hm_master_category_item as t6 on t1.page_url like concat('%', t6.category_id, '%')
),

tt102 as(
  select
      max(kaiin_seq) as kaiin_seq
    , max(ymd) as ymd
    , max(page_url) as page_url
    , max(page_title) as page_title
    , td_last(brand_name, len_brand) as brand_name
    , max(shouhin_name) as shouhin_name
    , td_last(item_category_name_1, len_item) as item_category_name_1
    , td_last(item_category_name_2, len_item) as item_category_name_2
    , td_last(item_category_name_3, len_item) as item_category_name_3
    , max(uid) as uid
    , max(query_array) as query_array
    , max(query_cid) as query_cid
    , max(query_ggcd) as query_ggcd
    , row_number
  from
    tt101
  group by
    row_number
)

insert overwrite table ${database_name.l1_non_all_bdash}.bd_access_log_add_category
select
    kaiin_seq
  , ymd
  , page_url
  , page_title
  , brand_name
  , shouhin_name
  , item_category_name_1
  , item_category_name_2
  , item_category_name_3
  , uid
  , query_array
  , query_cid
  , query_ggcd
from
  tt102