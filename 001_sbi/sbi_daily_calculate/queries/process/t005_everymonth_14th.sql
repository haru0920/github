drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as
-- 14.優待銘柄取引有無(国内株)_毎月14日時点情報
with tt001 as(
  select mkdb_id
  from ${database_name.l0.mkdb_transaction}.m_st_sec as a inner join ${database_name.l0.common_master}.yutai_master as b 
  on a.brand_cd = lpad(b.yuutaimeigara_code,5,'0')
  where 
    td_time_range(
          b.time
        , (select max(time) from ${database_name.l0.common_master}.yutai_master)
        , null
        , 'JST'
    ) -- 東洋経済新報社データの最新を取得
    
    and
    TD_TIME_RANGE(
      TD_TIME_PARSE(a.base_date,'JST')
      ,TD_TIME_STRING( 
        TD_DATE_TRUNC(
            'month',
            TD_DATE_TRUNC('month',TD_SCHEDULED_TIME(),'JST')-1, 
            'JST'
        )
        ,'M!', 'JST') || '-14'
      ,TD_DATE_TRUNC('day', TD_SCHEDULED_TIME(), 'JST') 
      ,'JST'
    ) -- base_timeが前月14日〜今月13日を対象
  group by mkdb_id 
)
-- 15.口座開設有無_毎月14日時点情報(信用)
,  tt002 as(
  select mkdb_id
  from ${database_name.l0.mkdb_transaction}.m_svc_acct_profile 
  where 
  profile_name='AccountMode' 
  and profile_value='MARGIN'
  group by mkdb_id
)

select 
t1.mkdb_id
, case when tt001.mkdb_id is not null then 1
       else 0 
       end as transaction_domestic_incentives_history_14_flag --優待銘柄取引有無(国内株)_毎月14日時点情報
, case when tt002.mkdb_id is not null then 1
       else 0 
       end as account_margin_open_14_flag --口座開設有無_毎月14日時点情報(信用)
from 
${database_name.l1_id_master}.id_master as t1 
left join tt001
on t1.mkdb_id = tt001.mkdb_id
left join tt002
on t1.mkdb_id = tt002.mkdb_id;
