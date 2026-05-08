# psgc <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/yng-me/psgc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yng-me/psgc/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/psgc)](https://CRAN.R-project.org/package=psgc)
<!-- badges: end -->

`psgc` provides access to the **Philippine Standard Geographic Code (PSGC)** — the official classification system for geographic areas in the Philippines published by the **Philippine Statistics Authority (PSA)**. It bundles 12 releases (Q1 2023 – Q1 2026) and exposes them through a small, consistent set of functions.

## Installation

```r
# Install from CRAN
install.packages("psgc")

# Or install the development version from GitHub
# install.packages("pak")
pak::pak("yng-me/psgc")
```

## Overview

| Function | What it does |
|---|---|
| `list_releases()` | List all bundled PSA releases |
| `latest_release()` | Name of the most recent release |
| `get_psgc()` | Full PSGC table, with optional level filter and population |
| `psgc_info()` | Metadata for one or more PSGC codes |
| `get_population()` | Census population figures (long or wide) |
| `map_psgc()` | Trace codes forward across releases |

Every function defaults to the latest release. Pass a `release` argument to work with older data.

## Usage

### Browse the full list

```r
library(psgc)

# All geographic areas in the latest release
ph <- get_psgc()
nrow(ph)
#> [1] 42046

head(ph)
#>    psgc_code                     area_name geographic_level
#> 1 0100000000       Region I - Ilocos Region              Reg
#> 2 0102800000               Ilocos Norte              Prov
#> ...
```

### Filter by geographic level

Plain English aliases are accepted — no need to memorise codes:

```r
get_psgc(geographic_level = "Region")
get_psgc(geographic_level = "Province")
get_psgc(geographic_level = "Barangay")

# Cities and municipalities together
get_psgc(geographic_level = "city_mun")

# Multiple levels at once
get_psgc(geographic_level = c("City", "Municipality"))
```

### Look up a specific code

```r
psgc_info("0100000000")           # Region I
psgc_info(c("0100000000", "0102800000"))  # batch lookup

# Short codes are accepted — trailing zeros are added automatically
psgc_info("01")      # → "0100000000" (Region I)
psgc_info("01028")   # → "0102800000" (Ilocos Norte)
```

### Population data

```r
# Long format (default)
get_population(geographic_level = "Region", details = TRUE)
#>    psgc_code                   area_name geographic_level  year population
#> 1 0100000000 Region I - Ilocos Region              Reg  2015    5026128
#> ...

# Wide format — one row per area, one column per census year
get_population(geographic_level = "Region", details = TRUE, wide = TRUE)
#>    psgc_code                   area_name geographic_level population_2015 population_2020 population_2024
#> 1 0100000000 Region I - Ilocos Region              Reg         5026128         5301139         5696141
#> ...
```

### Attach population to the PSGC table

```r
regions <- get_psgc(
  geographic_level        = "Region",
  include_population_data = TRUE
)

# population_data is a nested list-column — one data frame per row
regions$population_data[[1]]
#>   population  year
#> 1    5026128  2015
#> 2    5301139  2020
#> 3    5696141  2024
```

### Track codes across releases

```r
# What is the current code for this 2023-era code?
map_psgc("0100000000")

# Map to a specific target release
map_psgc("0100000000", to = "Q4_2023")
```

`mapping_type` tells you what changed: `"direct"` (unchanged), `"renumbered"`, `"split"`, `"merged"`, or `"abolished"` (new code will be `NA`).

## Geographic levels

| Code | Aliases accepted | Description |
|---|---|---|
| `Reg` | `Region`, `region`, `REG`, … | Region |
| `Prov` | `Province`, `province`, `PROV`, … | Province |
| `City` | `City`, `city`, `CITY` | City |
| `Mun` | `Municipality`, `municipal`, `MUN`, … | Municipality |
| `SubMun` | `Sub-Municipality`, `SubMun`, `sub_mun`, … | Sub-municipality |
| `Bgy` | `Barangay`, `Brgy`, `barangay`, `BGY`, … | Barangay |
| *(special)* | `city_mun`, `City-Municipality`, … | Cities **and** Municipalities |

## Bundled releases

```r
list_releases()
#>  [1] "Q1_2023"    "Q4_2023"    "April_2024" "Q2_2024"    "Q3_2024"
#>  [6] "Q4_2024"    "Q1_2025"    "Q2_2025"    "July_2025"  "Q3_2025"
#> [11] "Q4_2025"    "Q1_2026"
```

## License

MIT © Bhas Abdulsamad
