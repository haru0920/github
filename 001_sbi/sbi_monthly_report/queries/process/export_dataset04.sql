select
    month as "月"
  , over_nisa as "積立NISA上限到達者"
  , over_nisa_to_use_tax as "課税口座利用者"
  , rate as "課税口座移行率"
from
  ${td.each.col02}.${td.each.col03}
order by
  month