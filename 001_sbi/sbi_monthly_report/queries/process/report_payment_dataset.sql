insert into ${td.each.col02}.${td.each.col03}

-- report_payment_datamartのデータを取得
with tt001 as(
  select
      process_date
    , payment01
    , payment02
    , payment03
    , payment04
  from
    ${database_name.l1}.report_payment_datamart
  where
    flag_exist = 'new'
)

-- account_open_dateで集約し、フェーズ毎に集計
, tt002 as(
  select
      process_date
    , count(payment01) as payment01_cnt
    , count(payment02) as payment02_cnt
    , count(payment03) as payment03_cnt
    , count(payment04) as payment04_cnt
    , count(payment01) + count(payment02) + count(payment03) + count(payment04) as total_cnt
  from
    tt001
  group by
    process_date
)

-- 横持ち→縦持ち変換
, tt003 as(
  select
      t1.process_date
    , t1.total_cnt
    , t2.key as payment
    , t2.value as uu
  from
    tt002 as t1
  cross join unnest(
      array['ハイブリット預金', '振込', 'ATM', 'クレカ入金']
    , array[payment01_cnt, payment02_cnt, payment03_cnt, payment04_cnt]
  ) t2(key, value)

)

-- 比率の計算
, tt101 as(
  select
      process_date as month
    , payment
    , uu
    , round(cast(uu as double) / total_cnt, 5) as rate
  from
    tt003
)

-- 結果の出力
select
      month
    , payment
    , uu
    , rate
from
  tt101
order by 
  payment