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
package bundles **12 releases** from Q1 2023 through Q1 2026.

------------------------------------------------------------------------

## Checking available releases

``` r

list_releases()
#>  [1] "Q1_2023"    "Q4_2023"    "April_2024" "Q2_2024"    "Q3_2024"   
#>  [6] "Q4_2024"    "Q1_2025"    "Q2_2025"    "July_2025"  "Q3_2025"   
#> [11] "Q4_2025"    "Q1_2026"
latest_release()
#> [1] "Q1_2026"
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
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#> 2 0102800000             Ilocos Norte           012800000             Prov
#> 3 0102801000                    Adams           012801000              Mun
#> 4 0102801001                    Adams           012801001              Bgy
#> 5 0102802000                  Bacarra           012802000              Mun
#> 6 0102802001                     Bani           012802001              Bgy
#>   old_name city_class income_classification urban_rural island_region
#> 1     <NA>       <NA>                  <NA>        <NA>             L
#> 2     <NA>       <NA>                   1st        <NA>             L
#> 3     <NA>       <NA>                   4th        <NA>             L
#> 4     <NA>       <NA>                  <NA>           R             L
#> 5     <NA>       <NA>                   2nd        <NA>             L
#> 6     <NA>       <NA>                  <NA>           R             L
```

### Filter by geographic level

You do not need to remember the exact code names — plain English works
too:

``` r

regions <- get_psgc(geographic_level = "Region")
regions[, c("psgc_code", "area_name")]
#>        psgc_code                                               area_name
#> 1     0100000000                                Region I (Ilocos Region)
#> 3398  0200000000                              Region II (Cagayan Valley)
#> 5808  0300000000                              Region III (Central Luzon)
#> 9051  0400000000                                Region IV-A (CALABARZON)
#> 13191 0500000000                                 Region V (Bicol Region)
#> 16783 0600000000                             Region VI (Western Visayas)
#> 20279 0700000000                            Region VII (Central Visayas)
#> 22695 0800000000                           Region VIII (Eastern Visayas)
#> 27210 0900000000                         Region IX (Zamboanga Peninsula)
#> 29621 1000000000                            Region X (Northern Mindanao)
#> 31742 1100000000                                Region XI (Davao Region)
#> 32959 1200000000                               Region XII (SOCCSKSARGEN)
#> 34110 1300000000                           National Capital Region (NCR)
#> 35857 1400000000                  Cordillera Administrative Region (CAR)
#> 37119 1600000000                                    Region XIII (Caraga)
#> 38510 1700000000                                         MIMAROPA Region
#> 40049 1800000000                              Negros Island Region (NIR)
#> 41469 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
```

``` r

provinces <- get_psgc(geographic_level = "Province")
nrow(provinces)
#> [1] 82
head(provinces[, c("psgc_code", "area_name")])
#>       psgc_code    area_name
#> 2    0102800000 Ilocos Norte
#> 585  0102900000   Ilocos Sur
#> 1388 0103300000     La Union
#> 1985 0105500000   Pangasinan
#> 3399 0200900000      Batanes
#> 3435 0201500000      Cagayan
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
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q1_2026
```

You can look up multiple codes at once:

``` r

psgc_info(c("0100000000", "0102800000"))
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#> 2 0102800000             Ilocos Norte           012800000             Prov
#>   old_name city_class income_classification urban_rural island_region release
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q1_2026
#> 2     <NA>       <NA>                   1st        <NA>             L Q1_2026
```

**Short codes are accepted** — the package pads the rest with trailing
zeros, so you only need to provide enough digits to identify the area:

``` r

psgc_info("01")      # same as "0100000000" — Region I
#>    psgc_code                area_name correspondence_code geographic_level
#> 1 0100000000 Region I (Ilocos Region)           010000000              Reg
#>   old_name city_class income_classification urban_rural island_region release
#> 1     <NA>       <NA>                  <NA>        <NA>             L Q1_2026
psgc_info("01028")  # same as "0102800000" — Ilocos Norte
#>    psgc_code    area_name correspondence_code geographic_level old_name
#> 2 0102800000 Ilocos Norte           012800000             Prov     <NA>
#>   city_class income_classification urban_rural island_region release
#> 2       <NA>                   1st        <NA>             L Q1_2026
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
#> 1 0100000000 2015    5026128
#> 2 0100000000 2020    5301139
#> 3 0100000000 2024    5342453
#> 4 0102800000 2015     593081
#> 5 0102800000 2020     609588
#> 6 0102800000 2024     618850
```

### Add area names and geographic levels

Set `details = TRUE` to include the area name and level alongside the
numbers:

``` r

pop_detailed <- get_population(details = TRUE)
head(pop_detailed)
#>    psgc_code                area_name geographic_level year population
#> 1 0100000000 Region I (Ilocos Region)              Reg 2015    5026128
#> 2 0100000000 Region I (Ilocos Region)              Reg 2020    5301139
#> 3 0100000000 Region I (Ilocos Region)              Reg 2024    5342453
#> 4 0102800000             Ilocos Norte             Prov 2015     593081
#> 5 0102800000             Ilocos Norte             Prov 2020     609588
#> 6 0102800000             Ilocos Norte             Prov 2024     618850
```

### Filter by geographic level

Same aliases as
[`get_psgc()`](https://yng-me.github.io/psgc/reference/get_psgc.md) work
here too:

``` r

region_pop <- get_population(geographic_level = "Region", details = TRUE)
region_pop
#>     psgc_code                                               area_name
#> 1  0100000000                                Region I (Ilocos Region)
#> 2  0100000000                                Region I (Ilocos Region)
#> 3  0100000000                                Region I (Ilocos Region)
#> 4  0200000000                              Region II (Cagayan Valley)
#> 5  0200000000                              Region II (Cagayan Valley)
#> 6  0200000000                              Region II (Cagayan Valley)
#> 7  0300000000                              Region III (Central Luzon)
#> 8  0300000000                              Region III (Central Luzon)
#> 9  0300000000                              Region III (Central Luzon)
#> 10 0400000000                                Region IV-A (CALABARZON)
#> 11 0400000000                                Region IV-A (CALABARZON)
#> 12 0400000000                                Region IV-A (CALABARZON)
#> 13 0500000000                                 Region V (Bicol Region)
#> 14 0500000000                                 Region V (Bicol Region)
#> 15 0500000000                                 Region V (Bicol Region)
#> 16 0600000000                             Region VI (Western Visayas)
#> 17 0600000000                             Region VI (Western Visayas)
#> 18 0600000000                             Region VI (Western Visayas)
#> 19 0700000000                            Region VII (Central Visayas)
#> 20 0700000000                            Region VII (Central Visayas)
#> 21 0700000000                            Region VII (Central Visayas)
#> 22 0800000000                           Region VIII (Eastern Visayas)
#> 23 0800000000                           Region VIII (Eastern Visayas)
#> 24 0800000000                           Region VIII (Eastern Visayas)
#> 25 0900000000                         Region IX (Zamboanga Peninsula)
#> 26 0900000000                         Region IX (Zamboanga Peninsula)
#> 27 0900000000                         Region IX (Zamboanga Peninsula)
#> 28 1000000000                            Region X (Northern Mindanao)
#> 29 1000000000                            Region X (Northern Mindanao)
#> 30 1000000000                            Region X (Northern Mindanao)
#> 31 1100000000                                Region XI (Davao Region)
#> 32 1100000000                                Region XI (Davao Region)
#> 33 1100000000                                Region XI (Davao Region)
#> 34 1200000000                               Region XII (SOCCSKSARGEN)
#> 35 1200000000                               Region XII (SOCCSKSARGEN)
#> 36 1200000000                               Region XII (SOCCSKSARGEN)
#> 37 1300000000                           National Capital Region (NCR)
#> 38 1300000000                           National Capital Region (NCR)
#> 39 1300000000                           National Capital Region (NCR)
#> 40 1400000000                  Cordillera Administrative Region (CAR)
#> 41 1400000000                  Cordillera Administrative Region (CAR)
#> 42 1400000000                  Cordillera Administrative Region (CAR)
#> 43 1600000000                                    Region XIII (Caraga)
#> 44 1600000000                                    Region XIII (Caraga)
#> 45 1600000000                                    Region XIII (Caraga)
#> 46 1700000000                                         MIMAROPA Region
#> 47 1700000000                                         MIMAROPA Region
#> 48 1700000000                                         MIMAROPA Region
#> 49 1800000000                              Negros Island Region (NIR)
#> 50 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#> 51 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#> 52 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#>    geographic_level year population
#> 1               Reg 2015    5026128
#> 2               Reg 2020    5301139
#> 3               Reg 2024    5342453
#> 4               Reg 2015    3451410
#> 5               Reg 2020    3685744
#> 6               Reg 2024    3777608
#> 7               Reg 2015   11218177
#> 8               Reg 2020   12422172
#> 9               Reg 2024   12989074
#> 10              Reg 2015   14414774
#> 11              Reg 2020   16195042
#> 12              Reg 2024   16933234
#> 13              Reg 2015    5796989
#> 14              Reg 2020    6082165
#> 15              Reg 2024    6064426
#> 16              Reg 2015    7536383
#> 17              Reg 2020    7954723
#> 18              Reg 2024    4861911
#> 19              Reg 2015    7396898
#> 20              Reg 2020    8081988
#> 21              Reg 2024    6640875
#> 22              Reg 2015    4440150
#> 23              Reg 2020    4547150
#> 24              Reg 2024    4625929
#> 25              Reg 2015    3629783
#> 26              Reg 2020    3875576
#> 27              Reg 2024    5089934
#> 28              Reg 2015    4689302
#> 29              Reg 2020    5022768
#> 30              Reg 2024    5178326
#> 31              Reg 2015    4893318
#> 32              Reg 2020    5243536
#> 33              Reg 2024    5389422
#> 34              Reg 2015    4545276
#> 35              Reg 2020    4901486
#> 36              Reg 2024    4462776
#> 37              Reg 2015   12877253
#> 38              Reg 2020   13484462
#> 39              Reg 2024   14001751
#> 40              Reg 2015    1722006
#> 41              Reg 2020    1797660
#> 42              Reg 2024    1808985
#> 43              Reg 2015    2596709
#> 44              Reg 2020    2804788
#> 45              Reg 2024    2865196
#> 46              Reg 2015    2963360
#> 47              Reg 2020    3228558
#> 48              Reg 2024    3245446
#> 49              Reg 2024    4904944
#> 50              Reg 2015    3781387
#> 51              Reg 2020    4404288
#> 52              Reg 2024    4545486
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
#>     psgc_code                                               area_name
#> 1  0100000000                                Region I (Ilocos Region)
#> 2  0200000000                              Region II (Cagayan Valley)
#> 3  0300000000                              Region III (Central Luzon)
#> 4  0400000000                                Region IV-A (CALABARZON)
#> 5  0500000000                                 Region V (Bicol Region)
#> 6  0600000000                             Region VI (Western Visayas)
#> 7  0700000000                            Region VII (Central Visayas)
#> 8  0800000000                           Region VIII (Eastern Visayas)
#> 9  0900000000                         Region IX (Zamboanga Peninsula)
#> 10 1000000000                            Region X (Northern Mindanao)
#> 11 1100000000                                Region XI (Davao Region)
#> 12 1200000000                               Region XII (SOCCSKSARGEN)
#> 13 1300000000                           National Capital Region (NCR)
#> 14 1400000000                  Cordillera Administrative Region (CAR)
#> 15 1600000000                                    Region XIII (Caraga)
#> 16 1700000000                                         MIMAROPA Region
#> 17 1800000000                              Negros Island Region (NIR)
#> 18 1900000000 Bangsamoro Autonomous Region In Muslim Mindanao (BARMM)
#>    geographic_level population_2015 population_2020 population_2024
#> 1               Reg         5026128         5301139         5342453
#> 2               Reg         3451410         3685744         3777608
#> 3               Reg        11218177        12422172        12989074
#> 4               Reg        14414774        16195042        16933234
#> 5               Reg         5796989         6082165         6064426
#> 6               Reg         7536383         7954723         4861911
#> 7               Reg         7396898         8081988         6640875
#> 8               Reg         4440150         4547150         4625929
#> 9               Reg         3629783         3875576         5089934
#> 10              Reg         4689302         5022768         5178326
#> 11              Reg         4893318         5243536         5389422
#> 12              Reg         4545276         4901486         4462776
#> 13              Reg        12877253        13484462        14001751
#> 14              Reg         1722006         1797660         1808985
#> 15              Reg         2596709         2804788         2865196
#> 16              Reg         2963360         3228558         3245446
#> 17              Reg              NA              NA         4904944
#> 18              Reg         3781387         4404288         4545486
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
#>   population year
#> 1    5026128 2015
#> 2    5301139 2020
#> 3    5342453 2024
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
#> 1 0100000000 0100000000       direct      Q1_2023    Q1_2026
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
