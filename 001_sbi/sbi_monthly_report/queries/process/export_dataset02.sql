select
    account_open_date as "口座開設日"
  , phase as "フェーズ"
  , uu as "UU"
  , rate as "到達率"
from
  ${td.each.col02}.${td.each.col03}
order by
  account_open_date, phase