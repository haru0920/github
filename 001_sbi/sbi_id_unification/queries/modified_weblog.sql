SELECT 
  a. * ,
  -- mkdb_id02 > mkdb_id03 > unified_sitecatalys_hash_value
  CASE
    WHEN mkdb_id02 IS NOT NULL
    AND mkdb_id02 != '' THEN mkdb_id02
    WHEN mkdb_id03 IS NOT NULL
    AND mkdb_id03 != '' THEN mkdb_id03
    ELSE unified_sitecatalys_hash_value
  END AS sitecatalys_hash_value
FROM (
    SELECT 
       *
    FROM
      td_weblog.${source_table}
    WHERE
      TD_TIME_RANGE(time,
        '${start_date}',
        '${end_date}',
        'JST')
  ) a LEFT
JOIN (
  SELECT
    unified_sitecatalys_hash_value,
    td_ssc_id
  FROM (
    SELECT 
      latest_time,
      sitecatalys_hash_value as unified_sitecatalys_hash_value,
      td_ssc_id,
      ROW_NUMBER() over(PARTITION BY td_ssc_id ORDER BY latest_time DESC) AS latest_rank
    FROM
      l1_id_master.sitecatalys_hash_value_and_ssc_history
    WHERE 
      TD_TIME_RANGE(latest_time,
        NULL,
        '${end_date}',
        'JST')
  ) h
  WHERE 
    latest_rank = 1
) b
ON a.td_ssc_id = b.td_ssc_id