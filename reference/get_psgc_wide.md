# Get PSGC data in wide (denormalised) format

Returns a data frame with one row per barangay and all four geographic
levels—region, province, city/municipality, and barangay—spread into
separate columns. Highly Urbanised Cities (HUCs) and Independent
Component Cities (ICCs) are included as pseudo-province entries so their
barangays have a \`province\` value. Barangays in areas with no province
layer in the PSGC (e.g. Pateros in NCR, City of Isabela, Special
Geographic Areas) will have \`NA\` for \`province\` and
\`province_code\`.

## Usage

``` r
get_psgc_wide(release = latest_release())
```

## Arguments

- release:

  A release name from \[list_releases()\]. Defaults to
  \[latest_release()\].

## Value

A data frame with one row per barangay and the following columns, in
order:

- \`area_code\`:

  10-digit PSGC code of the barangay.

- \`region_code\`:

  10-digit PSGC code of the region.

- \`province_code\`:

  10-digit PSGC code of the province (or of the HUC/ICC acting as
  province).

- \`city_mun_code\`:

  10-digit PSGC code of the city, municipality, or sub-municipality.
  \`NA\` for barangays that sit directly under an HUC with no
  intervening city/municipality layer.

- \`region\`:

  Region name.

- \`province\`:

  Province name (or HUC/ICC name for province-free cities). \`NA\` for
  areas with no province layer (e.g. Pateros in NCR, City of Isabela,
  Special Geographic Areas).

- \`city_mun\`:

  City / municipality / sub-municipality name. \`NA\` for HUC barangays.

- \`barangay\`:

  Barangay name.

- \`urban_rural\`:

  Urban/rural classification of the barangay.

- \`island_region\`:

  Island group of the barangay.

## Examples

``` r
head(get_psgc_wide())
#>    area_code region_code province_code city_mun_code                   region
#> 1 0102801001  0100000000    0102800000    0102801000 Region I (Ilocos Region)
#> 2 0102802001  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 3 0102802002  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 4 0102802003  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 5 0102802004  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 6 0102802005  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#>       province city_mun   barangay urban_rural island_region
#> 1 Ilocos Norte    Adams      Adams           R             L
#> 2 Ilocos Norte  Bacarra       Bani           R             L
#> 3 Ilocos Norte  Bacarra      Buyon           R             L
#> 4 Ilocos Norte  Bacarra   Cabaruan           R             L
#> 5 Ilocos Norte  Bacarra Cabulalaan           R             L
#> 6 Ilocos Norte  Bacarra Cabusligan           R             L
head(get_psgc_wide("Q1_2023"))
#>    area_code region_code province_code city_mun_code                   region
#> 1 0102801001  0100000000    0102800000    0102801000 Region I (Ilocos Region)
#> 2 0102802001  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 3 0102802002  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 4 0102802003  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 5 0102802004  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#> 6 0102802005  0100000000    0102800000    0102802000 Region I (Ilocos Region)
#>       province city_mun   barangay urban_rural island_region
#> 1 Ilocos Norte    Adams      Adams           R             L
#> 2 Ilocos Norte  Bacarra       Bani           R             L
#> 3 Ilocos Norte  Bacarra      Buyon           R             L
#> 4 Ilocos Norte  Bacarra   Cabaruan           R             L
#> 5 Ilocos Norte  Bacarra Cabulalaan           R             L
#> 6 Ilocos Norte  Bacarra Cabusligan           R             L
```
