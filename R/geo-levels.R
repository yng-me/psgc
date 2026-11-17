# Internal alias table and resolver for the geographic_level argument.

# Named character vector: lowercase alias -> canonical PSGC geographic_level.
# Lookup lowercases the input, so "Region", "REGION" and "region" all match.
.GEO_LEVEL_ALIASES <- c(
  "reg" = "Reg", "region" = "Reg",
  "prov" = "Prov", "province" = "Prov",
  "city" = "City",
  "mun" = "Mun", "municipal" = "Mun", "municipality" = "Mun",
  "submun" = "SubMun", "sub_mun" = "SubMun",
  "sub-municipal" = "SubMun", "sub-municipality" = "SubMun",
  "bgy" = "Bgy", "brgy" = "Bgy", "barangay" = "Bgy",
  "dist" = "Dist", "district" = "Dist",
  "sgu" = "SGU"
)

# Lowercase aliases that expand to both City and Mun.
.CITY_MUN_ALIASES <- c(
  "city_mun", "city-mun", "citymun",
  "city-municipal", "city--municipal", "city-municipality"
)

# Resolve a user-supplied character vector to canonical PSGC geographic levels.
# Errors with an informative message on any unrecognised input.
.resolve_geo_levels <- function(geographic_level) {
  resolved <- lapply(tolower(trimws(geographic_level)), function(lv) {
    if (lv %in% .CITY_MUN_ALIASES) return(c("City", "Mun"))
    unname(.GEO_LEVEL_ALIASES[lv])
  })

  bad <- geographic_level[vapply(resolved, anyNA, logical(1))]
  if (length(bad) > 0) {
    shown <- c("Reg", "Prov", "City", "Mun", "SubMun", "Bgy", "Dist", "SGU", "city_mun")
    cli::cli_abort(
      c(
        "Unknown geographic level{?s}: {.val {bad}}.",
        i = "Canonical levels: {.val {shown}}.",
        i = "Many aliases are accepted (e.g. {.val {'Region'}}, {.val {'Barangay'}}, {.val {'city_mun'}})."
      )
    )
  }

  unique(unlist(resolved))
}
