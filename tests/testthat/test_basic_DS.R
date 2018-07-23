
context("basic_DS get_data")
library(NDTr)

test_that("get_data returns a data frame with unique values", {
  expect_equal(str_length("a"), 1)
  expect_equal(str_length("ab"), 2)
  expect_equal(str_length("abc"), 3)
})






