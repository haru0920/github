drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

select
    base_date
  , mkdb_id
  , receipt_number
  , order_date
  , route
  , specific_kbn
  , with_bank_flg
  , friend_flg
  , submit_method
  , wl_create_status
  , first_login
  , trade_rest_status
  , specific_status
  , recv_nri
  , send_ncs
  , res_ncs
  , res_ncs_date
  , send_nri_trade_rest
  , send_nri_specific
  , bm_exp_open
  , bm_specific
  , bm_trade_rest
  , p_ident_type
  , p_ident_no
  , p_ident_upload
  , p_ident_file_nm
  , upload_time
  , error_flg
  , error_msg
  , delete_flg
  , request_no
  , foreign_acct_sts
  , yobi1
  , replace(yobi2, '/', '-') as yobi2
  , paper_cd
  , paper_name
  , purpose_cd
  , dispatch_status_cd
  , copies
  , contents
  , remarks
  , request_date
  , request_user_id
  , update_user_id
  , cancel_user_id
  , cancel_flg
  , option1
  , selected_name1
  , option2
  , selected_name2
  , option3
  , selected_name3
  , text1
  , input_contents1
  , text2
  , input_contents2
  , text3
  , input_contents3
  , text4
  , input_contents4
  , text5
  , input_contents5
  , sendmail
  , dispatch_count
  , prospectus_no
  , individual_or_corp
  , address1
  , s_address1
  , family_relation
  , birthday
  , sex
  , job_cd
  , settlement_term
  , enquete_cd
  , enquete_name
  , easy_flg
  , agent_id
  , dealer_no
  , specific_kind
  , dividend_total_accept
  , resident_prefecture_code
  , trade_rest_status_2
  , identity_confirm_doc_lmt
  , submit_method_first
  , identity_doc_code_star
  , prov_mail_send
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