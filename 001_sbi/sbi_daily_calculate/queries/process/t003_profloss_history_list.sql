insert into ${td.each.col02}.${td.each.col03}

select
  *
from
  ${td.each.col05}.${td.each.col06}
where
  td_time_range(
      time
    ,  (select max(time) from ${td.each.col05}.${td.each.col06})
    , null
    , 'JST'
  )