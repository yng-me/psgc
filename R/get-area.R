get_regions <- function(release = latest_release(), ..., trim_area_code = TRUE, shorten_name = FALSE, proper_name = TRUE) {

  df_base <- get_psgc(
    release = release,
    geographic_level = "region",
    ...
  )

  if (trim_area_code) {
    df_base$psgc_code <- substr(df_base$psgc_code, 1, 2)
  }

  df_base <- df_base[order(df_base$psgc_code), ]

  if(shorten_name) {
    df_base$area_name <- .shorten_region_name(df_base$area_name, proper_name)
  }

  df <- data.frame(
    area_code = df_base$psgc_code,
    area_name = df_base$area_name
  )

  .add_population(df, df_base)
}

get_provinces <- function(release = latest_release(), ..., region = NULL, trim_area_code = TRUE) {

  .get_prov_or_huc(
    release = release,
    geographic_level = "province",
    region = region,
    trim_area_code = trim_area_code,
    ...
  )
}

get_hucs <- function(release = latest_release(), ..., region = NULL, trim_area_code = TRUE) {

  .get_prov_or_huc(
    release = release,
    geographic_level = "city",
    region = region,
    trim_area_code = trim_area_code,
    ...
  )
}

get_cities <- function(release = latest_release(), ..., region = NULL, province = NULL, trim_area_code = TRUE, include_hucs = FALSE) {

  df_base <- get_psgc(release = release, geographic_level = "city", ...)
  if(!include_hucs) { df_base <- df_base[!toupper(df_base$city_class) %in% "HUC", ] }
  .get_city_mun(df_base, region, province, trim_area_code)

}

get_muns <- function(release = latest_release(), ..., region = NULL, province = NULL, trim_area_code = TRUE, include_cities = TRUE) {

  level <- "mun"

  if (include_cities) {
    level <- c("mun", "city")
  }

  df_base <- get_psgc(
    release = release,
    geographic_level = level,
    ...
  )

  .get_city_mun(
    df_base = df_base,
    region = region,
    province = province,
    trim_area_code = trim_area_code
  )
}

get_barangays <- function(release = latest_release(), ..., region = NULL, province = NULL, city_mun = NULL, trim_area_code = TRUE) {

  df_base <- get_psgc(
    release = release,
    geographic_level = "barangay",
    ...
  )

  if (!is.data.frame(df_base)) {
    stop(
      "get_psgc() must return a data.frame.",
      call. = FALSE
    )
  }

  if (!"psgc_code" %in% names(df_base)) {
    stop(
      "get_psgc() result has no 'psgc_code' column.",
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

      df_base <- df_base[
        logical(0),
        ,
        drop = FALSE
      ]
    }
  }

  if (!is.null(city_mun)) {

    keep <- .parse_area_filter(
      city_mun,
      df_base$city_mun_code,
      width = 2L
    )

    df_base <- df_base[
      keep,
      ,
      drop = FALSE
    ]
  }

  df_base <- df_base[order(df_base$psgc_code), ]

  if (trim_area_code) {

    df <- data.frame(
      region_code = df_base$region_code,
      province_code = df_base$province_code,
      city_mun_code = df_base$city_mun_code,
      area_code = df_base$barangay_code,
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

get_barmm_sga_muns <- function(release = latest_release(), ..., trim_area_code = TRUE) {

  match.arg(release, list_releases()[2:length(list_releases())])
  get_muns(release = release, ..., province = "999", trim_area_code = trim_area_code)

}

get_barmm_sga_barangays <- function(release = latest_release(), ..., mun = NULL, trim_area_code = TRUE) {

  match.arg(release, list_releases()[2:length(list_releases())])
  get_barangays(release = release, ..., province = "999", city_mun = mun, trim_area_code = trim_area_code)

}