-- hive
-- 処理当日取り込みのdelivlogにuidを付与
insert into table ${database_name.l1_pd_all_cuenote}.cn_store_delivlog_add_uid
select
    t2.uid
  , t1.file_id
  , t1.file_name
  , t1.mail_kenmei
  , t1.mail_format
  , t1.haishin_date
  , t1.address_id
  , t1.mailaddress
  , t1.saishu_status
  , t1.togo_kokyaku_no
  , t1.htmlmail_kahi_flg
  , t1.kaiin_no
from
  ${database_name.l0_non_all_cunote}.cn_store_delivlog as t1
  left join ${database_name.l1_pd_all_cdc}.cdc_id_master as t2 on t1.kaiin_no = t2.old_customer_id
where
  t1.time in (select max(time) from ${database_name.l0_non_all_cunote}.cn_store_delivlog)
