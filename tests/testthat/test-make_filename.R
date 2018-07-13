context("make_filename")

test_that("make_filename works", {
  input <- "2013"
  output <- "accident_2013.csv.bz2"
  expect_equal(make_filename(input),output)
  input <- "2014"
  output <- "accident_2014.csv.bz2"
  expect_equal(make_filename(input),output)
  input <- 2015
  output <- "accident_2015.csv.bz2"
  expect_equal(make_filename(input),output)
})
