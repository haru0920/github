-- hive
-- master_categoryからアイテムカテゴリ名のマスタを作成
-- @TD enable_cartesian_product:true
with tt001 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_item_1
    , cast(null as string) as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and site_name = 'BEAUTY'
    and category_id rlike '^b_bbs_(ccnl|hhrm|kdcr|pdio|scpb)_[a-z0-9_]*'
),

tt002 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_item_1
    , cast(null as string) as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and category_id rlike 'bi_[a-z0-9]*$'
),

tt003 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_item
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and category_id rlike 'bi_[a-z0-9]*_[a-z0-9]*$'
),

tt004 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_item
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and category_id rlike 'bi_[a-z0-9]*_[a-z0-9]*_[a-z0-9]*$'
),

tt101 as(
  select
      t1.site_name
    , t1.category_id
    , t2.category_name_pc_item_1 as category_name_pc_item_1
    , t1.category_name_pc_item as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3
  from
    tt003 as t1
    left join tt002 as t2 on t1.category_id like concat(t2.category_id, '%')
),

tt102 as(
  select
      t1.site_name
    , t1.category_id
    , t2.category_name_pc_item_1
    , t2.category_name_pc_item_2
    , t1.category_name_pc_item as category_name_pc_item_3
  from
    tt004 as t1
    left join tt101 as t2 on t1.category_id like concat(t2.category_id, '%')
)

insert overwrite table ${database_name.l1_non_all_hitmall}.hm_master_category_item
select site_name, category_id, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3 from tt001 union all
select site_name, category_id, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3 from tt002 union all
select site_name, category_id, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3 from tt101 union all
select site_name, category_id, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3 from tt102