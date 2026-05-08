test_that("get_population() returns a data.frame with psgc_code, population, year", {
  result <- get_population()
  expect_s3_class(result, "data.frame")
  expect_true(all(c("psgc_code", "population", "year") %in% names(result)))
})

test_that("get_population() errors on unknown release", {
  expect_error(get_population("nonexistent"), class = "rlang_error")
})

# ── details ───────────────────────────────────────────────────────────────────

# Cycle 1: details=TRUE adds area_name and geographic_level
test_that("get_population(details=TRUE) adds area_name and geographic_level", {
  result <- get_population(details = TRUE)
  expect_true("area_name" %in% names(result))
  expect_true("geographic_level" %in% names(result))
})

# Cycle 2: details=FALSE (default) does NOT include those columns
test_that("get_population() does not include area_name by default", {
  result <- get_population()
  expect_false("area_name" %in% names(result))
  expect_false("geographic_level" %in% names(result))
})

# ── geographic_level filter ───────────────────────────────────────────────────

# Cycle 3: geographic_level filters rows by canonical level
test_that("get_population(geographic_level='Reg') returns only region rows", {
  result <- get_population(geographic_level = "Reg", details = TRUE)
  expect_true(all(result$geographic_level == "Reg"))
  expect_gt(nrow(result), 0)
})

# Cycle 4: aliases work the same as in get_psgc()
test_that("get_population(geographic_level='Region') same as 'Reg'", {
  expect_identical(
    get_population(geographic_level = "Region", details = TRUE),
    get_population(geographic_level = "Reg",    details = TRUE)
  )
})

# Cycle 5: unknown level errors
test_that("get_population(geographic_level='Unknown') errors", {
  expect_error(get_population(geographic_level = "Unknown"), class = "rlang_error")
})

# ── wide format ───────────────────────────────────────────────────────────────

# Cycle 6: wide=TRUE pivots year as columns named population_<year>
test_that("get_population(wide=TRUE) pivots years as columns", {
  result <- get_population(geographic_level = "Reg", wide = TRUE)
  years  <- sort(unique(get_population()$year))
  expected_cols <- paste0("population_", years)
  expect_true(all(expected_cols %in% names(result)))
  expect_false("year" %in% names(result))
  expect_false("population" %in% names(result))
})

# Cycle 7: wide=TRUE one row per psgc_code
test_that("get_population(wide=TRUE) has one row per psgc_code", {
  result <- get_population(geographic_level = "Reg", wide = TRUE)
  base   <- get_population(geographic_level = "Reg")
  expect_equal(nrow(result), length(unique(base$psgc_code)))
})

# Cycle 8: wide + details includes area_name and geographic_level
test_that("get_population(wide=TRUE, details=TRUE) includes area_name", {
  result <- get_population(geographic_level = "Reg", wide = TRUE, details = TRUE)
  expect_true("area_name" %in% names(result))
  expect_true("geographic_level" %in% names(result))
})

# ── column order ──────────────────────────────────────────────────────────────

test_that("get_population(details=TRUE) has correct column order (long)", {
  result <- get_population(details = TRUE)
  year_cols <- paste0("population_", sort(unique(result$year)))
  expect_equal(
    names(result)[1:4],
    c("psgc_code", "area_name", "geographic_level", "year")
  )
  expect_equal(names(result)[5], "population")
})

test_that("get_population(details=TRUE, wide=TRUE) has correct column order (wide)", {
  result  <- get_population(geographic_level = "Reg", wide = TRUE, details = TRUE)
  years   <- sort(unique(get_population()$year))
  yr_cols <- paste0("population_", years)
  expect_equal(
    names(result),
    c("psgc_code", "area_name", "geographic_level", yr_cols)
  )
})
