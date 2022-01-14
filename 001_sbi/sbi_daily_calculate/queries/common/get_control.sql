SELECT
    no
  , group1
  , group2
  , order_no
  , kubun
  , exe_digfile_name
  , col01
  , col02
  , col03
  , col04
  , col05
  , col06
  , col07
  , col08
  , col09
  , col10
FROM
  ${control.database}.${control.table}
WHERE
  ${group.group1}
  ${group.group2}
ORDER BY
    no ASC
  , order_no ASC