# psgc 0.1.1

## Bug fixes

* `island_region` values are now consistently abbreviated (`"L"`, `"V"`, `"M"`)
  across all releases. Three older releases (Q4_2023, April_2024, Q2_2024) had
  full spellings ("Luzon", "Visayas", "Mindanao") which are now recoded during
  the data build step.

## New features

* `get_psgc_wide()` returns a denormalised wide-format data frame with one row
  per barangay and all four geographic levels (region, province,
  city/municipality, barangay) spread into columns. HUC/ICC barangays have
  `city_mun` / `city_mun_code` set to `NA`; areas with no province layer (e.g.
  Pateros, City of Isabela, Special Geographic Areas) have `province` /
  `province_code` set to `NA` (#get_psgc_wide).

* `map_psgc()` gains a `changes_only` argument. When `TRUE`, only rows where
  the code actually changed (mapping type is not `"direct"`) are returned,
  making it easy to identify renumbered or abolished codes across releases.

## Performance

* `map_psgc()` has been rewritten with a fully vectorised algorithm. The
  crosswalk is pre-split by hop once per call and all codes are processed
  simultaneously at each hop using `match()`, replacing the previous per-code
  loop. This yields roughly a 500× speed-up for large code vectors (e.g.
  1 000 codes: 94 s → < 0.2 s).

# psgc 0.1.0

* Initial CRAN submission.
