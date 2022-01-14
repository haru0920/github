insert into ${td.each.col02}.${td.each.col03}

-- L1のActivation結果テーブルから、本日のセグメント該当者データを取得
with tt001 as(
  select
      mkdb_id
    , sitecatalys_hash_value
    , cast(process_year as integer) as process_year
    , process_month
    , process_date
  from
    ${td.each.col05}.${td.each.col06}
  where
    td_time_range(
        time
      ,  (select max(time) from ${td.each.col05}.${td.each.col06})
      , null
      , 'JST'
    )
)

-- L2の配信済みテーブルから、顧客ごとのユニークなグループデータを取得
, tt002 as(
  select
      mkdb_id
    , max(sitecatalys_hash_value) as sitecatalys_hash_value
    , max(group_flag) as group_flag
  from
    ${td.each.col02}.${td.each.col03}
  group by
    mkdb_id
)

-- tt001に対してtt002を結合し、紐付かなかったmkdb_idは新規該当者なのでグループを付与
, tt003 as(
  select
  	  t1.mkdb_id
    , t1.sitecatalys_hash_value
  	, case when rank() over (order by random()) < round(count(*) over(), 0) * 0.98 then 'A' else 'B' end as group_flag
  from
    tt001 as t1
    left join
    tt002 as t2
    on t1.mkdb_id = t2.mkdb_id
  where
    t2.mkdb_id is null
)

-- tt001に対してtt002とtt003を結合し、tt002>tt003の値を優先にgroup_flagを採用
select
    t1.mkdb_id
  , t1.sitecatalys_hash_value
  , t1.process_year
  , t1.process_month
  , t1.process_date
  , case when t2.group_flag is not null then t2.group_flag else t3.group_flag end as group_flag
from
  tt001 as t1
  left join tt002 as t2 on t1.mkdb_id = t2.mkdb_id
  left join tt003 as t3 on t1.mkdb_id = t3.mkdb_id

