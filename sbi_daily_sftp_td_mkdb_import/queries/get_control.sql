SELECT 
    no
  , define_filename
  , in_filepath
  , out_database
  , out_table
  , out_mode
FROM
  ${control.database}.${control.table}
ORDER BY
  no ASC