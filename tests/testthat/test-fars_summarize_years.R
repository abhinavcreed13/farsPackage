context("fars_summarize_years")

test_that("fars_summarize_years generates warning", {
  fars_2013 <- system.file("extdata", "accident_2013.csv.bz2", package = "FARSread")
  file.copy(from = fars_2013, to = getwd())
  expect_that(fars_summarize_years(c(2013, "ABCD")), gives_warning())
  file.remove("./accident_2013.csv.bz2")
})
