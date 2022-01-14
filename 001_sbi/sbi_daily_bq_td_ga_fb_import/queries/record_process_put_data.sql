select
    '${init.process_name}' as process_name
  , '${tmp.process_name_sub}' as process_name_sub
  , '${init.mode}' as mode
  , '${tmp.status}' as status
  , '${session_time}' as session_time
  , td_time_format(TD_TIME_PARSE(cast(CURRENT_TIMESTAMP as varchar), 'JST'), 'yyyy-MM-dd HH:mm:ssZ', 'JST')
 as process_time