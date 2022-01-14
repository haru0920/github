drop table if exists ${td.each.col02}.${td.each.col03};
create table ${td.each.col02}.${td.each.col03} as

-- m_user_attrbute_infoから本日分のデータのIDのみを取得
select
    mkdb_id
  , sitecatalys_hash_value
from
  ${td.each.col05}.${td.each.col06}
