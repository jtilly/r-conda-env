test_that("readme code works", {
  create_package_env()
  df <- tibble::tribble(~x, ~y, ~z, "a", 2, 3.6, "b", 1, 8.5)
  expect_equal(python_model_predict(df), c(0, 1))
  expect_equal(check_pandas_version(), "The installed Pandas version is 1.0.3")
})

test_that("test that we can switch python versions", {
  # use reticulate and run some python code in the base environment
  reticulate::use_condaenv("base", conda = get_conda_path())
  sys <- reticulate::import("sys")
  version_orig <- sys$version

  # make sure that we can still access this package's conda environment
  expect_equal(check_pandas_version(), "The installed Pandas version is 1.0.3")

  # use reticulate and run some python code in the base environment
  reticulate::use_condaenv("base", conda = get_conda_path())
  sys <- reticulate::import("sys")
  version <- sys$version

  # make sure nothing changed
  expect_equal(version_orig, version)
})
