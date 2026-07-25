test_that("list_releases() returns a character vector", {
  expect_type(list_releases(), "character")
})

test_that("list_releases() has 13 elements", {
  expect_length(list_releases(), 13)
})

test_that("list_releases() starts with Q1_2023", {
  expect_equal(list_releases()[[1]], "Q1_2023")
})

test_that("latest_release() returns Q2_2026", {
  expect_equal(latest_release(), "Q2_2026")
})

test_that("latest_release() is the last element of list_releases()", {
  releases <- list_releases()
  expect_equal(latest_release(), releases[[length(releases)]])
})
