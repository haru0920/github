--drop table if exists incudata_test.t005_everymonth_20;
--create table incudata_test.t005_everymonth_20 as
drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as
-- 12.取引履歴有無(国内株)_毎月20日時点情報
with tt001 as(
select mkdb_id
from ${database_name.l0.mkdb_transaction}.m_trade_date_mm
where 
td_time_range(
        time
      , (select max(time) from ${database_name.l0.mkdb_transaction}.m_trade_date_mm)
      , null
      , 'JST'
) and goods='現物'
group by mkdb_id
)
-- 13.優待検索画面PV有無_毎月20日時点情報
,  tt002 as(
select sitecatalys_hash_value 
from ${database_name.l1_id_master}.modified_td_pageview
where 
TD_TIME_RANGE(
  time
  ,TD_TIME_STRING( 
    TD_DATE_TRUNC(
        'month',
        TD_DATE_TRUNC('month',TD_SCHEDULED_TIME(),'JST')-1,
        'JST'
    )
    ,'M!', 'JST') || '-20'
  -- ,TD_DATE_TRUNC('day', TD_SCHEDULED_TIME(), 'JST')
  ,TD_DATE_TRUNC('day', TD_TIME_ADD(td_scheduled_time(),'1d'), 'JST')
  ,'JST'
) 
and td_url like 'https://site0.sbisec.co.jp/marble/domestic/benefit/yutaisearch.do?%'
group by sitecatalys_hash_value
)

select 
t1.mkdb_id
, t1.sitecatalys_hash_value
, case when tt001.mkdb_id is not null then 1
       else 0 
       end as transaction_domestic_history_20_flag -- 12.取引履歴有無(国内株)_毎月20日時点情報
, case when tt002.sitecatalys_hash_value is not null then 1
       else 0 
       end as search_incentives_pv_20_flag -- 13.優待検索画面PV有無_毎月20日時点情報
from 
${database_name.l1_id_master}.id_master as t1
left join tt001
on t1.mkdb_id = tt001.mkdb_id
left join tt002
on t1.sitecatalys_hash_value = tt002.sitecatalys_hash_value;