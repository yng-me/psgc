# psgc 0.2.0

## Bug fixes
* Fixed some population data not showing in Q2_2026 due to incorrect padding from the original source.
* Removed the four Q1_2023 NCR district rows that shared the placeholder code `0000000000`.
* `map_psgc()` now returns one row per successor for split codes, errors on an unknown `from` release, and errors when a code is not in the given `from` release (it used to report it as abolished). The never-produced `"merged"` type was removed from the docs.
* `psgc_info()` and `get_population(wide = TRUE)` are much faster on large inputs; `psgc_info()` lists all missing codes in one error.
* `geographic_level` now ignores case and surrounding spaces, and accepts `"Dist"` and `"SGU"`.

## New features
* Added Q3_2026 version of PSGC, now the latest release. 
* Added Q2_2021 version of PSGC (first version available from the source). It uses the older 9-digit code format; `map_psgc()` links it to Q1_2023 through `correspondence_code`, and `psgc_info()` and `get_psgc_wide()` handle 9-digit codes.

# psgc 0.1.2

* Added Q2_2026 version of PSGC

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
