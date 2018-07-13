context("fars_read")

test_that("fars_read works", {
  input <- "data/accident_2013.csv.bz2"
  expect_true(is.data.frame(fars_read(input)))
  expect_true(nrow(fars_read(input)) > 0)
  expect_true(ncol(fars_read(input)) > 0)
})
