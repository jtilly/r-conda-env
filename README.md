# r-conda-env

R-Package = conda environment wrapped model

This package allows you to ship and deploy machine learning models built in Python using an R package.

Say you have a Python model that works in one specific conda environment and you want to make it accessible to R users via reticulate. How do you go about doing that?

This proof of concept R-package comes with a fully specified conda environment that will be created when the R package is installed. All Python code inside this package will then be run in this conda environment. We can ship several models in the same R package as long as they share their conda environment. If two models do not share their conda environment, we ship them in separate R packages.

## Usage

- Make sure `conda` is on your `PATH` before open R/RStudio
- Install this package via `remotes::install_github("jtilly/r-conda-env")`

``` r
library(rcondaenv)
#> Loading required package: reticulate
#> Loading required package: digest
#> To work with this R-package you need to create the conda environment that comes along with it.
#> To do so run create_package_env()
create_package_env()
#> Creating conda environment now.
#> Created conda environment with Python executable /opt/local/conda/envs/e7499e940c6b09fd29540f6983c0a615/bin/python
#> NULL
df = tibble::tribble(
  ~x, ~y,  ~z,
  "a", 2,  3.6,
  "b", 1,  8.5
)
python_model_predict(df)
#> Float64Index([0.0, 1.0], dtype='float64')
check_pandas_version()
#> [1] "The installed Pandas version is 1.0.3"
```
