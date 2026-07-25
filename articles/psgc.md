# Getting started with psgc

## What is the PSGC?

The **Philippine Standard Geographic Code (PSGC)** is the official list
of every geographic area in the Philippines — from the broadest
(regions) down to the most granular (barangays). It is published and
maintained by the **Philippine Statistics Authority (PSA)**.

Each area is identified by a unique **10-digit code** and a geographic
level:

| Level    | Description      | Example                         |
|----------|------------------|---------------------------------|
| `Reg`    | Region           | Region I – Ilocos Region        |
| `Prov`   | Province         | Ilocos Norte                    |
| `City`   | City             | Laoag City                      |
| `Mun`    | Municipality     | Bacarra                         |
| `SubMun` | Sub-municipality | (Metro Manila component cities) |
| `Bgy`    | Barangay         | Brgy. 1, Laoag City             |

The PSA releases updated PSGC files several times a year as new cities
are chartered, barangays are created, or codes are renumbered. This
package bundles **13 releases** from Q1 2023 through Q2 2026.

------------------------------------------------------------------------

## Checking available releases

``` r

list_releases()
#>  [1] "Q1_2023"    "Q4_2023"    "April_2024" "Q2_2024"    "Q3_2024"   
#>  [6] "Q4_2024"    "Q1_2025"    "Q2_2025"    "July_2025"  "Q3_2025"   
#> [11] "Q4_2025"    "Q1_2026"    "Q2_2026"
latest_release()
#> [1] "Q2_2026"
```

By default, every function in this package uses the latest release. You
can always pass a specific release name to work with older data.

------------------------------------------------------------------------

## Getting the full PSGC list

[`get_psgc()`](https://yng-me.github.io/psgc/reference/get_psgc.md)
returns the complete list of geographic areas for a given release.

``` r

ph <- get_psgc()
nrow(ph)
#> [1] 43768
head(ph)
#>    psgc_code                    area_name correspondence_code geographic_level
#> 1 0100000000     Region I (Ilocos Region)           010000000              Reg
#> 2 1000000000 Region X (Northern Mindanao)           100000000              Reg
#> 3 1001300000                     Bukidnon           101300000             Prov
#> 4 1001301000                      Baungon           101301000              Mun
#> 5 1001301001                     Balintad           101301001              Bgy
#> 6 1001301002                   Buenavista           101301002              Bgy
#>   old_name city_class income_classification urban_rural island_region
#> 1     <NA>       <NA>                  <NA>        <NA>             L
#> 2     <NA>       <NA>                  <NA>        <NA>             M
#> 3     <NA>       <NA>                   1st        <NA>             M
#> 4     <NA>       <NA>                   1st        <NA>             M
#> 5     <NA>       <NA>                  <NA>           R             M
#> 6     <NA>       <NA>                  <NA>           R             M
```

### Filter by geographic level

You do not need to remember the exact code names — plain English works
too:

``` r

regions <- get_psgc(geographic_level = "Region")
regions[, c("psgc_code", "area_name")]
#>        psgc_code                                               area_name
#> 1     0100000000                                Region I (Ilocos Region)
#> 2     1000000000                            Region X (Northern Mindanao)
#> 5519  1100000000                                Region XI (Davao Region)
#> 6736  1200000000                               Region XII (SOCCSKSARGEN)
#> 7887  1300000000                           National Capital Region (NCR)
#> 9634  1400000000                  Cordillera Administrative Region (CAR)
#> 10896 1600000000                                    Region XIII (Caraga)
#> 12287 1700000000                                         MIMAROPA Region
#> 13826 1800000000                              Negros Island Region (NIR)
#> 15246 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#> 17546 0200000000                              Region II (Cagayan Valley)
#> 19956 0300000000                              Region III (Central Luzon)
#> 23199 0400000000                                Region IV-A (CALABARZON)
#> 27339 0500000000                                 Region V (Bicol Region)
#> 30931 0600000000                             Region VI (Western Visayas)
#> 34427 0700000000                            Region VII (Central Visayas)
#> 36843 0800000000                           Region VIII (Eastern Visayas)
#> 41358 0900000000                         Region IX (Zamboanga Peninsula)
```

``` r

provinces <- get_psgc(geographic_level = "Province")
nrow(provinces)
#> [1] 82
head(provinces[, c("psgc_code", "area_name")])
#>       psgc_code          area_name
#> 3    1001300000           Bukidnon
#> 490  1001800000           Camiguin
#> 554  1003500000    Lanao del Norte
#> 1039 1004200000 Misamis Occidental
#> 1547 1004300000   Misamis Oriental
#> 1997 0102800000       Ilocos Norte
```

You can filter for multiple levels at once by passing a vector:

``` r

city_mun <- get_psgc(geographic_level = c("City", "Municipality"))
nrow(city_mun)
#> [1] 1642
```

There is also a convenient shorthand, `"city_mun"`, that does the same
thing:

``` r

nrow(get_psgc(geographic_level = "city_mun"))
#> [1] 1642
```

### Using a specific release

``` r

ph_2023 <- get_psgc("Q1_2023")
nrow(ph_2023)
#> [1] 43784
```

------------------------------------------------------------------------

## Looking up a specific code

If you already have a PSGC code and want its details, use
[`psgc_info()`](https://yng-me.github.io/psgc/reference/psgc_info.md).

``` r

psgc_info("0100000000") # Region I
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#>   old_name city_class income_classification urban_rural island_region release
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q2_2026
```

You can look up multiple codes at once:

``` r

psgc_info(c("0100000000", "0102800000"))
#>       psgc_code                area_name correspondence_code geographic_level
#> 1    0100000000 Region I (Ilocos Region)           010000000              Reg
#> 1997 0102800000             Ilocos Norte           012800000             Prov
#>      old_name city_class income_classification urban_rural island_region
#> 1        <NA>       <NA>                  <NA>        <NA>             L
#> 1997     <NA>       <NA>                   1st        <NA>             L
#>      release
#> 1    Q2_2026
#> 1997 Q2_2026
```

**Short codes are accepted** — the package pads the rest with trailing
zeros, so you only need to provide enough digits to identify the area:

``` r

psgc_info("01")      # same as "0100000000" — Region I
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#>   old_name city_class income_classification urban_rural island_region release
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q2_2026
psgc_info("01028")  # same as "0102800000" — Ilocos Norte
#>       psgc_code    area_name correspondence_code geographic_level old_name
#> 1997 0102800000 Ilocos Norte           012800000             Prov     <NA>
#>      city_class income_classification urban_rural island_region release
#> 1997       <NA>                   1st        <NA>             L Q2_2026
```

------------------------------------------------------------------------

## Population data

[`get_population()`](https://yng-me.github.io/psgc/reference/get_population.md)
returns PSA census figures (2015, 2020, 2024) for all geographic areas
in a release.

``` r

pop <- get_population()
head(pop)
#>    psgc_code year population
#> 1 1000000000 2015    4689302
#> 2 1000000000 2020    5022768
#> 3 1000000000 2024    5178326
#> 4 1001300000 2015    1415226
#> 5 1001300000 2020    1541308
#> 6 1001300000 2024    1601902
```

### Add area names and geographic levels

Set `details = TRUE` to include the area name and level alongside the
numbers:

``` r

pop_detailed <- get_population(details = TRUE)
head(pop_detailed)
#>    psgc_code                    area_name geographic_level year population
#> 1 1000000000 Region X (Northern Mindanao)              Reg 2015    4689302
#> 2 1000000000 Region X (Northern Mindanao)              Reg 2020    5022768
#> 3 1000000000 Region X (Northern Mindanao)              Reg 2024    5178326
#> 4 1001300000                     Bukidnon             Prov 2015    1415226
#> 5 1001300000                     Bukidnon             Prov 2020    1541308
#> 6 1001300000                     Bukidnon             Prov 2024    1601902
```

### Filter by geographic level

Same aliases as
[`get_psgc()`](https://yng-me.github.io/psgc/reference/get_psgc.md) work
here too:

``` r

region_pop <- get_population(geographic_level = "Region", details = TRUE)
region_pop
#>     psgc_code                                               area_name
#> 1  1000000000                            Region X (Northern Mindanao)
#> 2  1000000000                            Region X (Northern Mindanao)
#> 3  1000000000                            Region X (Northern Mindanao)
#> 4  1100000000                                Region XI (Davao Region)
#> 5  1100000000                                Region XI (Davao Region)
#> 6  1100000000                                Region XI (Davao Region)
#> 7  1200000000                               Region XII (SOCCSKSARGEN)
#> 8  1200000000                               Region XII (SOCCSKSARGEN)
#> 9  1200000000                               Region XII (SOCCSKSARGEN)
#> 10 1300000000                           National Capital Region (NCR)
#> 11 1300000000                           National Capital Region (NCR)
#> 12 1300000000                           National Capital Region (NCR)
#> 13 1400000000                  Cordillera Administrative Region (CAR)
#> 14 1400000000                  Cordillera Administrative Region (CAR)
#> 15 1400000000                  Cordillera Administrative Region (CAR)
#> 16 1600000000                                    Region XIII (Caraga)
#> 17 1600000000                                    Region XIII (Caraga)
#> 18 1600000000                                    Region XIII (Caraga)
#> 19 1700000000                                         MIMAROPA Region
#> 20 1700000000                                         MIMAROPA Region
#> 21 1700000000                                         MIMAROPA Region
#> 22 1800000000                              Negros Island Region (NIR)
#> 23 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#> 24 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#> 25 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#>    geographic_level year population
#> 1               Reg 2015    4689302
#> 2               Reg 2020    5022768
#> 3               Reg 2024    5178326
#> 4               Reg 2015    4893318
#> 5               Reg 2020    5243536
#> 6               Reg 2024    5389422
#> 7               Reg 2015    4545276
#> 8               Reg 2020    4901486
#> 9               Reg 2024    4462776
#> 10              Reg 2015   12877253
#> 11              Reg 2020   13484462
#> 12              Reg 2024   14001751
#> 13              Reg 2015    1722006
#> 14              Reg 2020    1797660
#> 15              Reg 2024    1808985
#> 16              Reg 2015    2596709
#> 17              Reg 2020    2804788
#> 18              Reg 2024    2865196
#> 19              Reg 2015    2963360
#> 20              Reg 2020    3228558
#> 21              Reg 2024    3245446
#> 22              Reg 2024    4904944
#> 23              Reg 2015    3781387
#> 24              Reg 2020    4404288
#> 25              Reg 2024    4545486
```

### Wide format — one row per area

Set `wide = TRUE` to get each census year as its own column, making it
easy to compare figures side by side or feed into a table or chart:

``` r

region_pop_wide <- get_population(
  geographic_level = "Region",
  details          = TRUE,
  wide             = TRUE
)
region_pop_wide
#>    psgc_code                                               area_name
#> 1 1000000000                            Region X (Northern Mindanao)
#> 2 1100000000                                Region XI (Davao Region)
#> 3 1200000000                               Region XII (SOCCSKSARGEN)
#> 4 1300000000                           National Capital Region (NCR)
#> 5 1400000000                  Cordillera Administrative Region (CAR)
#> 6 1600000000                                    Region XIII (Caraga)
#> 7 1700000000                                         MIMAROPA Region
#> 8 1800000000                              Negros Island Region (NIR)
#> 9 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#>   geographic_level population_2015 population_2020 population_2024
#> 1              Reg         4689302         5022768         5178326
#> 2              Reg         4893318         5243536         5389422
#> 3              Reg         4545276         4901486         4462776
#> 4              Reg        12877253        13484462        14001751
#> 5              Reg         1722006         1797660         1808985
#> 6              Reg         2596709         2804788         2865196
#> 7              Reg         2963360         3228558         3245446
#> 8              Reg              NA              NA         4904944
#> 9              Reg         3781387         4404288         4545486
```

### Attach population data to the PSGC list

If you want population figures alongside the main PSGC table (rather
than as a separate data frame), use `include_population_data = TRUE` in
[`get_psgc()`](https://yng-me.github.io/psgc/reference/get_psgc.md).
This adds a `population_data` list-column — each cell is a small data
frame with `population` and `year`:

``` r

regions_with_pop <- get_psgc(
  geographic_level       = "Region",
  include_population_data = TRUE
)

# Inspect the population data for the first region
regions_with_pop$population_data[[1]]
#> [1] population year      
#> <0 rows> (or 0-length row.names)
```

------------------------------------------------------------------------

## Tracking codes across releases

The PSA occasionally renumbers or abolishes areas between releases.
[`map_psgc()`](https://yng-me.github.io/psgc/reference/map_psgc.md)
traces a code forward to any later release so you can keep longitudinal
datasets consistent.

``` r

map_psgc("0100000000")  # forward to the latest release
#>     old_code   new_code mapping_type from_release to_release
#> 1 0100000000 0100000000       direct      Q1_2023    Q2_2026
```

``` r

map_psgc("0100000000", to = "Q4_2023")
#>     old_code   new_code mapping_type from_release to_release
#> 1 0100000000 0100000000       direct      Q1_2023    Q4_2023
```

The `mapping_type` column tells you what happened to the code:

| Type         | Meaning                                         |
|--------------|-------------------------------------------------|
| `direct`     | Code is unchanged                               |
| `renumbered` | Code was assigned a new number                  |
| `split`      | One area was divided into multiple areas        |
| `merged`     | Multiple areas were merged into one             |
| `abolished`  | Area no longer exists (`new_code` will be `NA`) |

This is especially useful when joining PSGC-coded survey data from
different years — use
[`map_psgc()`](https://yng-me.github.io/psgc/reference/map_psgc.md)
first to normalise all codes to a single release before merging.
