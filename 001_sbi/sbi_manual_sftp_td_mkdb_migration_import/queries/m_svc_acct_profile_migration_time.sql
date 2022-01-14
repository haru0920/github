insert into mkdb_transaction.m_svc_acct_profile_migration_time

select 
    mkdb_id
  , base_month
  , profile_name
  , profile_value
  , ts
  , td_time_parse(ts, 'JST') as time
from
  m_svc_acct_profile_migration
where
  td_time_range(td_time_parse(ts, 'JST'), ${time_range}, 'JST')
order by
  time