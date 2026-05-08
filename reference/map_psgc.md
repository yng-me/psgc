# Map PSGC codes to a target release

Map PSGC codes to a target release

## Usage

``` r
map_psgc(code, from = "auto", to = latest_release())
```

## Arguments

- code:

  A character vector of 10-digit PSGC codes.

- from:

  Release the codes come from, or \`"auto"\` (default) to detect
  automatically using the earliest release that contains each code.

- to:

  Target release name. Defaults to \[latest_release()\].

## Value

A data frame with columns \`old_code\`, \`new_code\` (\`NA\` for
abolished codes), \`mapping_type\` (\`"direct"\`, \`"renumbered"\`,
\`"split"\`, \`"merged"\`, or \`"abolished"\`), \`from_release\`, and
\`to_release\`. Split codes produce multiple rows.

## Examples

``` r
map_psgc("0100000000")
#>              old_code   new_code mapping_type from_release to_release
#> 0100000000 0100000000 0100000000       direct      Q1_2023    Q1_2026
map_psgc(c("0100000000", "0102800000"), to = "Q4_2023")
#>              old_code   new_code mapping_type from_release to_release
#> 0100000000 0100000000 0100000000       direct      Q1_2023    Q4_2023
#> 0102800000 0102800000 0102800000       direct      Q1_2023    Q4_2023
```
