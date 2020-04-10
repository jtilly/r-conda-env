#' Get Python model module
#'
#' @return Reticulate object with Python model module
get_python_model <- function() {
  reticulate::use_condaenv(get_package_envname(), required = TRUE) # nolint
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
  cl <- parallel::makeCluster(1)
  parallel::clusterExport(cl, c("df"))
  results <- parallel::parLapply(cl, 1, function(i) {
    model <- get_python_model()
    model$predict(df)$values
  })
  parallel::stopCluster(cl)
  return(unlist(results))
}

#' Return version of Pandas
#'
#' @return str with Pandas version
#' @export
check_pandas_version <- function() {
  cl <- parallel::makeCluster(1)
  parallel::clusterExport(cl, c("df"))
  results <- parallel::parLapply(cl, 1, function(i) {
    model <- get_python_model()
    version <- model$check_pandas_version()
    return(version)
  })
  parallel::stopCluster(cl)
  return(unlist(results))
}
