test_that("readme code works", {
  create_package_env()
  df <- tibble::tribble(~x, ~y, ~z, "a", 2, 3.6, "b", 1, 8.5)
  expect_equal(python_model_predict(df), c(0, 1))
  expect_equal(check_pandas_version(), "The installed Pandas version is 1.0.3")
})
