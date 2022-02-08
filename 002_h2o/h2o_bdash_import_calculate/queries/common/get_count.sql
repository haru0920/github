select
  count(*) as cnt
from
  ${tmp.database_name}.${tmp.table_name}
where
  td_time_range(
    time
    , '${session_local_time}'
    , TD_TIME_FORMAT(TD_TIME_ADD(${session_unixtime}, '1d'), 'yyyy-MM-dd 00:00:00', 'JST')
    , 'JST')
