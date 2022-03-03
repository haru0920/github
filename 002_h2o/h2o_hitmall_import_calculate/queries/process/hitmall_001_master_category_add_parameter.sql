-- hive
-- @TD enable_cartesian_product:true
-- master_categoryからブランド名のマスタを作成
with tt001 as(
  select
      site_name
    , category_id
    , category_name_pc as category_name_pc_brand
    , cast(null as string) as category_name_pc_item_1
    , cast(null as string) as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3
    , cast(null as string) as category_name_pc_collection
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and (category_id rlike '^bbs_.*'
    or (site_name = 'BEAUTY' 
      and category_id rlike '^b_bbs_[a-z0-9]*$' ))
),

-- master_categoryからアイテムカテゴリ名のマスタを作成(アイテムカテゴリ名1)
tt101 as(
  select
      site_name
    , category_id
    , cast(null as string) as category_name_pc_brand
    , category_name_pc as category_name_pc_item_1
    , cast(null as string) as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3
    , cast(null as string) as category_name_pc_collection
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and site_name = 'BEAUTY'
    and category_id rlike '^b_bbs_(ccnl|hhrm|kdcr|pdio|scpb)_[a-z0-9_]*'
),

-- master_categoryからアイテムカテゴリ名のマスタを作成(アイテムカテゴリ名1)
tt102 as(
  select
      site_name
    , category_id
    , cast(null as string) as category_name_pc_brand
    , category_name_pc as category_name_pc_item_1
    , cast(null as string) as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3
    , cast(null as string) as category_name_pc_collection
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and category_id rlike 'bi_[a-z0-9]*$'
),

-- master_categoryからアイテムカテゴリ名のマスタを作成(アイテムカテゴリ名2)
tt103 as(
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

-- master_categoryからアイテムカテゴリ名のマスタを作成(アイテムカテゴリ名3)
tt104 as(
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

-- master_categoryからアイテムカテゴリ名のマスタを作成(アイテムカテゴリ名1/2)
tt105 as(
  select
      t1.site_name
    , t1.category_id
    , cast(null as string) as category_name_pc_brand
    , t2.category_name_pc_item_1 as category_name_pc_item_1
    , t1.category_name_pc_item as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3
    , cast(null as string) as category_name_pc_collection
  from
    tt103 as t1
    left join tt102 as t2 on t1.category_id like concat(t2.category_id, '%')
),

-- master_categoryからアイテムカテゴリ名のマスタを作成(アイテムカテゴリ名1/2/3)
tt106 as(
  select
      t1.site_name
    , t1.category_id
    , cast(null as string) as category_name_pc_brand
    , t2.category_name_pc_item_1
    , t2.category_name_pc_item_2
    , t1.category_name_pc_item as category_name_pc_item_3
    , cast(null as string) as category_name_pc_collection
  from
    tt104 as t1
    left join tt105 as t2 on t1.category_id like concat(t2.category_id, '%')
),

-- master_categoryからアイテムカテゴリ名のマスタを作成
tt107 as(
  select site_name, category_id, category_name_pc_brand, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3, category_name_pc_collection from tt101 union all
  select site_name, category_id, category_name_pc_brand, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3, category_name_pc_collection from tt102 union all
  select site_name, category_id, category_name_pc_brand, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3, category_name_pc_collection from tt105 union all
  select site_name, category_id, category_name_pc_brand, category_name_pc_item_1, category_name_pc_item_2, category_name_pc_item_3, category_name_pc_collection from tt106
),

-- master_categoryからコレクション名のマスタを作成
tt201 as(
  select
      site_name
    , category_id
    , cast(null as string) as category_name_pc_brand
    , cast(null as string) as category_name_pc_item_1
    , cast(null as string) as category_name_pc_item_2
    , cast(null as string) as category_name_pc_item_3   
    , category_name_pc as category_name_pc_collection
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    and site_name = 'BEAUTY'
    and category_id rlike '^b_bbs_(?!.*(ccnl|hhrm|kdcr|pdio|scpb))[a-z0-9]*_[a-z0-9]*' 
),

-- マスターの母集団となるリスト
tt301 as(
  select
    site_name
  , category_id
  from
    ${database_name.l0_non_all_hitmall}.hm_master_category as t1
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
    -- 取込データのノイズ対応
    and category_id not in ('top')
)

-- 分割したマスタを統合
insert overwrite table ${database_name.l1_non_all_hitmall}.${td.each.col03}
select
    t1.site_name
  , t1.category_id
  , t2.category_name_pc_brand
  , t3.category_name_pc_item_1
  , t3.category_name_pc_item_2
  , t3.category_name_pc_item_3
  , t4.category_name_pc_collection
from
  tt301 as t1
  left join tt001 as t2 on t1.category_id = t2.category_id
  left join tt107 as t3 on t1.category_id = t3.category_id
  left join tt201 as t4 on t1.category_id = t4.category_id