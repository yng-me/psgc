# Map PSGC codes to a target release

Map PSGC codes to a target release

## Usage

``` r
map_psgc(code, from = "auto", to = latest_release(), changes_only = FALSE)
```

## Arguments

- code:

  A character vector of PSGC codes (10 digits; 9 for codes from
  \`"Q2_2021"\`).

- from:

  Release the codes come from, or \`"auto"\` (default) to detect
  automatically using the earliest release that contains each code.

- to:

  Target release name. Defaults to \[latest_release()\].

- changes_only:

  Logical. If \`TRUE\`, only rows where the code actually changed (i.e.
  \`mapping_type\` is not \`"direct"\`) are returned. Codes that
  remained unchanged across all hops are dropped. Defaults to \`FALSE\`.

## Value

A data frame with columns \`old_code\`, \`new_code\` (\`NA\` for
abolished codes), \`mapping_type\` (\`"direct"\`, \`"renumbered"\`,
\`"split"\`, or \`"abolished"\`), \`from_release\`, and \`to_release\`.
A split code produces one row per successor.

## Examples

``` r
map_psgc("0100000000")
#>     old_code   new_code mapping_type from_release to_release
#> 1 0100000000 0100000000       direct      Q1_2023    Q3_2026
map_psgc(c("0100000000", "0102800000"), to = "Q4_2023")
#>     old_code   new_code mapping_type from_release to_release
#> 1 0100000000 0100000000       direct      Q1_2023    Q4_2023
#> 2 0102800000 0102800000       direct      Q1_2023    Q4_2023
map_psgc(get_psgc("Q1_2023", geographic_level = "Bgy")$psgc_code,
         from = "Q1_2023", to = "Q4_2023", changes_only = TRUE)
#>      old_code   new_code mapping_type from_release to_release
#> 1  0402103001       <NA>    abolished      Q1_2023    Q4_2023
#> 2  0402103002 0402103076   renumbered      Q1_2023    Q4_2023
#> 3  0402103003       <NA>    abolished      Q1_2023    Q4_2023
#> 4  0402103005       <NA>    abolished      Q1_2023    Q4_2023
#> 5  0402103006       <NA>    abolished      Q1_2023    Q4_2023
#> 6  0402103009       <NA>    abolished      Q1_2023    Q4_2023
#> 7  0402103010 0402103079   renumbered      Q1_2023    Q4_2023
#> 8  0402103011       <NA>    abolished      Q1_2023    Q4_2023
#> 9  0402103015       <NA>    abolished      Q1_2023    Q4_2023
#> 10 0402103019       <NA>    abolished      Q1_2023    Q4_2023
#> 11 0402103022       <NA>    abolished      Q1_2023    Q4_2023
#> 12 0402103023       <NA>    abolished      Q1_2023    Q4_2023
#> 13 0402103024 0402103090   renumbered      Q1_2023    Q4_2023
#> 14 0402103025 0402103092   renumbered      Q1_2023    Q4_2023
#> 15 0402103029 0402103077   renumbered      Q1_2023    Q4_2023
#> 16 0402103030       <NA>    abolished      Q1_2023    Q4_2023
#> 17 0402103031       <NA>    abolished      Q1_2023    Q4_2023
#> 18 0402103032       <NA>    abolished      Q1_2023    Q4_2023
#> 19 0402103033       <NA>    abolished      Q1_2023    Q4_2023
#> 20 0402103035       <NA>    abolished      Q1_2023    Q4_2023
#> 21 0402103037       <NA>    abolished      Q1_2023    Q4_2023
#> 22 0402103038       <NA>    abolished      Q1_2023    Q4_2023
#> 23 0402103039 0402103081   renumbered      Q1_2023    Q4_2023
#> 24 0402103040       <NA>    abolished      Q1_2023    Q4_2023
#> 25 0402103041 0402103082   renumbered      Q1_2023    Q4_2023
#> 26 0402103044       <NA>    abolished      Q1_2023    Q4_2023
#> 27 0402103051       <NA>    abolished      Q1_2023    Q4_2023
#> 28 0402103052       <NA>    abolished      Q1_2023    Q4_2023
#> 29 0402103053 0402103084   renumbered      Q1_2023    Q4_2023
#> 30 0402103054       <NA>    abolished      Q1_2023    Q4_2023
#> 31 0402103056       <NA>    abolished      Q1_2023    Q4_2023
#> 32 0402103057       <NA>    abolished      Q1_2023    Q4_2023
#> 33 0402103060       <NA>    abolished      Q1_2023    Q4_2023
#> 34 0402103061 0402103088   renumbered      Q1_2023    Q4_2023
#> 35 0402103062       <NA>    abolished      Q1_2023    Q4_2023
#> 36 0402103063       <NA>    abolished      Q1_2023    Q4_2023
#> 37 0402103067 0402103091   renumbered      Q1_2023    Q4_2023
#> 38 0402103068       <NA>    abolished      Q1_2023    Q4_2023
#> 39 0402103069       <NA>    abolished      Q1_2023    Q4_2023
#> 40 0402103070       <NA>    abolished      Q1_2023    Q4_2023
#> 41 0402103071       <NA>    abolished      Q1_2023    Q4_2023
#> 42 0402103072 0402103093   renumbered      Q1_2023    Q4_2023
#> 43 0402103073       <NA>    abolished      Q1_2023    Q4_2023
#> 44 0402103074       <NA>    abolished      Q1_2023    Q4_2023
#> 45 1380300003       <NA>    abolished      Q1_2023    Q4_2023
#> 46 1380300004       <NA>    abolished      Q1_2023    Q4_2023
#> 47 1380300007       <NA>    abolished      Q1_2023    Q4_2023
#> 48 1380300016       <NA>    abolished      Q1_2023    Q4_2023
#> 49 1380300019       <NA>    abolished      Q1_2023    Q4_2023
#> 50 1380300021       <NA>    abolished      Q1_2023    Q4_2023
#> 51 1380300022       <NA>    abolished      Q1_2023    Q4_2023
#> 52 1380300028       <NA>    abolished      Q1_2023    Q4_2023
#> 53 1380300032       <NA>    abolished      Q1_2023    Q4_2023
#> 54 1380300033       <NA>    abolished      Q1_2023    Q4_2023
```
