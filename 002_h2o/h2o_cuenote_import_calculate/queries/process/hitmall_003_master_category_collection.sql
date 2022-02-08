-- hive
-- master_categoryからコレクション名のマスタを作成
insert overwrite table ${database_name.l1_non_all_hitmall}.hm_master_category_collection
select
    site_name
  , category_id
  , category_name_pc as category_name_pc_collection
from
  ${database_name.l0_non_all_hitmall}.hm_master_category as t1
where
  t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
  and site_name = 'BEAUTY'
  and category_id rlike '^b_bbs_(?!.*(ccnl|hhrm|kdcr|pdio|scpb))[a-z0-9]*_[a-z0-9]*' 
