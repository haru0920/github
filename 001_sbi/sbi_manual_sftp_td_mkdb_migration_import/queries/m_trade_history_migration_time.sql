insert into mkdb_transaction.m_trade_history_migration_time

select 
    mkdb_id
  , base_month
  , customer_id
  , search_product_l_cd
  , search_product_m_cd
  , search_product_s_cd
  , product_cd1
  , product_cd2
  , product_cd3
  , product_cd4
  , product_cd5
  , search_trade_l_cd
  , search_trade_m_cd
  , search_trade_s_cd
  , trade_cd1
  , trade_cd2
  , trade_cd3
  , trade_cd4
  , trade_cd5
  , brand_cd
  , br_brand_ind
  , br_domestic_fgn_ind
  , br_brand_type_1
  , br_brand_type_2
  , br_comp_code
  , br_st_right_ind
  , br_n_o_ind
  , br_ser_no
  , br_sub_no_1
  , br_sub_no_2
  , br_list_cntry_cd
  , formal_brand_name
  , trade_date
  , get_date
  , order_no
  , product_short_name
  , trade_short_name1
  , trade_short_name2
  , capital_gain_tax_ind
  , price
  , new_trade_price
  , issue_currency_name
  , exchange_rate
  , quantity
  , quantity_unit
  , fee
  , consumption_tax
  , accrued_interest_ind
  , accrued_interest
  , withholding_tax
  , capital_gain_tax
  , accurate_amount
  , cancel_flg
  , create_time
  , dealer_no
  , tokutei_koza_kbn
  , hitokutei_kbn
  , td_time_parse(create_time, 'JST') as time
from
  m_trade_history_migration
where
  td_time_range(td_time_parse(create_time, 'JST'), ${time_range}, 'JST')
order by
  time