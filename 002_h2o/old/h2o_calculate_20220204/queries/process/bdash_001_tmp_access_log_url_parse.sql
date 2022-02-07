-- hive
-- URLパラメータをパーシング処理
insert overwrite table ${database_name.l1_non_all_bdash}.tmp_bd_access_log_url_parse
select
    td_time_parse(ymd, 'JST') as time
  , kaiin_seq
  , ymd
  , page_url
  , page_title
  , split(regexp_replace(parse_url(page_url, 'QUERY'), '[^&][A-Za-z0-9]*=', ''), '&') as query_array
  , parse_url(page_url, 'QUERY', 'cid') as query_cid
  , parse_url(page_url, 'QUERY', 'ggcd') as query_ggcd
from
  ${database_name.l0_non_all_bdash}.bd_access_log
where
  time in (select max(time) from ${database_name.l0_non_all_bdash}.bd_access_log)