#' Get population data for a specific release
#'
#' Returns the census population figures bundled with a PSGC release.
#'
#' @param release A release name from [list_releases()]. Defaults to
#'   [latest_release()].
#' @param details Logical. If `TRUE`, adds `area_name` and `geographic_level`
#'   columns from the PSGC release data. Defaults to `FALSE`.
#' @param geographic_level A character vector of geographic levels to filter by.
#'   Accepts the same canonical codes and aliases as [get_psgc()] (e.g.
#'   `"Reg"`, `"Region"`, `"Prov"`, `"city_mun"`, `"Barangay"`, etc.).
#'   `NULL` (default) returns all levels. Implies `details = TRUE` internally
#'   to resolve the filter; the column is only included in the result when
#'   `details = TRUE` is also requested.
#' @param wide Logical. If `TRUE`, pivots census years to columns named
#'   `population_<year>` (e.g. `population_2015`, `population_2020`,
#'   `population_2024`), yielding one row per PSGC code. Defaults to `FALSE`.
#' @return A data frame. In long format (default): columns `psgc_code`,
#'   `population`, `year`, plus optionally `area_name` and `geographic_level`.
#'   In wide format: columns `psgc_code`, `population_<year>` per census year,
#'   plus optionally `area_name` and `geographic_level`.
#' @importFrom stats setNames
#' @export
#' @examples
#' head(get_population())
#' get_population("Q1_2023")
#' get_population(details = TRUE)
#' get_population(geographic_level = "Reg")
#' get_population(geographic_level = "Region", wide = TRUE)
#' get_population(geographic_level = "Reg", wide = TRUE, details = TRUE)
get_population <- function(release = latest_release(), details = FALSE, geographic_level = NULL, wide = FALSE) {
  if (!release %in% .RELEASES) {
    cli::cli_abort(
      "Unknown release {.val {release}}. Use {.fn list_releases} to see available releases."
    )
  }

  pop <- psgc_population[[release]]

  if (!is.null(geographic_level)) {
    canonical <- .resolve_geo_levels(geographic_level)
    psgc_df   <- psgc_releases[[release]]
    keep      <- psgc_df$psgc_code[psgc_df$geographic_level %in% canonical]
    pop       <- pop[pop$psgc_code %in% keep, ]
  }

  if (details || !is.null(geographic_level)) {
    psgc_df <- psgc_releases[[release]]
    detail_cols <- c("psgc_code", "area_name", "geographic_level")
    pop <- merge(pop, psgc_df[, detail_cols], by = "psgc_code", all.x = TRUE)
    if (!details) {
      pop$area_name        <- NULL
      pop$geographic_level <- NULL
    }
  }

  if (wide) {
    years <- sort(unique(pop$year))
    year_cols <- paste0("population_", years)
    wide_list <- lapply(split(pop, pop$psgc_code), function(rows) {
      yr_pop <- setNames(
        as.list(rows$population[match(years, rows$year)]),
        year_cols
      )
      base <- rows[1L, setdiff(names(rows), c("population", "year")), drop = FALSE]
      rownames(base) <- NULL
      cbind(base, as.data.frame(yr_pop, stringsAsFactors = FALSE))
    })
    pop <- do.call(rbind, wide_list)
    rownames(pop) <- NULL
    ordered_cols <- c(
      "psgc_code",
      intersect(c("area_name", "geographic_level"), names(pop)),
      year_cols
    )
    pop <- pop[, ordered_cols, drop = FALSE]
  } else {
    ordered_cols <- c(
      "psgc_code",
      intersect(c("area_name", "geographic_level"), names(pop)),
      "year",
      "population"
    )
    pop <- pop[, ordered_cols, drop = FALSE]
  }

  pop
}
