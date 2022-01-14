drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- m_user_attrbute_tableから最新取り込みデータのみを取得
select
  mkdb_id
from
  ${database_name.l0.mkdb_master}.m_user_attrbute_info
where
  td_time_range(
      time
    ${tmp.start_date_commentout1}, null
    ${tmp.start_date_commentout2}, td_date_trunc('month', td_date_trunc('month', cast(${session_unixtime} as integer), 'JST') - 1, 'JST')
    , td_date_trunc('month', cast(${session_unixtime} as integer), 'JST')
    , 'JST'
  )
group by
  mkdb_id