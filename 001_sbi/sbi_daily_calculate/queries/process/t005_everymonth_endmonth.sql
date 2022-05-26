--実行日は毎月1日
--前月分のt005_everymonth_endmonthからt005_everymonth_endmonth_historyを作成
--insert into ${database_name.l0.mkdb_transaction}.t005_everymonth_endmonth_history
insert into ${database_name.l1}.t005_everymonth_endmonth_history
( 
select
   a.mkdb_id
   ,case when ( b.lost_count_past_to_3month_ago + b.lost_count_2month_ago ) is null then 0 
    else b.lost_count_past_to_3month_ago + b.lost_count_2month_ago end as lost_count_past_to_3month_ago
   ,b.ipo_lost_count_endmonth_flag as ipo_lost_count_endmonth_flag
   ,b.latest_target_month as latest_target_month
   ,b.ipo_lost_point_endmanth_flag as ipo_lost_point_endmanth_flag
   ,b.ipo_lost_point_available_flag as ipo_lost_point_available_flag
   ,b.nisa_foreign_owned_endmonth_flag as nisa_foreign_owned_endmonth_flag
  from 
   ${database_name.l1_id_master}.id_master as a
  LEFT OUTER JOIN ${td.each.col02}.${td.each.col03} as b
  ON a.mkdb_id = b.mkdb_id
  where 
   b.time = (select max(time) from ${td.each.col02}.${td.each.col03}) 
   or b.time is null
);

drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as
--m_ipo_bosyu_user_statusはデータ重複があるためユニークレコードを抽出(期間：前々月2日〜バッチ実行期間まで)
with tt001_01 as (
  SELECT 
    mkdb_id,
    ibus_bosyu_number AS ibus_bosyu_number,
  max_by(
    ibus_elected_status,
    time
  ) AS ibus_elected_status,
  max_by(
    ibus_application_date,
    time
  ) AS ibus_application_date,
  max_by(
    ibus_acquire_point,
    time
  ) AS ibus_acquire_point
FROM
  ${database_name.l0.mkdb_transaction}.m_ipo_bosyu_user_status
WHERE
  TD_TIME_RANGE(time,
    TD_TIME_FORMAT(TD_DATE_TRUNC('month',
        td_time_add(td_scheduled_time(),
          '-40d',
          'JST'),
        'JST'),
      'yyyy-MM',
      'JST')|| '-02'--前々月2日
    -- ,td_scheduled_time() --バッチ実行日（毎月1日）
    ,TD_TIME_ADD(td_scheduled_time(),'1d') --バッチ実行日（毎月1日）
    ,'JST')
GROUP BY
  mkdb_id,
  ibus_bosyu_number
), 
tt001_02 as(
  select 
    a.mkdb_id
    ,max(b.lost_count_1month_ago) as lost_count_1month_ago
    ,max(c.lost_count_2month_ago) as lost_count_2month_ago
    ,max(d.ipo_lost_point_endmanth_flag) as ipo_lost_point_endmanth_flag
  from 
    tt001_01 as a 
  LEFT OUTER JOIN 
  (  select --直近1ヶ月前の落選回数を取得
     mkdb_id
     , count(*) as lost_count_1month_ago
     from tt001_01
     where 
     TD_TIME_RANGE( 
                    td_time_parse(
                      (substr(ibus_application_date ,1,4) || '-' || substr(ibus_application_date ,5,2))
                    )
                    ,TD_TIME_FORMAT(
                        TD_DATE_TRUNC('month',td_time_add(td_scheduled_time(),'-1d', 'JST'),'JST') 
                        ,'yyyy-MM'
                        ,'JST'
                     ) || '-01'--前月1日
                    --,td_scheduled_time() --バッチ実行日（毎月1日）
                    ,TD_TIME_ADD(td_scheduled_time(),'1d')  --バッチ実行日（毎月1日）
                    ,'JST')  
       and ibus_elected_status in ('3','5') --3:落選または5:繰り上げならず
       group by mkdb_id   ) as b
  ON a.mkdb_id = b.mkdb_id
  LEFT OUTER JOIN  (  select --直近２ヶ月前の落選回数を取得
         mkdb_id
        , count(*) as lost_count_2month_ago
     from tt001_01
     where 
     TD_TIME_RANGE( 
                   td_time_parse(
                      (substr(ibus_application_date ,1,4) || '-' || substr(ibus_application_date ,5,2))
                    )
                  ,TD_TIME_FORMAT(
                      TD_DATE_TRUNC('month',td_time_add(td_scheduled_time(),'-40d', 'JST'),'JST') 
                      ,'yyyy-MM'
                      ,'JST'
                   ) || '-01'--前前月1日
                  ,TD_TIME_FORMAT(
                      TD_DATE_TRUNC('month',td_time_add(td_scheduled_time(),'-1d', 'JST'),'JST') 
                      ,'yyyy-MM'
                      ,'JST'
                   ) || '-01'--前月1日
                  ,'JST')  
       and ibus_elected_status in ('3','5') --3:落選または5:繰り上げならず
       group by mkdb_id ) as c
  ON a.mkdb_id = c.mkdb_id
  LEFT OUTER JOIN 
  ( select mkdb_id -- 21. IPOポイント利用落選フラグ_月末時点情報
           ,1 as ipo_lost_point_endmanth_flag
    from ${database_name.l0.mkdb_transaction}.m_ipo_bosyu_user_status
    where 
      TD_TIME_RANGE( 
                    td_time_parse(
                      (substr(ibus_application_date ,1,4) || '-' || substr(ibus_application_date ,5,2))
                    )
                    ,TD_TIME_FORMAT(
                        TD_DATE_TRUNC('month',td_time_add(td_scheduled_time(),'-1d', 'JST'),'JST') 
                        ,'yyyy-MM'
                        ,'JST'
                     ) || '-01'--前月1日
                    -- ,td_scheduled_time() --バッチ実行日（毎月1日）
                    ,TD_TIME_ADD(td_scheduled_time(),'1d')  --バッチ実行日（毎月1日）
                    ,'JST')  
      and ibus_elected_status in ('3','5')  --3:落選または5:繰り上げならず
      and CAST(ibus_acquire_point as int) > 0 
    group by mkdb_id
  ) as d
  ON a.mkdb_id = d.mkdb_id
  group by a.mkdb_id
)
,  tt001 as(
select 
  b.mkdb_id
  , case when b.latest_target_month is null and a.ipo_lost_point_endmanth_flag =1 then TD_TIME_FORMAT(TD_DATE_TRUNC('month',td_scheduled_time(),'JST'),'yyyy-MM','JST')
         when b.latest_target_month is not null and a.ipo_lost_point_endmanth_flag =1 and b.latest_target_month <= 
             TD_TIME_FORMAT(
                              TD_DATE_TRUNC('month',td_time_add(td_scheduled_time(),'-80d', 'JST'),'JST') --3ヶ月前の年月
                              ,'yyyy-MM'
                              ,'JST'
              )  then TD_TIME_FORMAT(TD_DATE_TRUNC('month',td_scheduled_time(),'JST'),'yyyy-MM','JST') --前回の施策実施月から3ヶ月以上経過していたら当月を入れる
  else b.latest_target_month --上記に当てはまらない場合は前月の値をそのまま
  end as latest_target_month -- 直近配信該当月
  ,case when a.ipo_lost_point_endmanth_flag = 1 then 1
   else 0 end as ipo_lost_point_endmanth_flag ---- 21. IPOポイント利用落選フラグ_月末時点情報
  ,b.lost_count_past_to_3month_ago
  ,case when a.lost_count_1month_ago > 0 then a.lost_count_1month_ago
   else 0 end lost_count_1month_ago --直近1ヶ月前の落選回数
  ,case when a.lost_count_2month_ago > 0 then a.lost_count_2month_ago 
   else 0 end lost_count_2month_ago --直近2ヶ月前の落選回数
from ${database_name.l1}.t005_everymonth_endmonth_history  as b 
left outer join tt001_02 as a
on a.mkdb_id = b.mkdb_id
where  TD_TIME_RANGE(b.time,(select max(time) from ${database_name.l1}.t005_everymonth_endmonth_history ),null,'JST') 
)
--NISA枠外株保有フラグ_月末時点情報取得用SQL
, tt002 as (
  select mkdb_id
  from ${database_name.l0.mkdb_attribute}.m_fd_bond_balance
  where TD_TIME_RANGE(
                      time
                      ,(select max(time) from ${database_name.l0.mkdb_attribute}.m_fd_bond_balance)
                      ,null
                      ,'JST')
             --and record_date = TD_TIME_FORMAT(TD_SCHEDULED_TIME(),'yyyyMMdd','JST')
             and product_code = '81'
             and specific_account_type in ('4','8')
             and sec_trade_country_code = '304'
  group by mkdb_id
)

select 
  b.mkdb_id
  ,b.ipo_lost_point_endmanth_flag
  ,b.lost_count_past_to_3month_ago as lost_count_past_to_3month_ago
  ,b.lost_count_2month_ago as lost_count_2month_ago
  ,b.lost_count_1month_ago as lost_count_1month_ago
  ,case when (b.lost_count_past_to_3month_ago + b.lost_count_2month_ago + b.lost_count_1month_ago) /10 <> (b.lost_count_past_to_3month_ago + b.lost_count_2month_ago) /10 then 1
          else 0
          end as ipo_lost_count_endmonth_flag
  ,b.latest_target_month
,case when b.latest_target_month = TD_TIME_FORMAT(td_scheduled_time(),'yyyy-MM','JST') then 1
         when b.latest_target_month is NULL then 1
         else 0
         end as ipo_lost_point_available_flag
,case when c.mkdb_id is not null then 1
         else 0 
         end nisa_foreign_owned_endmonth_flag
from
 tt001 as b
LEFT OUTER JOIN tt002 as c
ON b.mkdb_id = c.mkdb_id
;
