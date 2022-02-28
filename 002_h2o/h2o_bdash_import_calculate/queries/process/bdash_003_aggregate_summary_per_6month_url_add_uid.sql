-- hive
-- URLパラメータをパーシング処理
-- @TD enable_cartesian_product:true
with tt001 as(
  select
      t1.kaiin_seq
    , t1.ym
    , split(t1.ym, '[年月-]') datemonth
    , t1.page_url
    , t1.page_title
    , cast(t1.page_view_kaisu as int) as page_view_kaisu
    , cast(t1.page_stay_totaltime as int) as page_stay_totaltime
    , cast(t1.page_stay_maxtime as int) as page_stay_maxtime
    , cast(t1.page_stay_mintime as int) as page_stay_mintime
    , cast(t1.page_stay_avgtime as int) as page_stay_avgtime
    , t2.uid
  from
    ${database_name.l0_non_all_bdash}.bd_aggregate_summary_per_6month_url as t1
    left join ${database_name.l1_pd_all_cdc}.cdc_id_master as t2 on array_contains(t2.member_seq_array, t1.kaiin_seq)
  where
    t1.time in (select max(time) from ${database_name.l0_non_all_bdash}.bd_aggregate_summary_per_6month_url)
)

insert overwrite table ${database_name.l1_non_all_bdash}.${td.each.col03}
select
    kaiin_seq
  , ym
  , concat(datemonth[0], '-', lpad(datemonth[1], 2, 0), '-', '01') as ym_start
  , concat(datemonth[0], '-', lpad(datemonth[3], 2, 0), '-', '01') as ym_end
  , page_url
  , page_title
  , page_view_kaisu
  , page_stay_totaltime
  , page_stay_maxtime
  , page_stay_mintime
  , page_stay_avgtime
  , uid
from
  tt001