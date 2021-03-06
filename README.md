
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r-conda-env

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/jtilly/r-conda-env.svg?branch=master)](https://travis-ci.org/jtilly/r-conda-env)
<!-- badges: end -->

R-Package = conda environment wrapped model

This package allows you to ship and deploy machine learning models built
in Python using an R package.

Say you have a Python model that works in one specific conda environment
and you want to make it accessible to R users via reticulate. How do you
go about doing that?

This proof of concept R-package comes with a fully specified conda
environment that will be created when the R package is installed. All
Python code inside this package will then be run in this conda
environment. We can ship several models in the same R package as long as
they share their conda environment. If two models do not share their
conda environment, we ship them in separate R packages.

## Install

You need to have conda installed on your system and reticulate must be
able to [find
it](https://rstudio.github.io/reticulate/reference/conda-tools.html#finding-conda).

``` r
# install.packages("remotes")
remotes::install_github("jtilly/r-conda-env")
```

## Usage

``` r
library(rcondaenv)
create_package_env()
#> Creating conda environment now.
#> Environment 2f0409c2f60c564607d28c44c8edc52c already exists. Removing it first...
#> Created conda environment 2f0409c2f60c564607d28c44c8edc52c
df <- tibble::tribble(
  ~x, ~y, ~z,
  "a", 2, 3.6,
  "b", 1, 8.5
)
python_model_predict(df)
#> [1] 0 1
check_pandas_version()
#> [1] "The installed Pandas version is 1.0.3"
```

## Details

  - The conda requirements are defined in `inst/conda-requirements.txt`
    and installed with the R Package.
    
        python=3.8.2=he5300dc_5_cpython
        pandas=1.0.3=py38hcb8c335_0
        numpy=1.18.1=py38h8854b6b_1
    
    Package versions are currently pinned. There’s an unpinned version
    for non-Linux systems.

  - Arbitrary Python code can be shipped with the package. Currently,
    there’s only one file `inst/model.py`:
    
    ``` python
    import pandas as pd
    
    def predict(df):
      """Trivial predict function that returns a sequence 0, 1, ..., n-1."""
      return df.reset_index(drop=True).index.astype(float)
    
    def check_pandas_version():
      return(f"The installed Pandas version is {pd.__version__}")
    ```

  - The reticulate calls are in `R/predict.R`.

  - We overcome the problem that you cannot use reticulate to interface
    with different Python executables within the same R session (see
    [this
    comment](https://github.com/rstudio/reticulate/issues/27#issuecomment-512256949))
    by running the reticulate call on a different worker (via the
    `parallel` package - both `PSOCK` and `FORK` work here). This comes
    with overhead, both for setting up the
    [cluster](https://developer.r-project.org/Blog/public/2020/03/17/socket-connections-update/index.html)
    and for serializing the data and communicating with the worker,
    which may or may not be tolerable depending on your use case.

## Performance

A benchmark is provided for a data set with 10 numerical columns, 10
string columns, and 10 date columns. `encapsulate` uses the little hack
that allows us to use reticulate with different Python executables in
the same R session. `do_not_encapsulate` goes straight from the user’s R
session to reticulate.

``` r
set_cluster_type("FORK")
results <- bench(n = 1e6)
#> Running with:
#>         n
#> 1       1
#> 2      10
#> 3     100
#> 4    1000
#> 5   10000
#> 6  100000
#> 7 1000000
knitr::kable(results[c("expression", "n", "median")])
```

| expression               |     n |   median |
| :----------------------- | ----: | -------: |
| encapsulate(df)          | 1e+00 | 542.29ms |
| do\_not\_encapsulate(df) | 1e+00 | 459.25ms |
| encapsulate(df)          | 1e+01 | 510.14ms |
| do\_not\_encapsulate(df) | 1e+01 | 465.09ms |
| encapsulate(df)          | 1e+02 | 500.33ms |
| do\_not\_encapsulate(df) | 1e+02 | 464.31ms |
| encapsulate(df)          | 1e+03 | 566.11ms |
| do\_not\_encapsulate(df) | 1e+03 | 470.98ms |
| encapsulate(df)          | 1e+04 | 614.53ms |
| do\_not\_encapsulate(df) | 1e+04 | 532.51ms |
| encapsulate(df)          | 1e+05 |    1.91s |
| do\_not\_encapsulate(df) | 1e+05 |    1.17s |
| encapsulate(df)          | 1e+06 |   12.01s |
| do\_not\_encapsulate(df) | 1e+06 |    7.52s |
