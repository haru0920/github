insert into ${td.each.col02}.${td.each.col03}

select
  "a"."process_date" as "process_date",
  "a"."mkdb_id" as "mkdb_id",
  "a"."achievement_nisa_day" as "achievement_nisa_day",
  "a"."account_open_date" as "account_open_date"from "cdp_audience_218415"."customers" a
where a."isa_keiyaku_kbn" = 1
and a."isa_hkzwk_gendo_gk" = 400000
and a."flag_nisa_threshold" = 'true'
