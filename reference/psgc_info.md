# Get metadata for one or more PSGC codes

Get metadata for one or more PSGC codes

## Usage

``` r
psgc_info(code, release = latest_release())
```

## Arguments

- code:

  A character vector of 10-digit PSGC codes.

- release:

  A release name from \[list_releases()\]. Defaults to
  \[latest_release()\].

## Value

A data frame with one row per code containing metadata columns
(\`area_name\`, \`geographic_level\`, \`correspondence_code\`, etc.)
plus a \`release\` column indicating which release was used.

## Examples

``` r
psgc_info("0100000000")
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#>   old_name city_class income_classification urban_rural island_region release
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q1_2026
psgc_info(c("0100000000", "0102800000"))
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#> 2 0102800000             Ilocos Norte           012800000             Prov
#>   old_name city_class income_classification urban_rural island_region release
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q1_2026
#> 2     <NA>       <NA>                   1st        <NA>             L Q1_2026
psgc_info("0100000000", release = "Q1_2023")
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#>   old_name city_class income_classification urban_rural island_region release
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q1_2023
```
