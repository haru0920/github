drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- 国内株式現物預り明細から処理月のデータを取得
with tt001 as(
  select
      mkdb_id
    , br_comp_code
    , exec_base_balance_t1
    , acquire_price
    , appraise_market_price
    , time
  from
    ${database_name.l0.mkdb_transaction}.m_bl_int_stock
  where 
    td_interval(time, '-1M', 'JST')
)

-- tt001の中で最小のtimeのレコードのみを取得
, tt002 as(
  select
      mkdb_id
    , br_comp_code
    , exec_base_balance_t1
    , acquire_price
    , appraise_market_price
    , time
  from
    tt001
  where
    td_time_range(
        time
      , (select max(time) from tt001)
      , td_time_add(td_date_trunc('day', (select max(time) from tt001), 'JST'), '1d')
    )
)

-- 国内株評価損益リスト(ユーザ/銘柄単位での集計)
, tt101 as(
  select
      mkdb_id
    , br_comp_code
    , sum(cast(exec_base_balance_t1 as double) * cast(acquire_price as double)) as purchase_price
    , (max(cast(appraise_market_price as double))
      - (ceiling(sum(cast(exec_base_balance_t1 as double) * cast(acquire_price as double)) / sum(cast(exec_base_balance_t1 as double))))
      ) * sum(cast(exec_base_balance_t1 as double)) as profit_loss
  from
    tt002
  where
    cast(exec_base_balance_t1 as double) > 0
    and cast(acquire_price as double) > 0
    and cast(appraise_market_price as double) > 0
  group by
      mkdb_id
    , br_comp_code
)

select
    mkdb_id
  , sum(profit_loss) / sum(purchase_price) as t001_profit_loss_rate
from
  tt101
group by
  mkdb_id