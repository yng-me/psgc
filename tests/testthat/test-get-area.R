# Smoke tests for the unexported area helpers (R/get-area.R).

test_that("area helpers return rows for the latest release", {
  expect_equal(nrow(get_regions()), nrow(get_psgc(geographic_level = "Reg")))
  expect_gt(nrow(get_provinces()), 0)
  expect_gt(nrow(get_hucs()), 0)
  expect_gt(nrow(get_cities()), 0)
  expect_gt(nrow(get_muns()), 0)
  expect_gt(nrow(get_barangays(region = "01")), 0)
})

test_that("region filter keeps only that region", {
  expect_true(all(get_provinces(region = "01")$region_code == "01"))
  expect_true(all(get_barangays(region = 1)$region_code == "01"))
})

test_that("area helpers work with 9-digit Q2_2021 codes", {
  expect_gt(nrow(get_provinces("Q2_2021")), 0)
  expect_gt(nrow(get_barangays("Q2_2021", region = "01")), 0)
})

test_that("include_population_data adds a population column", {
  expect_true("population" %in% names(get_regions(include_population_data = TRUE)))
})
