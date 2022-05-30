select
  count(*) as cun
from
  ${td.each.out_database}.${td.each.out_table}
where
  td_time_range(
    time
    , '${session_local_time}'
    , TD_TIME_FORMAT(TD_TIME_ADD(${session_unixtime}, '1d'), 'yyyy-MM-dd 00:00:00', 'JST')
    , 'JST')
