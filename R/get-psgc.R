#' Get PSGC data for a specific release
#'
#' @param release A release name from [list_releases()]. Defaults to
#'   [latest_release()].
#' @param geographic_level A character vector of geographic levels to filter by.
#'   Accepts canonical codes (`"Reg"`, `"Prov"`, `"City"`, `"Mun"`,
#'   `"SubMun"`, `"Bgy"`) as well as common aliases such as `"Region"`,
#'   `"Province"`, `"Municipality"`, `"Barangay"`, `"Sub-Municipality"`, etc.
#'   Use `"city_mun"` (or aliases like `"City-Municipality"`) to include both
#'   cities and municipalities. `NULL` (default) returns all levels.
#' @param include_population_data Logical. If `TRUE`, census population figures
#'   are joined onto the result, adding `population` (integer) and `year`
#'   columns. Each geographic unit produces one row per available census year.
#'   Defaults to `FALSE`.
#' @return A data frame of PSGC entries for the given release, optionally
#'   filtered to the requested geographic level(s) and/or enriched with
#'   population data.
#' @export
#' @examples
#' head(get_psgc())
#' get_psgc("Q1_2023")
#' get_psgc(geographic_level = "Reg")
#' get_psgc(geographic_level = "Region")
#' get_psgc(geographic_level = "city_mun")
#' get_psgc(geographic_level = c("Prov", "City"))
#' get_psgc(geographic_level = "Reg", include_population_data = TRUE)
get_psgc <- function(release = latest_release(), geographic_level = NULL, include_population_data = FALSE) {
  if (!release %in% .RELEASES) {
    cli::cli_abort(
      "Unknown release {.val {release}}. Use {.fn list_releases} to see available releases."
    )
  }
  df <- psgc_releases[[release]]
  if (!is.null(geographic_level)) {
    canonical <- .resolve_geo_levels(geographic_level)
    df <- df[df$geographic_level %in% canonical, ]
  }
  if (include_population_data) {
    pop <- psgc_population[[release]]
    pop_split <- split(pop[, c("population", "year")], pop$psgc_code)
    empty <- data.frame(population = integer(0), year = integer(0))
    df$population_data <- lapply(df$psgc_code, function(code) {
      res <- pop_split[[code]]
      if (is.null(res)) empty else { rownames(res) <- NULL; res }
    })
  }
  df
}
