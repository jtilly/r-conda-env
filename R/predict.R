#' Get Python model module
#'
#' @return Reticulate object with Python model module
get_python_model <- function() {
  reticulate::use_condaenv(get_package_envname(),
    required = TRUE,
    conda = get_conda_path()
  )
  package_path <- system.file(".", package = get_package_name())
  model <- reticulate::import_from_path("model",
    path = package_path,
    convert = TRUE
  )
  return(model)
}

#' Predict method for Python Model
#'
#' This function passes an input data frame on to a Python function
#' and retrns a vector of predictions.
#'
#' @param df data frame to be passed on to Python predict function
#' @return vector with predictions
#' @export
python_model_predict <- function(df) {
  encapsulate(func = function(df) {
    as.numeric(get_python_model()$predict(df)$values)
  }, df = df)
}

#' Return version of Pandas
#'
#' @return str with Pandas version
#' @export
check_pandas_version <- function() {
  encapsulate(func = function() {
    get_python_model()$check_pandas_version()
  })
}
