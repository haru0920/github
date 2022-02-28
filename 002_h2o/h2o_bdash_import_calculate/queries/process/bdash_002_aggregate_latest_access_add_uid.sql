-- hive
-- URLパラメータをパーシング処理
-- @TD enable_cartesian_product:true
with tt001 as(
  select
      t1.kaiin_seq
    , split(t1.saishin_houmon_date_time, '[/: ]') as datetime01
    , split(t1.saishin_shouhinetsuran_date_time, '[/: ]') as datetime02
    , t2.uid
  from
    ${database_name.l0_non_all_bdash}.bd_aggregate_latest_access as t1
    left join ${database_name.l1_pd_all_cdc}.cdc_id_master as t2 on array_contains(t2.member_seq_array, t1.kaiin_seq)
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_bdash}.bd_aggregate_latest_access)
)

insert overwrite table ${database_name.l1_non_all_bdash}.${td.each.col03}
select
    kaiin_seq
  , concat(datetime01[0], '-', lpad(datetime01[1], 2, 0), '-', lpad(datetime01[2], 2, 0), ' ', lpad(datetime01[3], 2, 0), ':', lpad(datetime01[4], 2, 0), ':', '00') as saishin_houmon_date_time
  , concat(datetime02[0], '-', lpad(datetime02[1], 2, 0), '-', lpad(datetime02[2], 2, 0), ' ', lpad(datetime02[3], 2, 0), ':', lpad(datetime02[4], 2, 0), ':', '00') as saishin_shouhinetsuran_date_time
  , uid
from
  tt001