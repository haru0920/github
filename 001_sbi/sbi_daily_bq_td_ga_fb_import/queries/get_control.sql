SELECT 
    no
  , in_project_id
  , in_dataset
  , in_table
  , in_export_to_gcs
  , in_gcs_bucket
  , in_gcs_path_prefix
  , out_database
  , out_table
  , out_mode
FROM
  ${control.database}.${control.table}
ORDER BY
  no ASC