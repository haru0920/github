DELETE FROM l1_id_master.${destination_table} 
  WHERE
    TD_TIME_RANGE(time,
      '${start_date}',
      '${end_date}',
      'JST')