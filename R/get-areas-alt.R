# get_regions <- function(release = latest_release(), ..., trim_area_code = TRUE, shorten_name = FALSE, proper_name = TRUE) {

#   df_base <- get_psgc(release = release, geographic_level = 'region', ...)

#   if(trim_area_code) {
#     df_base$psgc_code <- substr(df_base$psgc_code, 1, 2)
#   }

#   df_base <- df_base[order(df_base$psgc_code), ]

#   if(shorten_name) {

#     if(proper_name) {
    
#       df_base$area_name <- ifelse(
#         grepl("NCR|NIR|ARMM|CAR", df_base$area_name),
#         trimws(gsub("\\s*\\([^)]*\\)", "", df_base$area_name)),
#         trimws(sub(".*\\(([^)]*)\\).*", "\\1", df_base$area_name))
#       )

#     } else {

#       df_base$area_name <- ifelse(
#         grepl("NCR|NIR|ARMM|CAR", df_base$area_name),
#         trimws(sub(".*\\(([^)]*)\\).*", "\\1", df_base$area_name)),
#         trimws(gsub("\\s*\\([^)]*\\)", "", df_base$area_name))
#       )

#       df_base$area_name <- ifelse(
#         grepl("MIMAROPA", df_base$area_name, ignore.case = TRUE), 
#         "MIMAROPA", 
#         df_base$area_name
#       )
#     }
#   }

#   df <- data.frame(
#     area_code = df_base$psgc_code,
#     area_name = df_base$area_name
#   )

#   if("population_data" %in% names(df_base)) {
#     df$population <- vapply(
#       df_base$population_data, 
#       function(x) { x$population[which.max(x$year)] }, 
#       integer(1)
#     )
#   }

#   df
  
# }

# get_provinces <- function(release = latest_release(), ..., region = NULL, trim_area_code = TRUE) {

#   .get_prov_or_huc(
#     release = release, 
#     geographic_level = 'province', 
#     region = region, 
#     trim_area_code = trim_area_code, 
#     ...
#   )

# }

# get_hucs <- function(release = latest_release(), ..., region = NULL, trim_area_code = TRUE) {

#   .get_prov_or_huc(
#     release = release, 
#     geographic_level = 'city', 
#     region = region, 
#     trim_area_code = trim_area_code, 
#     ...
#   )

# }

# get_cities <- function(release = latest_release(), ..., region = NULL, province = NULL, trim_area_code = TRUE, include_hucs = FALSE) {
  
#   df_base <- get_psgc(release = release, geographic_level = "city", ...)
#   if(!include_hucs) { df_base <- df_base[df_base$city_class != "HUC", ] }
#   .get_city_mun(df_base, region, province, trim_area_code)
  
# }

# get_muns <- function(release = latest_release(), ..., region = NULL, province = NULL, trim_area_code = TRUE, include_cities = TRUE) {

#   level <- "mun"
#   if(include_cities) { level <- c(level, "city") }

#   df_base <- get_psgc(release = release, geographic_level = level, ...)
#   .get_city_mun(df_base, region, province, trim_area_code)

# }

# get_barangays <- function(release = latest_release(), ..., region = NULL, province = NULL, city_mun = NULL, trim_area_code = TRUE) {

#   df_base <- get_psgc(release = release, geographic_level = 'barangay', ...)  
#   df_base$region_code <- substr(df_base$psgc_code, 1, 2)

#   df_base$province_code <- ifelse(
#     nchar(df_base$psgc_code) == 10, 
#     substr(df_base$psgc_code, 3, 5),
#     substr(df_base$psgc_code, 3, 4)
#   )

#   df_base$city_mun_code <- ifelse(
#     nchar(df_base$psgc_code) == 10, 
#     substr(df_base$psgc_code, 6, 7),
#     substr(df_base$psgc_code, 5, 6)
#   )

#   df_base$barangay_code <- ifelse(
#     nchar(df_base$psgc_code) == 10, 
#     substr(df_base$psgc_code, 8, 10),
#     substr(df_base$psgc_code, 7, 9)
#   )

#   if(!is.null(region)) {
#     reg <- .parse_area_filter(region)
#     df_base <- df_base[grepl(reg, df_base$region_code, ignore.case = TRUE), ]
#   }

#   if(!is.null(province)) {
#     m <- max(nchar(df_base$psgc_code)) - 7
#     prov <- .parse_area_filter(province, m)
#     df_base <- df_base[grepl(prov, df_base$province_code, ignore.case = TRUE), ]
#   }

#   if(!is.null(city_mun)) {
#     mun <- .parse_area_filter(city_mun)
#     df_base <- df_base[grepl(mun, df_base$city_mun_code, ignore.case = TRUE), ]
#   }

#   df_base <- df_base[order(df_base$psgc_code), ]

#   if(trim_area_code) {
#     df <- data.frame(
#       region_code = df_base$region_code,
#       province_code = df_base$province_code,
#       city_mun_code = df_base$city_mun_code,
#       area_code = df_base$barangay_code,
#       area_name = df_base$area_name
#     )
#   } else {
#     df <- data.frame(
#       area_code = df_base$psgc_code,
#       area_name = df_base$area_name
#     )
#   }

#   if("population_data" %in% names(df_base)) {
#     df$population <- vapply(
#       df_base$population_data,
#       function(x) { x$population[which.max(x$year)] }, 
#       integer(1)
#     )
#   }
  
#   df

# }

# .get_prov_or_huc <- function(release, geographic_level, region = NULL, trim_area_code = TRUE, ...) {

#   df_base <- get_psgc(release = release, geographic_level = geographic_level, ...)
#   if(geographic_level == "city") {
#     df_base <- df_base[df_base$city_class == "HUC", ]
#   }

#   df_base$region_code <- substr(df_base$psgc_code, 1, 2)
  
#   df_base$province_code <- ifelse(
#     nchar(df_base$psgc_code) == 10, 
#     substr(df_base$psgc_code, 3, 5),
#     substr(df_base$psgc_code, 3, 4)
#   )

#   if(!is.null(region)) {
#     reg <- .parse_area_filter(region)
#     df_base <- df_base[grepl(reg, df_base$region_code, ignore.case = TRUE), ]
#   }

#   df_base <- df_base[order(df_base$psgc_code), ]

#   if(trim_area_code) {
#     df <- data.frame(
#       region_code = df_base$region_code,
#       area_code = df_base$province_code,
#       area_name = df_base$area_name
#     )
#   } else {
#     df <- data.frame(
#       area_code = df_base$psgc_code,
#       area_name = df_base$area_name
#     )
#   }

#   if("population_data" %in% names(df_base)) {
#     df$population <- vapply(
#       df_base$population_data, 
#       function(x) { x$population[which.max(x$year)] }, 
#       integer(1)
#     )
#   }
  
#   df

# }

# .get_city_mun <- function(df_base, region, province, trim_area_code) {

#   df_base$region_code <- substr(df_base$psgc_code, 1, 2)

#   df_base$province_code <- ifelse(
#     nchar(df_base$psgc_code) == 10, 
#     substr(df_base$psgc_code, 3, 5),
#     substr(df_base$psgc_code, 3, 4)
#   )

#   df_base$city_mun_code <- ifelse(
#     nchar(df_base$psgc_code) == 10, 
#     substr(df_base$psgc_code, 6, 7),
#     substr(df_base$psgc_code, 5, 6)
#   )

#   if(!is.null(region)) {
#     reg <- .parse_area_filter(region)
#     df_base <- df_base[grepl(reg, df_base$region_code, ignore.case = TRUE), ]
#   }

#   if(!is.null(province)) {
#     m <- max(nchar(df_base$psgc_code)) - 7
#     prov <- .parse_area_filter(province, m)
#     df_base <- df_base[grepl(prov, df_base$province_code, ignore.case = TRUE), ]
#   }

#   df_base <- df_base[order(df_base$psgc_code), ]

#   if(trim_area_code) {
#     df <- data.frame(
#       region_code = df_base$region_code,
#       province_code = df_base$province_code,
#       area_code = df_base$city_mun_code,
#       area_name = df_base$area_name
#     )
#   } else {
#     df <- data.frame(
#       area_code = df_base$psgc_code,
#       area_name = df_base$area_name
#     )
#   }

#   if("population_data" %in% names(df_base)) {
#     df$population <- vapply(
#       df_base$population_data, 
#       function(x) { x$population[which.max(x$year)] }, 
#       integer(1)
#     )
#   }
  
#   df
# }

# .parse_area_filter <- function(x, m = 2) {
#   x <- ifelse(
#     grepl("^[0-9]+$", x),
#     ifelse(
#       nchar(x) >= m,
#       substr(x, 1, m),
#       sprintf(paste0("%0", m, "d"), as.integer(x))
#     ),
#     x
#   )
#   paste0("^(", paste0(x, collapse = "|"), ")$")
# }





# .parse_psgc <- function(psgc_code) {

#   psgc_code <- as.character(psgc_code)

#   if(anyNA(psgc_code)) {
#     stop("psgc_code contains NA values.", call. = FALSE)
#   }

#   bad <- !nchar(psgc_code) %in% c(9L, 10L, 1L, 2L, 3L) | !grepl("^[0-9]+$", psgc_code)

#   if (any(bad)) {
#     stop(
#       "Invalid PSGC code(s): ",
#       paste(unique(psgc_code[bad]), collapse = ", "),
#       call. = FALSE
#     )
#   }

#   is10 <- nchar(psgc_code) == 10L

#   data.frame(
#     region_code = substr(psgc_code, 1L, 2L),

#     province_code = ifelse(
#       is10,
#       substr(psgc_code, 3L, 5L),
#       substr(psgc_code, 3L, 4L)
#     ),

#     city_mun_code = ifelse(
#       is10,
#       substr(psgc_code, 6L, 7L),
#       substr(psgc_code, 5L, 6L)
#     ),

#     barangay_code = ifelse(
#       is10,
#       substr(psgc_code, 8L, 10L),
#       substr(psgc_code, 7L, 9L)
#     ),

#     stringsAsFactors = FALSE
#   )
# }