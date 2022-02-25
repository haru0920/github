-- hive
-- URLパラメータをパーシング処理
-- @TD enable_cartesian_product:true
with tt001 as(
  select
      td_time_parse(t1.ymd, 'JST') as time
    , t1.visitor_id
    , t1.kaiin_seq
    , t1.ymd
    , t1.device_category
    , t1.browser
    , t1.page_url
    , t1.page_title
    , t1.action_type
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
      t1.time
    , t1.visitor_id
    , t1.kaiin_seq
    , t1.ymd
    , t1.device_category
    , t1.browser
    , t1.page_url
    , t1.page_title
    , t1.action_type
    , coalesce(t2.category_name_pc_brand, t3.brand_name, t4.category_name_pc_brand) as brand_name
    , t3.shouhin_name as shouhin_name
    , coalesce(t2.category_name_pc_item_1, t3.item_category_name_1, t4.category_name_pc_item_1) as item_category_name_1
    , coalesce(t2.category_name_pc_item_2, t3.item_category_name_2, t4.category_name_pc_item_2) as item_category_name_2
    , coalesce(t2.category_name_pc_item_3, t3.item_category_name_3, t4.category_name_pc_item_3) as item_category_name_3
    , t1.uid
    , t1.query_array
    , t1.query_cid
    , t1.query_ggcd
    , row_number
    , length(t4.category_id) as match_length
  from
    tt001 as t1
    left join ${database_name.l1_non_all_hitmall}.hm_master_category_add_parameter as t2 on t1.query_cid = t2.category_id
    left join ${database_name.l1_non_all_hitmall}.hm_master_goods_cast as t3 on t1.query_ggcd = t3.shouhin_kanri_no
    -- left join ${database_name.l1_non_all_hitmall}.hm_master_category_add_parameter as t4 on array_contains(t1.query_array, t4.category_id)
    left join ${database_name.l1_non_all_hitmall}.hm_master_category_add_parameter as t4 on t1.page_url like concat('%', t4.category_id, '%')
),

-- レコードのユニーク処理
-- max：どのレコードを採用しても同じ場合に使用、case：longest match(td_last)を優先、左記がNULLの場合はmaxを使用　←　like joinをしているため必要
tt102 as(
  select
      max(time) as time
    , max(visitor_id) as visitor_id
    , max(kaiin_seq) as kaiin_seq
    , max(ymd) as ymd
    , max(device_category) as device_category
    , max(browser) as browser
    , max(page_url) as page_url
    , max(page_title) as page_title
    , max(action_type) as action_type
    , case
        when td_last(brand_name, match_length) is not null then td_last(brand_name, match_length)
        else max(brand_name)
      end as brand_name
    , max(shouhin_name) as shouhin_name
    , case
        when td_last(item_category_name_1, match_length) is not null then td_last(item_category_name_1, match_length)
        else max(item_category_name_1)
      end as item_category_name_1
    , case
        when td_last(item_category_name_2, match_length) is not null then td_last(item_category_name_2, match_length)
        else max(item_category_name_2)
      end as item_category_name_2
    , case
        when td_last(item_category_name_3, match_length) is not null then td_last(item_category_name_3, match_length)
        else max(item_category_name_3)
      end as item_category_name_3
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

insert overwrite table ${database_name.l1_non_all_bdash}.${td.each.col03}
select
    time
  , visitor_id
  , kaiin_seq
  , ymd
  , device_category
  , browser
  , page_url
  , page_title
  , action_type
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