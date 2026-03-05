COPY (
  with content_items_cleaned as (
    select
      id,
      base_path,
      title,
      details->'body' as body
    from content_items
  )
  select *
  from content_items_cleaned
  order by id asc
  limit 50
) to STDOUT WITH CSV HEADER;
