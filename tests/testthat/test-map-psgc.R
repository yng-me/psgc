test_that("map_psgc() returns a data.frame", {
  expect_s3_class(map_psgc("0100000000"), "data.frame")
})

test_that("map_psgc() result has the required columns", {
  result <- map_psgc("0100000000")
  expect_true(all(c("old_code", "new_code", "mapping_type", "from_release", "to_release") %in% names(result)))
})

test_that("a stable code maps as 'direct' across all releases", {
  # Region I has existed in every release
  result <- map_psgc("0100000000", from = "Q1_2023", to = "Q1_2026")
  expect_equal(result$mapping_type, "direct")
  expect_equal(result$new_code, "0100000000")
})

test_that("map_psgc() is vectorised — two codes return two rows", {
  result <- map_psgc(c("0100000000", "0102800000"))
  expect_equal(nrow(result), 2)
})

test_that("map_psgc() with from = 'auto' resolves release correctly", {
  result <- map_psgc("0100000000")
  expect_false(is.na(result$from_release))
})

test_that("map_psgc() errors on backward mapping", {
  expect_error(
    map_psgc("0100000000", from = "Q1_2026", to = "Q1_2023"),
    class = "rlang_error"
  )
})

test_that("map_psgc() errors on unknown code", {
  expect_error(map_psgc("9999999999"), class = "rlang_error")
})

test_that("map_psgc() errors on unknown target release", {
  expect_error(
    map_psgc("0100000000", to = "Q9_2099"),
    class = "rlang_error"
  )
})

test_that("an abolished code maps to NA new_code with mapping_type 'abolished'", {
  # 0402103002 (Aniban I) was renumbered, so let's use a code that is
  # genuinely abolished (no successor) — any code in Q1_2023 not in Q4_2023
  # other than 0402103002. We locate one via the crosswalk directly.
  abolished_code <- psgc:::psgc_crosswalk[
    psgc:::psgc_crosswalk$from_release == "Q1_2023" &
      psgc:::psgc_crosswalk$to_release == "Q4_2023" &
      psgc:::psgc_crosswalk$mapping_type == "abolished",
    "old_code"
  ][1]
  result <- map_psgc(abolished_code, from = "Q1_2023", to = "Q4_2023")
  expect_equal(nrow(result), 1)
  expect_true(is.na(result$new_code))
  expect_equal(result$mapping_type, "abolished")
})

test_that("a renumbered code maps to its new code with mapping_type 'renumbered'", {
  # 0402103002 (Aniban I) -> 0402103076 (Aniban 1) in Q1_2023 -> Q4_2023
  result <- map_psgc("0402103002", from = "Q1_2023", to = "Q4_2023")
  expect_equal(result$new_code, "0402103076")
  expect_equal(result$mapping_type, "renumbered")
})
