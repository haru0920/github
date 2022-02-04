-- hive
-- cdcのid_masterを作成(繰り返しデータは配列で保持)
with tt001 as(
  select
      uid
    , max(old_customer_id) as old_customer_id
  from
    ${database_name.l0_pd_all_cdc}.cdc_profile
  group by
    uid
),

tt002 as(
  select
      uid
    , collect_set(member_seq) as member_seq_array
  from
    ${database_name.l0_pd_all_cdc}.cdc_sites
  group by
    uid
),

tt003 as(
  select
      uid
    , collect_set(member_no) as member_no_array
  from
    ${database_name.l0_pd_all_cdc}.cdc_cards
  group by
    uid
),

tt004 as(
  select
      uid
    , collect_set(email) as email_array
  from
    ${database_name.l0_pd_all_cdc}.cdc_approach
  group by
    uid
),

tt101 as(
  select
      t1.uid
    , t1.old_customer_id
    , t2.member_seq_array
    , t3.member_no_array
    , t4.email_array
  from
    tt001 as t1
    left join tt002 as t2 on t1.uid = t2.uid
    left join tt003 as t3 on t1.uid = t3.uid
    left join tt004 as t4 on t1.uid = t4.uid
)

insert overwrite table ${database_name.l1_pd_all_cdc}.cdc_id_master
select
    uid
  , old_customer_id
  , member_seq_array
  , member_no_array
  , email_array
from
  tt101