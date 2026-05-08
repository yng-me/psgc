# Internal alias table and resolver for the geographic_level argument.

# Named character vector: alias -> canonical PSGC geographic_level.
.GEO_LEVEL_ALIASES <- c(
  # Region
  "Reg" = "Reg", "reg" = "Reg", "REG" = "Reg",
  "Region" = "Reg", "region" = "Reg", "REGION" = "Reg",
  # Province
  "Prov" = "Prov", "prov" = "Prov", "PROV" = "Prov",
  "Province" = "Prov", "province" = "Prov", "PROVINCE" = "Prov",
  # City
  "City" = "City", "city" = "City", "CITY" = "City",
  # Municipality
  "Mun" = "Mun", "mun" = "Mun", "MUN" = "Mun",
  "Municipal" = "Mun", "municipal" = "Mun", "MUNICIPAL" = "Mun",
  "Municipality" = "Mun", "municipality" = "Mun", "MUNICIPALITY" = "Mun",
  # Sub-Municipality
  "SubMun" = "SubMun", "submun" = "SubMun", "SUBMUN" = "SubMun",
  "sub_mun" = "SubMun", "SUB_MUN" = "SubMun",
  "Sub-Municipal" = "SubMun", "sub-municipal" = "SubMun", "SUB-MUNICIPAL" = "SubMun",
  "Sub-Municipality" = "SubMun", "sub-municipality" = "SubMun", "SUB-MUNICIPALITY" = "SubMun",
  # Barangay
  "Bgy" = "Bgy", "bgy" = "Bgy", "BGY" = "Bgy",
  "Brgy" = "Bgy", "brgy" = "Bgy", "BRGY" = "Bgy",
  "Barangay" = "Bgy", "barangay" = "Bgy", "BARANGAY" = "Bgy"
)

# Aliases that expand to both City and Mun.
.CITY_MUN_ALIASES <- c(
  "city_mun", "city-mun", "CityMun", "citymun", "CITYMUN", "CITY_MUN",
  "City-Municipal", "city--municipal", "CITY-MUNICIPAL",
  "City-Municipality", "city-municipality", "CITY-MUNICIPALITY"
)

# Resolve a user-supplied character vector to canonical PSGC geographic levels.
# Errors with an informative message on any unrecognised input.
.resolve_geo_levels <- function(geographic_level) {
  resolved <- lapply(geographic_level, function(lv) {
    if (lv %in% .CITY_MUN_ALIASES) return(c("City", "Mun"))
    canonical <- .GEO_LEVEL_ALIASES[lv]
    if (is.na(canonical)) return(NA_character_)
    unname(canonical)
  })

  bad <- geographic_level[vapply(resolved, function(x) anyNA(x), logical(1))]
  if (length(bad) > 0) {
    shown <- c("Reg", "Prov", "City", "Mun", "SubMun", "Bgy", "city_mun")
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
