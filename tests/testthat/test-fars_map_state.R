context("fars_map_state")

test_that("fars_map_state works", {
  fars_2013 <- system.file("extdata", "accident_2013.csv.bz2", package = "farsPackage")
  file.copy(from = fars_2013, to = getwd())
  Texas <- fars_map_state(48, 2013)
  expect_null(Texas, "null")
  file.remove("./accident_2013.csv.bz2")
})
