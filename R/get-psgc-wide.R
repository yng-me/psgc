#' Get PSGC data in wide (denormalised) format
#'
#' Returns a data frame with one row per barangay and all four geographic
#' levels—region, province, city/municipality, and barangay—spread into
#' separate columns. Highly Urbanised Cities (HUCs) and Independent Component
#' Cities (ICCs) are included as pseudo-province entries so their barangays
#' have a `province` value. Barangays in areas with no province layer in the
#' PSGC (e.g. Pateros in NCR, City of Isabela, Special Geographic Areas)
#' will have `NA` for `province` and `province_code`.
#'
#' @param release A release name from [list_releases()]. Defaults to
#'   [latest_release()].
#' @return A data frame with one row per barangay and the following columns, in
#'   order:
#'   \describe{
#'     \item{`area_code`}{10-digit PSGC code of the barangay.}
#'     \item{`region_code`}{10-digit PSGC code of the region.}
#'     \item{`province_code`}{10-digit PSGC code of the province (or of the
#'       HUC/ICC acting as province).}
#'     \item{`city_mun_code`}{10-digit PSGC code of the city, municipality, or
#'       sub-municipality. `NA` for barangays that sit directly under an HUC
#'       with no intervening city/municipality layer.}
#'     \item{`region`}{Region name.}
#'     \item{`province`}{Province name (or HUC/ICC name for province-free
#'       cities). `NA` for areas with no province layer (e.g. Pateros in NCR,
#'       City of Isabela, Special Geographic Areas).}
#'     \item{`city_mun`}{City / municipality / sub-municipality name. `NA` for
#'       HUC barangays.}
#'     \item{`barangay`}{Barangay name.}
#'     \item{`urban_rural`}{Urban/rural classification of the barangay.}
#'     \item{`island_region`}{Island group of the barangay.}
#'   }
#' @export
#' @examples
#' head(get_psgc_wide())
#' head(get_psgc_wide("Q1_2023"))
get_psgc_wide <- function(release = latest_release()) {
  
  if (!release %in% .RELEASES) {
    cli::cli_abort(
      "Unknown release {.val {release}}. Use {.fn list_releases} to see available releases."
    )
  }

  brgys <- get_psgc(release = release, geographic_level = "brgy")
  brgys <- brgys[, c("psgc_code", "area_name", "urban_rural", "island_region")]

  regs      <- get_psgc(release = release, geographic_level = "reg")[, c("psgc_code", "area_name")]
  city_muns <- get_psgc(release = release, geographic_level = c("city_mun", "submun"))[, c("psgc_code", "area_name")]

  # Build the province lookup from the raw release data rather than via
  # get_psgc() so that special entries with an empty geographic_level (e.g.
  # "City of Isabela (Not a Province)", "Special Geographic Area") are included.
  # Structurally, province-level entries have zeros in digits 6–10 but NOT in
  # digits 3–10 (which would make them region entries).
  all_df <- psgc_releases[[release]]
  provs <- all_df[
    substr(all_df$psgc_code, 6, 10) == "00000" &
      substr(all_df$psgc_code, 3, 10) != "00000000",
    c("psgc_code", "area_name")
  ]

  colnames(regs)      <- c("region_code",   "region")
  colnames(provs)     <- c("province_code",  "province")
  colnames(city_muns) <- c("city_mun_code",  "city_mun")
  colnames(brgys)     <- c("area_code", "barangay", "urban_rural", "island_region")

  # Derive parent-level codes from each barangay's 10-digit code.
  brgys$region_code   <- paste0(substr(brgys$area_code, 1, 2), "00000000")
  brgys$province_code <- paste0(substr(brgys$area_code, 1, 5), "00000")
  brgys$city_mun_code <- paste0(substr(brgys$area_code, 1, 7), "000")

  psgc_all <- merge(brgys,    city_muns, by = "city_mun_code",  all.x = TRUE)
  psgc_all <- merge(psgc_all, provs,     by = "province_code",  all.x = TRUE)
  psgc_all <- merge(psgc_all, regs,      by = "region_code",    all.x = TRUE)

  # HUC barangays have no city/municipality layer — digits 6–7 of the area
  # code are "00", meaning the barangay sits directly under the HUC (province).
  huc <- substr(psgc_all$area_code, 6, 7) == "00"
  psgc_all$city_mun[huc]      <- NA_character_
  psgc_all$city_mun_code[huc] <- NA_character_

  psgc_all <- psgc_all[
    order(psgc_all$region_code, psgc_all$province_code, psgc_all$city_mun_code, psgc_all$area_code),
  ]
  rownames(psgc_all) <- NULL

  psgc_all[, c(
    "area_code",
    "region_code",
    "province_code",
    "city_mun_code",
    "region",
    "province",
    "city_mun",
    "barangay",
    "urban_rural",
    "island_region"
  )]
}
