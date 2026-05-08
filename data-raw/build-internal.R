## data-raw/build-internal.R
## Builds psgc_releases (named list of data frames) and psgc_crosswalk
## (consecutive-pair crosswalk table) and saves them as internal package data.
##
## Run from the package root: Rscript data-raw/build-internal.R

library(jsonlite)

.RELEASES <- c(
  "Q1_2023", "Q4_2023", "April_2024", "Q2_2024",
  "Q3_2024", "Q4_2024", "Q1_2025", "Q2_2025",
  "July_2025", "Q3_2025", "Q4_2025", "Q1_2026"
)

# ── Helpers ───────────────────────────────────────────────────────────────────

load_population <- function(release) {
  f <- file.path("data-raw", paste0(release, "-all.json"))
  df <- jsonlite::fromJSON(f)[[1]]
  pop_list <- df$population_data
  pop_list <- pop_list[!vapply(pop_list, is.null, logical(1))]
  pop_list <- pop_list[vapply(pop_list, nrow, integer(1)) > 0L]
  if (length(pop_list) == 0L) return(NULL)
  pop_df <- do.call(rbind, pop_list)
  names(pop_df)[names(pop_df) == "code"] <- "psgc_code"
  pop_df$population <- as.integer(gsub("[^0-9]", "", pop_df$population))
  pop_df <- pop_df[nzchar(pop_df$psgc_code) & !is.na(pop_df$psgc_code), ]
  pop_df <- unique(pop_df)
  rownames(pop_df) <- NULL
  pop_df
}

load_release <- function(release) {
  f <- file.path("data-raw", paste0(release, "-all.json"))
  df <- jsonlite::fromJSON(f)[[1]]
  # Drop unneeded columns
  drop_cols <- c("population_data", "reg", "prv", "mun", "bgy", "status", "version")
  df <- df[, setdiff(names(df), drop_cols)]
  # Drop rows with empty or NA psgc_code (malformed entries)
  df <- df[nzchar(df$psgc_code) & !is.na(df$psgc_code), ]
  
  df$old_name <- ifelse(is.na(df$old_name) | !nzchar(df$old_name), NA_character_, df$old_name)
  df$city_class <- ifelse(is.na(df$city_class) | !nzchar(df$city_class), NA_character_, df$city_class)
  df$income_classification <- ifelse(is.na(df$income_classification) | !nzchar(df$income_classification) | df$income_classification == "-", NA_character_, df$income_classification)
  df$correspondence_code <- ifelse(is.na(df$correspondence_code) | !nzchar(df$correspondence_code), NA_character_, df$correspondence_code)
  df$urban_rural <- ifelse(is.na(df$urban_rural) | !nzchar(df$urban_rural), NA_character_, df$urban_rural)
  df$island_region <- ifelse(is.na(df$island_region) | !nzchar(df$island_region), NA_character_, df$island_region)
  df$area_name <- trimws(df$area_name)
  rownames(df) <- NULL
  df
}

# Convert trailing Roman numerals to Arabic (e.g. "Aniban II" → "Aniban 2")
roman_to_arabic <- function(x) {
  romans <- c(
    " XII$" = " 12", " XI$" = " 11", " X$" = " 10",
    " IX$" = " 9",  " VIII$" = " 8", " VII$" = " 7",
    " VI$" = " 6",  " IV$" = " 4",  " V$" = " 5",
    " III$" = " 3", " II$" = " 2",  " I$" = " 1"
  )
  for (pat in names(romans)) {
    x <- gsub(pat, romans[[pat]], x)
  }
  x
}

normalize_name <- function(x) {
  x <- trimws(x)
  x <- roman_to_arabic(x)   # apply before tolower so Roman patterns match
  x <- tolower(x)
  x <- gsub("[^a-z0-9 ]", "", x)
  gsub("\\s+", " ", x)
}

# First n digits of psgc_code that identify the parent unit
parent_prefix <- function(code, level) {
  result <- character(length(code))
  is_bgy    <- level == "Bgy"
  is_mun    <- level %in% c("Mun", "City", "SubMun")
  is_prov   <- level == "Prov"

  result[is_bgy]  <- substr(code[is_bgy],  1, 8)
  result[is_mun]  <- substr(code[is_mun],  1, 5)
  result[is_prov] <- substr(code[is_prov], 1, 2)
  result
}

# ── Consecutive-pair crosswalk ────────────────────────────────────────────────

build_pair_crosswalk <- function(old_df, new_df, from_release, to_release) {
  old_codes <- old_df$psgc_code
  new_codes <- new_df$psgc_code

  rows <- list()

  # 1. Direct: same code in both releases
  direct <- intersect(old_codes, new_codes)
  if (length(direct) > 0) {
    rows[["direct"]] <- data.frame(
      from_release = from_release,
      to_release   = to_release,
      old_code     = direct,
      new_code     = direct,
      mapping_type = "direct",
      stringsAsFactors = FALSE
    )
  }

  # 2. Candidates for renumbered / split / abolished
  disappeared <- setdiff(old_codes, new_codes)
  appeared    <- setdiff(new_codes, old_codes)

  if (length(disappeared) == 0) {
    return(do.call(rbind, rows))
  }

  old_miss <- old_df[old_df$psgc_code %in% disappeared, ]
  new_app  <- new_df[new_df$psgc_code %in% appeared, ]

  old_miss$norm_name <- normalize_name(old_miss$area_name)
  new_app$norm_name  <- normalize_name(new_app$area_name)
  old_miss$parent    <- parent_prefix(old_miss$psgc_code, old_miss$geographic_level)
  new_app$parent     <- parent_prefix(new_app$psgc_code,  new_app$geographic_level)

  unmatched <- character(0)
  renumbered_rows <- list()
  split_rows      <- list()

  for (i in seq_len(nrow(old_miss))) {
    oi <- old_miss[i, ]

    # Candidates share level + parent prefix
    cands <- new_app[
      new_app$geographic_level == oi$geographic_level &
        new_app$parent == oi$parent, ,
      drop = FALSE
    ]
    if (nrow(cands) == 0) {
      unmatched <- c(unmatched, oi$psgc_code)
      next
    }

    # Exact normalised-name match
    exact <- cands[cands$norm_name == oi$norm_name, , drop = FALSE]

    if (nrow(exact) == 1) {
      renumbered_rows[[length(renumbered_rows) + 1]] <- data.frame(
        from_release = from_release,
        to_release   = to_release,
        old_code     = oi$psgc_code,
        new_code     = exact$psgc_code,
        mapping_type = "renumbered",
        stringsAsFactors = FALSE
      )
    } else if (nrow(exact) > 1) {
      split_rows[[length(split_rows) + 1]] <- data.frame(
        from_release = from_release,
        to_release   = to_release,
        old_code     = oi$psgc_code,
        new_code     = exact$psgc_code,
        mapping_type = "split",
        stringsAsFactors = FALSE
      )
    } else {
      unmatched <- c(unmatched, oi$psgc_code)
    }
  }

  if (length(renumbered_rows) > 0) rows[["renumbered"]] <- do.call(rbind, renumbered_rows)
  if (length(split_rows) > 0)      rows[["split"]]      <- do.call(rbind, split_rows)

  # 3. Abolished: no successor found
  if (length(unmatched) > 0) {
    rows[["abolished"]] <- data.frame(
      from_release = from_release,
      to_release   = to_release,
      old_code     = unmatched,
      new_code     = NA_character_,
      mapping_type = "abolished",
      stringsAsFactors = FALSE
    )
  }

  do.call(rbind, rows)
}

# ── Load all releases ─────────────────────────────────────────────────────────

message("Loading releases...")
psgc_releases <- setNames(
  lapply(.RELEASES, load_release),
  .RELEASES
)
message("  Loaded: ", paste(.RELEASES, collapse = ", "))

# ── Load population data ──────────────────────────────────────────────────────

message("Loading population data...")
psgc_population <- setNames(
  lapply(.RELEASES, load_population),
  .RELEASES
)
message("  Population data loaded for: ", paste(.RELEASES, collapse = ", "))

# ── Build consecutive-pair crosswalk ─────────────────────────────────────────

message("Building crosswalk chain...")
pair_list <- vector("list", length(.RELEASES) - 1)
for (i in seq_len(length(.RELEASES) - 1)) {
  fr <- .RELEASES[i]
  to <- .RELEASES[i + 1]
  message("  ", fr, " -> ", to)
  pair_list[[i]] <- build_pair_crosswalk(
    psgc_releases[[fr]], psgc_releases[[to]], fr, to
  )
}
psgc_crosswalk <- do.call(rbind, pair_list)
rownames(psgc_crosswalk) <- NULL

# ── Apply manual overrides ────────────────────────────────────────────────────

overrides_file <- "data-raw/crosswalk-overrides.csv"
overrides <- read.csv(overrides_file, stringsAsFactors = FALSE)

if (nrow(overrides) > 0) {
  message("Applying ", nrow(overrides), " manual overrides...")
  # Remove auto-inferred rows that are superseded by an override
  override_key <- paste(overrides$from_release, overrides$to_release, overrides$old_code)
  auto_key     <- paste(psgc_crosswalk$from_release, psgc_crosswalk$to_release, psgc_crosswalk$old_code)
  psgc_crosswalk <- psgc_crosswalk[!auto_key %in% override_key, ]

  override_rows <- overrides[, c("old_code", "new_code", "mapping_type", "from_release", "to_release")]
  psgc_crosswalk <- rbind(psgc_crosswalk, override_rows)
}

message("Crosswalk rows: ", nrow(psgc_crosswalk))

# ── Summary ───────────────────────────────────────────────────────────────────

tbl <- table(psgc_crosswalk$mapping_type)
message("Mapping type breakdown:")
for (nm in names(tbl)) message("  ", nm, ": ", tbl[[nm]])

# ── Save internal data ────────────────────────────────────────────────────────

message("Saving internal data...")
usethis::use_data(psgc_releases, psgc_crosswalk, psgc_population, internal = TRUE, overwrite = TRUE, compress = "xz")
message("Done. R/sysdata.rda written.")
