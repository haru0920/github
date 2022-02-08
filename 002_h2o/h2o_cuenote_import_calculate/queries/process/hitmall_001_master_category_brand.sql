-- hive
-- master_categoryからブランド名のマスタを作成
insert overwrite table ${database_name.l1_non_all_hitmall}.hm_master_category_brand
select
    site_name
  , category_id
  , category_name_pc as category_name_pc_brand
from
  ${database_name.l0_non_all_hitmall}.hm_master_category as t1
where
  t1.time in (select max(time) from ${database_name.l0_non_all_hitmall}.hm_master_category)
  and (category_id rlike '^bbs_.*'
  or (site_name = 'BEAUTY' 
    and category_id rlike '^b_bbs_[a-z0-9]*$' ))
