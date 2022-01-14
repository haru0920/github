drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

select
    mkdb_id
  , base_month
  , dealer_no
  , application_date
  , birthday_gen
  , birthday
  , sex
  , blood_relation_cd
  , zip_cd1
  , zip_cd2
  , address_cd
  , address_kana1
  , address_kanji1
  , tokutei_koza
  , finance_name
  , receipt_no
  , cust_invenstment
  , cust_capital
  , cust_income
  , cust_tran
  , cust_oprate
  , cust_annual_income
  , cust_finance
  , cust_interest
  , trade_equity
  , trade_bond
  , trade_bondfund
  , trade_margine
  , trade_warrant
  , trade_futuresoption
  , trade_saving_inventment_trust
  , trade_other_inventment_trust
  , trade_foreign_securities
  , confirmation
  , create_date
  , id_cd
  , url_route
  , send_customer_id
  , substr(replace(open_date, '/', '-'), 1, 10) as open_date
  , three_flg
  , close_date
  , route
  , agent_id
  , judge_status
  , parental_minor_kbn
  , deal_subject_person
  , household_birthday_gen
  , household_birthday
  , nationality
  , greencard_hold
  , us_resident
  , investor_kbn
  , member_foreign_kbn_ntt
  , member_foreign_kbn_broadcast
  , member_foreign_kbn_aviation
  , qi_category_1
  , qi_category_2
  , transfer_method
  , div_bank_code
  , div_bank_name
  , div_bank_deposit_class
  , div_bank_account_class
  , resident_prefecture_code
  , sp_dividend_accept
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