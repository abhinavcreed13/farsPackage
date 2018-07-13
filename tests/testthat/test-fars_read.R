context("fars_read")

test_that("fars_read works", {
  fars_2013 <- system.file("extdata", "accident_2013.csv.bz2", package = "farsPackage")
  expect_true(is.data.frame(fars_read(fars_2013)))
  expect_true(nrow(fars_read(fars_2013)) > 0)
  expect_true(ncol(fars_read(fars_2013)) > 0)
})
