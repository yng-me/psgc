test_that("psgc_info() returns a data.frame", {
  expect_s3_class(psgc_info("0100000000"), "data.frame")
})

test_that("psgc_info() returns correct area_name for a known code", {
  expect_equal(psgc_info("0100000000")$area_name, "Region I (Ilocos Region)")
})

test_that("psgc_info() returns correct geographic_level for a known code", {
  expect_equal(psgc_info("0100000000")$geographic_level, "Reg")
})

test_that("psgc_info() is vectorised over code", {
  result <- psgc_info(c("0100000000", "0102800000"))
  expect_equal(nrow(result), 2)
})

test_that("psgc_info() errors on unknown code", {
  expect_error(psgc_info("9999999999"), class = "rlang_error")
})

test_that("psgc_info() respects explicit release argument", {
  result <- psgc_info("0100000000", release = "Q1_2023")
  expect_equal(result$release, "Q1_2023")
})

# Cycle 1: default release is latest_release()
test_that("psgc_info() defaults to latest_release()", {
  result <- psgc_info("0100000000")
  expect_equal(result$release, latest_release())
})

# Cycle 1: unknown explicit release errors (not a cryptic crash)
test_that("psgc_info() errors on unknown explicit release", {
  expect_error(psgc_info("0100000000", release = "nonexistent"), class = "rlang_error")
})

# Cycle 2: error message is informative
test_that("psgc_info() release error mentions the bad value and list_releases", {
  err <- tryCatch(
    psgc_info("0100000000", release = "nonexistent"),
    error = function(e) e
  )
  expect_match(conditionMessage(err), "nonexistent", fixed = TRUE)
  expect_match(conditionMessage(err), "list_releases", fixed = TRUE)
})

# ── short code padding ────────────────────────────────────────────────────────

# Cycle 1: 2-digit code pads to full 10-digit code
test_that("psgc_info() pads 2-digit code with trailing zeros", {
  expect_equal(psgc_info("01")$psgc_code, "0100000000")
})

# Cycle 2: mid-length codes also pad correctly
test_that("psgc_info() pads any short code (2-9 digits) with trailing zeros", {
  expect_equal(psgc_info("01028")$psgc_code, "0102800000")  # Ilocos Norte province
  expect_equal(psgc_info("010280000")$psgc_code, "0102800000")
})

# Cycle 3: fewer than 2 digits errors
test_that("psgc_info() errors when code has fewer than 2 digits", {
  expect_error(psgc_info("0"), class = "rlang_error")
  expect_error(psgc_info(""),  class = "rlang_error")
})

# Cycle 4: more than 10 digits errors
test_that("psgc_info() errors when code has more than 10 digits", {
  expect_error(psgc_info("01234567890"), class = "rlang_error")
})
