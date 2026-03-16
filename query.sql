COPY (
  select
    id,
    base_path,
    title,
    details->'body' as body,
    expanded_links->'taxons' as taxons
  from content_items
  where publishing_app = 'whitehall'
  and expanded_links?'taxons'
  and first_published_at >= '2025-01-01'
) to STDOUT WITH CSV HEADER;
