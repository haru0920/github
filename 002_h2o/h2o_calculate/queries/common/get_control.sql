SELECT
    no
  , group1
  , group2
  , group3
  , order_no
  , kubun
  , exe_digfile_name
  , comment
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
  ${group.group3}
ORDER BY
    no ASC
  , order_no ASC