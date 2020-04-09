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
create_package_env()
#> Creating conda environment now.
#> Created conda environment e7499e940c6b09fd29540f6983c0a615
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

- The conda requirements are defined in `inst/conda-requirements.txt` and installed with the R Package.
  ```
  python=3.8.2=he5300dc_5_cpython
  pandas=1.0.3=py38hcb8c335_0
  git_root=0.1=py_0
  numpy=1.18.1=py38h8854b6b_1
  ```
  Package versions are currently pinned. There's an unpinned version for non-Linux systems.
- Arbitrary Python code can be shipped with the package. Currently, there's only one file `inst/model.py`:
  ```python
  import pandas as pd

  def predict(df):
    """Trivial predict function that returns a sequence 0, 1, ..., n-1."""
    return df.reset_index(drop=True).index.astype(float)
    
  def check_pandas_version():
    return(f"The installed Pandas version is {pd.__version__}")
  ```
- The reticulate calls are in `R/predict.R`.
- We overcome the problem that you cannot use Reticulate to interface with different Python executables within the same R session (see [this comment](https://github.com/rstudio/reticulate/issues/27#issuecomment-512256949)) by giving each call to Python its own socket (via the parallel package). This comes with [overhead](https://developer.r-project.org/Blog/public/2020/03/17/socket-connections-update/index.html), which may or may not be tolerable depending on your use case.
