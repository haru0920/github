-- hive
-- master_categoryからアイテムカテゴリ名のマスタを作成
with tt001 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_item
    , 1 as categoru_item_no
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and ((site_name = 'BEAUTY' and category_id rlike '^b_bbs_(ccnl|hhrm|kdcr|pdio|scpb)_[a-z0-9_]*')
    or category_id rlike 'bi_[a-z0-9]*$')
),

tt002 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_item
    , 2 as categoru_item_no
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and category_id rlike 'bi_[a-z0-9]*_[a-z0-9]*$'
),

tt003 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_item
    , 3 as categoru_item_no
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and category_id rlike 'bi_[a-z0-9]*_[a-z0-9]*_[a-z0-9]*$'
)

insert overwrite table ${database_name.l1_non_all_hitmall}.hm_master_category_item
select site_name, category_id, category_name_pc_item, categoru_item_no from tt001 union all
select site_name, category_id, category_name_pc_item, categoru_item_no from tt002 union all
select site_name, category_id, category_name_pc_item, categoru_item_no from tt003
