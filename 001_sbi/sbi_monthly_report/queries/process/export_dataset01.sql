select
    phase as "フェーズ"
  , month as "月"
  , uu as "UU"
  , prev_month_rate as "前月比"
  , this_month_rate as "構成比"
  , total_uu as "総UU"
from
  ${td.each.col02}.${td.each.col03}
order by
  month, phase