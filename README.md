
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
  ~x, ~y,  ~z,
  "a", 2,  3.6,
  "b", 1,  8.5
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

  - We overcome the problem that you cannot use Reticulate to interface
    with different Python executables within the same R session (see
    [this
    comment](https://github.com/rstudio/reticulate/issues/27#issuecomment-512256949))
    by giving each call to Python its own socket (via the parallel
    package). This comes with
    [overhead](https://developer.r-project.org/Blog/public/2020/03/17/socket-connections-update/index.html),
    which may or may not be tolerable depending on your use case.

## Performance

``` r
results = bench()
#> Running with:
#>         n
#> 1       1
#> 2      10
#> 3     100
#> 4    1000
#> 5   10000
#> 6  100000
#> 7 1000000
knitr::kable(results[c("expression", "n", "median", "mem_alloc")])
```

| expression               |     n |   median | mem\_alloc |
| :----------------------- | ----: | -------: | ---------: |
| encapsulate(df)          | 1e+00 | 507.88ms |   181.96KB |
| do\_not\_encapsulate(df) | 1e+00 | 475.17ms |     2.25MB |
| encapsulate(df)          | 1e+01 |  525.6ms |   176.59KB |
| do\_not\_encapsulate(df) | 1e+01 | 492.75ms |   198.73KB |
| encapsulate(df)          | 1e+02 | 503.01ms |   178.25KB |
| do\_not\_encapsulate(df) | 1e+02 | 478.05ms |   208.67KB |
| encapsulate(df)          | 1e+03 | 560.41ms |   192.31KB |
| do\_not\_encapsulate(df) | 1e+03 |  507.8ms |   293.05KB |
| encapsulate(df)          | 1e+04 | 630.94ms |   332.94KB |
| do\_not\_encapsulate(df) | 1e+04 | 561.94ms |     1.11MB |
| encapsulate(df)          | 1e+05 |    2.07s |      1.7MB |
| do\_not\_encapsulate(df) | 1e+05 |    1.24s |     9.36MB |
| encapsulate(df)          | 1e+06 |   15.19s |    15.43MB |
| do\_not\_encapsulate(df) | 1e+06 |   11.16s |    91.75MB |
