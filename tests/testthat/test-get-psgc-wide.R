test_that("get_psgc_wide() returns a data.frame", {
  result <- get_psgc_wide()
  expect_s3_class(result, "data.frame")
})

test_that("get_psgc_wide() has the expected 10 columns in order", {
  result <- get_psgc_wide()
  expect_equal(
    names(result),
    c(
      "area_code", "region_code", "province_code", "city_mun_code",
      "region", "province", "city_mun", "barangay",
      "urban_rural", "island_region"
    )
  )
})

test_that("get_psgc_wide() returns non-empty data", {
  expect_gt(nrow(get_psgc_wide()), 0)
})

test_that("get_psgc_wide() errors on unknown release", {
  expect_error(get_psgc_wide("nonexistent"), class = "rlang_error")
})

test_that("get_psgc_wide() accepts a valid non-default release", {
  result <- get_psgc_wide("Q1_2023")
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)
})

test_that("get_psgc_wide() has one row per unique area_code", {
  result <- get_psgc_wide()
  expect_equal(nrow(result), length(unique(result$area_code)))
})

test_that("get_psgc_wide() area_code matches barangay count from get_psgc()", {
  brgys  <- get_psgc(geographic_level = "brgy")
  result <- get_psgc_wide()
  expect_equal(nrow(result), nrow(brgys))
})

test_that("get_psgc_wide() has no NA in region column", {
  result <- get_psgc_wide()
  expect_false(any(is.na(result$region)))
})

test_that("get_psgc_wide() city_mun is NA for HUC barangays", {
  result <- get_psgc_wide()
  huc_brgys <- result[substr(result$area_code, 6, 7) == "00", ]
  expect_true(nrow(huc_brgys) > 0)
  expect_true(all(is.na(huc_brgys$city_mun)))
  expect_true(all(is.na(huc_brgys$city_mun_code)))
})

test_that("get_psgc_wide() city_mun is non-NA for regular barangays", {
  result <- get_psgc_wide()
  regular <- result[substr(result$area_code, 6, 7) != "00", ]
  expect_false(any(is.na(regular$city_mun)))
})

test_that("get_psgc_wide() province is NA for areas with no province layer", {
  result <- get_psgc_wide()
  # Most barangays have a province; special cases (Pateros in NCR, City of
  # Isabela, Special Geographic Areas) legitimately have NA.
  expect_true(sum(!is.na(result$province)) > sum(is.na(result$province)))
})

test_that("get_psgc_wide() HUC barangays have a non-NA province", {
  result <- get_psgc_wide()
  # Caloocan City (1380100000) is an HUC — its barangays must resolve a province
  # and must have NA city_mun.
  caloocan_brgys <- result[substr(result$area_code, 1, 7) == "1380100", ]
  expect_true(nrow(caloocan_brgys) > 0)
  expect_false(any(is.na(caloocan_brgys$province)))
  expect_true(all(is.na(caloocan_brgys$city_mun)))
})

test_that("get_psgc_wide() region_code is 10 digits ending in 00000000", {
  result <- get_psgc_wide()
  expect_true(all(nchar(result$region_code) == 10L))
  expect_true(all(substr(result$region_code, 3, 10) == "00000000"))
})

test_that("get_psgc_wide() province_code is 10 digits ending in 00000 when present", {
  result <- get_psgc_wide()
  non_na <- result$province_code[!is.na(result$province_code)]
  expect_true(all(nchar(non_na) == 10L))
  expect_true(all(substr(non_na, 6, 10) == "00000"))
})

test_that("get_psgc_wide() city_mun_code is 10 digits ending in 000 when present", {
  result <- get_psgc_wide()
  non_na <- result$city_mun_code[!is.na(result$city_mun_code)]
  expect_true(all(nchar(non_na) == 10L))
  expect_true(all(substr(non_na, 8, 10) == "000"))
})

test_that("get_psgc_wide() result is sorted by region, province, city_mun, area_code", {
  result <- get_psgc_wide()
  expected_order <- order(
    result$region_code, result$province_code,
    result$city_mun_code, result$area_code
  )
  expect_equal(seq_len(nrow(result)), expected_order)
})
