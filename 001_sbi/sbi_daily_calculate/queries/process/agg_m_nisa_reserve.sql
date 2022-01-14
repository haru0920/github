drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

select
    mkdb_id
  , input_file_id1
  , input_file_id2
  , group_id
  , class_code
  , support_class
  , i_user_code
  , record_date
  , self_div
  , dealer_code
  , occupation1
  , occupation2
  , internet_kbn
  , hoyu_koza_g1
  , isa_dealer_code
  , cast(kaituke_y as integer) as kaituke_y
  , shori_ymd
  , isa_keiyaku_kbn
  , cast(isa_hkzwk_gendo_gk as integer) as isa_hkzwk_gendo_gk
  , isa_hkzwk_shiyo_gk_fugo
  , cast(isa_hkzwk_shiyo_gk as integer) as isa_hkzwk_shiyo_gk
  , isa_wkover_ymd
  , nisa_shur
from
  ${td.each.col05}.${td.each.col06}
where
  -- 最新のデータを対象
  td_time_range(
      time
    , (select max(time) from ${td.each.col05}.${td.each.col06})
    , null
    , 'JST'
  )
  -- mkdb_id is nullは紐付かないので除外
  and mkdb_id is not null
  -- 当該年以外は不要なので除外
  and kaituke_y = cast(td_time_format(${session_unixtime}, 'yyyy', 'JST') as varchar)