WITH tt1 as(
  SELECT
  	distinct process_name_sub
  FROM
    ${process.record_process.database}.${process.record_process.table}
  WHERE
    td_time_range(
    	time
    	, '${session_local_time}'
    	, TD_TIME_FORMAT(TD_TIME_ADD(${session_unixtime}, '1d'), 'yyyy-MM-dd 00:00:00', 'JST')
    	, 'JST')
    ${init.recovery_query}
)
SELECT 
    no
  , define_filename
  , in_filepath
  , out_database
  , out_table
  , out_mode
FROM
  ${control.database}.${control.table} as t1
  inner join
  tt1 as t2
  on t1.define_filename = t2.process_name_sub
ORDER BY
  no ASC