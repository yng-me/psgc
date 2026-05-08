test_that("get_psgc() returns a data.frame", {
  expect_s3_class(get_psgc(), "data.frame")
})

test_that("get_psgc() result has a psgc_code column", {
  expect_true("psgc_code" %in% names(get_psgc()))
})

test_that("get_psgc('Q1_2023') returns non-empty data", {
  expect_gt(nrow(get_psgc("Q1_2023")), 0)
})

test_that("get_psgc() errors on unknown release", {
  expect_error(get_psgc("nonexistent"), class = "rlang_error")
})

# Cycle 1: single geographic_level filter
test_that("get_psgc(geographic_level='Reg') returns only regions", {
  result <- get_psgc(geographic_level = "Reg")
  expect_true(nrow(result) > 0)
  expect_true(all(result$geographic_level == "Reg"))
})

# Cycle 3: unknown geographic_level errors
test_that("get_psgc(geographic_level='Unknown') errors with informative message", {
  expect_error(get_psgc(geographic_level = "Unknown"), class = "rlang_error")
})

# Cycle 2: multiple geographic_level values
test_that("get_psgc(geographic_level=c('Reg','Prov')) returns only those levels", {
  result <- get_psgc(geographic_level = c("Reg", "Prov"))
  expect_true(nrow(result) > 0)
  expect_true(all(result$geographic_level %in% c("Reg", "Prov")))
  expect_true("Reg" %in% result$geographic_level)
  expect_true("Prov" %in% result$geographic_level)
})

# ── geographic_level aliases ──────────────────────────────────────────────────

test_that("alias 'Region' produces same result as 'Reg'", {
  expect_identical(get_psgc(geographic_level = "Region"),
                   get_psgc(geographic_level = "Reg"))
})

test_that("alias 'province' (lower-case) produces same result as 'Prov'", {
  expect_identical(get_psgc(geographic_level = "province"),
                   get_psgc(geographic_level = "Prov"))
})

test_that("alias 'Municipality' produces same result as 'Mun'", {
  expect_identical(get_psgc(geographic_level = "Municipality"),
                   get_psgc(geographic_level = "Mun"))
})

test_that("alias 'Barangay' produces same result as 'Bgy'", {
  expect_identical(get_psgc(geographic_level = "Barangay"),
                   get_psgc(geographic_level = "Bgy"))
})

test_that("alias 'Sub-Municipality' produces same result as 'SubMun'", {
  expect_identical(get_psgc(geographic_level = "Sub-Municipality"),
                   get_psgc(geographic_level = "SubMun"))
})

test_that("alias 'city_mun' returns City and Mun rows", {
  result <- get_psgc(geographic_level = "city_mun")
  expect_true(nrow(result) > 0)
  expect_true(all(result$geographic_level %in% c("City", "Mun")))
  expect_true("City" %in% result$geographic_level)
  expect_true("Mun" %in% result$geographic_level)
})

test_that("alias 'City-Municipality' (city_mun variant) returns City and Mun rows", {
  expect_identical(get_psgc(geographic_level = "City-Municipality"),
                   get_psgc(geographic_level = "city_mun"))
})

test_that("alias 'city-mun' returns same result as 'city_mun'", {
  expect_identical(get_psgc(geographic_level = "city-mun"),
                   get_psgc(geographic_level = "city_mun"))
})

# ── include_population_data ───────────────────────────────────────────────────

# Cycle 1: TRUE adds a population_data list column (not flat columns)
test_that("get_psgc(include_population_data=TRUE) adds a population_data list column", {
  result <- get_psgc(include_population_data = TRUE)
  expect_true("population_data" %in% names(result))
  expect_false("population" %in% names(result))
  expect_false("year" %in% names(result))
})

# Cycle 3: row count unchanged (no expansion) + geographic_level filter respected
test_that("include_population_data=TRUE does not expand rows", {
  base   <- get_psgc()
  result <- get_psgc(include_population_data = TRUE)
  expect_equal(nrow(result), nrow(base))
})

test_that("include_population_data=TRUE respects geographic_level filter", {
  result <- get_psgc(geographic_level = "Reg", include_population_data = TRUE)
  expect_true(all(result$geographic_level == "Reg"))
  expect_true("population_data" %in% names(result))
})

# Cycle 2: each element is a data frame with population (integer) and year
test_that("population_data elements are data frames with population and year columns", {
  result <- get_psgc(geographic_level = "Reg", include_population_data = TRUE)
  first <- result$population_data[[1]]
  expect_s3_class(first, "data.frame")
  expect_true("population" %in% names(first))
  expect_true("year" %in% names(first))
  expect_true(is.integer(first$population))
})

