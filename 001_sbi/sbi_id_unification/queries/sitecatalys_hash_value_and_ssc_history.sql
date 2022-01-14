SELECT 
  sitecatalys_hash_value,
  td_ssc_id,
  MAX(time) AS latest_time
FROM (
    SELECT 
      time,
      CASE
        WHEN mkdb_id02 IS NOT NULL
        AND mkdb_id02 != '' THEN mkdb_id02
        ELSE mkdb_id03
      END AS sitecatalys_hash_value,
      td_ssc_id
    FROM
      td_weblog.td_pageview
    WHERE
      TD_TIME_RANGE(time,
        '${start_date}',
        '${end_date}',
        'JST')
      AND(
        (
          mkdb_id02 IS NOT NULL
          AND mkdb_id02 != ''
        )
        OR (
          mkdb_id03 IS NOT NULL
          AND mkdb_id03 != ''
        )
      )
  UNION
  ALL SELECT 
    time,
    CASE
      WHEN mkdb_id02 IS NOT NULL
      AND mkdb_id02 != '' THEN mkdb_id02
      ELSE mkdb_id03
    END AS sitecatalys_hash_value,
    td_ssc_id
  FROM
    td_weblog.td_click
  WHERE
    TD_TIME_RANGE(time,
      '${start_date}',
      '${end_date}',
      'JST')
    AND(
      (
        mkdb_id02 IS NOT NULL
        AND mkdb_id02 != ''
      )
      OR (
        mkdb_id03 IS NOT NULL
        AND mkdb_id03 != ''
      )
    )
  UNION
  ALL SELECT 
    latest_time AS time,
    sitecatalys_hash_value,
    td_ssc_id
  FROM
    l1_id_master.tmp_history
  ) a
GROUP BY
  1,
  2