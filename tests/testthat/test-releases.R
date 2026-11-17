test_that("list_releases() returns a character vector", {
  expect_type(list_releases(), "character")
})

test_that("list_releases() has 15 elements", {
  expect_length(list_releases(), 15)
})

test_that("list_releases() starts with Q2_2021", {
  expect_equal(list_releases()[[1]], "Q2_2021")
})

test_that("latest_release() returns Q3_2026", {
  expect_equal(latest_release(), "Q3_2026")
})

test_that("latest_release() is the last element of list_releases()", {
  releases <- list_releases()
  expect_equal(latest_release(), releases[[length(releases)]])
})
