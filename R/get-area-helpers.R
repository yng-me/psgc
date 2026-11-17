.get_prov_or_huc <- function(release, geographic_level, region = NULL, trim_area_code = TRUE, ...) {

  df_base <- get_psgc(release = release, geographic_level = geographic_level, ...)

  if(geographic_level == "city") {
    df_base <- df_base[toupper(df_base$city_class) %in% "HUC", ]
  }

  df_base <- cbind(df_base, .parse_psgc(df_base$psgc_code))

  if(!is.null(region)) {
    df_base <- df_base[.parse_area_filter(region, df_base$region_code, width = 2L), , drop = FALSE]
  }

  df_base <- df_base[order(df_base$psgc_code), ]

  if (trim_area_code) {

    df <- data.frame(
      region_code = df_base$region_code,
      area_code = df_base$province_code,
      area_name = df_base$area_name
    )

  } else {

    df <- data.frame(
      area_code = df_base$psgc_code,
      area_name = df_base$area_name
    )
  }

  .add_population(df, df_base)
}

.get_city_mun <- function(df_base, region = NULL, province = NULL, trim_area_code = TRUE) {

  if (!is.data.frame(df_base)) {
    stop(
      "df_base must be a data.frame.",
      call. = FALSE
    )
  }

  if (!"psgc_code" %in% names(df_base)) {
    stop(
      "df_base has no 'psgc_code' column.",
      call. = FALSE
    )
  }

  parts <- .parse_psgc(df_base$psgc_code)

  df_base <- cbind(
    df_base,
    parts
  )

  if (!is.null(region)) {

    keep <- .parse_area_filter(
      region,
      df_base$region_code,
      width = 2L
    )

    df_base <- df_base[
      keep,
      ,
      drop = FALSE
    ]
  }

  if (!is.null(province)) {

    # 3 digits for current 10-digit PSGCs.
    #
    # For legacy 9-digit PSGCs, province_code itself is 2 digits.
    # Therefore normalize against the actual extracted codes rather
    # than deriving a width from the remaining data.
    if (length(df_base$province_code)) {

      widths <- unique(
        nchar(df_base$province_code)
      )

      keep <- rep(FALSE, nrow(df_base))

      for (w in widths) {

        idx <- nchar(df_base$province_code) == w

        keep[idx] <- .parse_area_filter(
          province,
          df_base$province_code[idx],
          width = w
        )
      }

      df_base <- df_base[
        keep,
        ,
        drop = FALSE
      ]

    } else {

      # Preserve the expected empty result.
      df_base <- df_base[
        logical(0),
        ,
        drop = FALSE
      ]
    }
  }

  df_base <- df_base[order(df_base$psgc_code), ]

  if (trim_area_code) {

    df <- data.frame(
      region_code = df_base$region_code,
      province_code = df_base$province_code,
      area_code = df_base$city_mun_code,
      area_name = df_base$area_name,
      stringsAsFactors = FALSE
    )

  } else {

    df <- data.frame(
      area_code = df_base$psgc_code,
      area_name = df_base$area_name,
      stringsAsFactors = FALSE
    )
  }

  .add_population(df, df_base)
}

.parse_psgc <- function(psgc_code) {

  psgc_code <- as.character(psgc_code)

  if (anyNA(psgc_code)) {
    stop("psgc_code contains NA values.", call. = FALSE)
  }

  bad <- !nchar(psgc_code) %in% c(9L, 10L) |
    !grepl("^[0-9]+$", psgc_code)

  if (any(bad)) {
    stop(
      "Invalid PSGC code(s): ",
      paste(unique(psgc_code[bad]), collapse = ", "),
      call. = FALSE
    )
  }

  is10 <- nchar(psgc_code) == 10L

  data.frame(
    region_code = substr(psgc_code, 1L, 2L),

    province_code = ifelse(
      is10,
      substr(psgc_code, 3L, 5L),
      substr(psgc_code, 3L, 4L)
    ),

    city_mun_code = ifelse(
      is10,
      substr(psgc_code, 6L, 7L),
      substr(psgc_code, 5L, 6L)
    ),

    barangay_code = ifelse(
      is10,
      substr(psgc_code, 8L, 10L),
      substr(psgc_code, 7L, 9L)
    ),

    stringsAsFactors = FALSE
  )
}

.normalize_area_codes <- function(x, width) {

  x <- as.character(x)

  if (anyNA(x)) {
    stop(
      "Area filters cannot contain NA.",
      call. = FALSE
    )
  }

  x <- trimws(x)

  if (!length(x)) {
    return(character())
  }

  if (any(!grepl("^[0-9]+$", x))) {
    stop(
      "Area codes must contain digits only.",
      call. = FALSE
    )
  }

  too_long <- nchar(x) > width

  if (any(too_long)) {
    stop(
      "Area code(s) exceed the expected ",
      width,
      "-digit width: ",
      paste(unique(x[too_long]), collapse = ", "),
      call. = FALSE
    )
  }

  sprintf(
    paste0("%0", width, "d"),
    as.integer(x)
  )
}

.parse_area_filter <- function(x, valid_codes, width) {

  if (is.null(x)) {
    return(rep(TRUE, length(valid_codes)))
  }

  x <- as.character(x)

  if (anyNA(x)) {
    stop(
      "Area filters cannot contain NA.",
      call. = FALSE
    )
  }

  # Accept both:
  #   c("1", "2")
  #   "1,2"
  #   "1, 2"
  x <- unlist(
    strsplit(x, ",", fixed = TRUE),
    use.names = FALSE
  )

  x <- trimws(x)
  x <- x[nzchar(x)]

  if (!length(x)) {
    return(rep(FALSE, length(valid_codes)))
  }

  if (!is.numeric(width) ||
      length(width) != 1L ||
      is.na(width) ||
      width < 1 ||
      width != as.integer(width)) {

    stop(
      "'width' must be a single positive integer.",
      call. = FALSE
    )
  }

  width <- as.integer(width)

  numeric_filter <- grepl("^[0-9]+$", x)

  if (any(numeric_filter)) {
    x[numeric_filter] <- .normalize_area_codes(
      x[numeric_filter],
      width
    )
  } else {
    stop(
      "Area codes must contain digits only.",
      call. = FALSE
    )
  }

  valid_codes %in% x
}

.get_latest_population <- function(x) {

  if (is.null(x) ||
      is.null(x$year) ||
      is.null(x$population) ||
      !length(x$year) ||
      !length(x$population)) {

    return(NA_real_)
  }

  year <- suppressWarnings(as.integer(x$year))
  population <- suppressWarnings(as.integer(x$population))

  ok <- !is.na(year) & !is.na(population)

  if (!any(ok)) {
    return(NA_real_)
  }

  latest_year <- max(year[ok])

  # If there are duplicate observations for the latest year,
  # use the first one.
  i <- which(ok & year == latest_year)[1L]

  population[i]

}

.add_population <- function(df, df_base) {

  if ("population_data" %in% names(df_base)) {

    df$population <- vapply(
      df_base$population_data,
      .get_latest_population,
      integer(1)
    )
  }

  df
}

.shorten_region_name <- function(regions, proper_name) {

  special <- grepl("\\b(NCR|NIR|B?ARMM|CAR)\\b", regions, ignore.case = TRUE)

  if (proper_name) {
    
    regions <- ifelse(
      special,
      trimws(gsub("\\s*\\([^)]*\\)", "", regions)),
      trimws(sub(".*\\(([^)]*)\\).*", "\\1", regions))
    )

  } else {

    regions <- ifelse(
      special,
      trimws(sub(".*\\(([^)]*)\\).*", "\\1", regions)),
      trimws(gsub("\\s*\\([^)]*\\)", "", regions))
    )

    regions <- ifelse(
      grepl("^MIMAROPA", regions, ignore.case = TRUE),
      "MIMAROPA",
      regions
    )
  }
}