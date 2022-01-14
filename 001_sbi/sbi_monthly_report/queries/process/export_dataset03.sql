select
    month as "月"
  , payment as "入金方法"
  , uu as "UU"
  , rate as "構成比"
from
  ${td.each.col02}.${td.each.col03}
order by
  month, payment