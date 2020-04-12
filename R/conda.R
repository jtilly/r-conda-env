#' Set conda path to be used inside package
#'
#' @param conda The path to a `conda` executable. Use `"auto"` to allow
#'   `reticulate` to automatically find an appropriate `conda` binary.
#' @export
set_conda_path <- function(conda) {
  assign("conda", conda, envir = pkg.env) # nolint
}

#' Get conda path that is used inside package
#' @return conda path (or "auto" if reticulate is supposed to
#'   automatically find a conda binary)
#' @export
get_conda_path <- function() {
  get("conda", envir = pkg.env) # nolint
}

#' Set cluster type for encapsulation.
#' @param type cluster type used for makeCluster
#' @export
set_cluster_type <- function(type) {
  assign("cluster_type", type, envir = pkg.env) # nolint
}

#' Set cluster type for encapsulation.
#' @return type cluster type used for makeCluster
#' @export
get_cluster_type <- function(type) {
  get("cluster_type", envir = pkg.env) # nolint
}

#' Return package name
#'
#' @return str with package name
get_package_name <- function() {
  get("package_name", envir = pkg.env) # nolint
}

#' Get conda requirements that are shipped with this package
#' @return vector with requirements
get_conda_requirements <- function() {
  if (Sys.info()["sysname"] == "Linux") {
    file_to_conda_requirements <- system.file(
      "conda-requirements.txt",
      package = get_package_name()
    )
  } else {
    file_to_conda_requirements <- system.file(
      "conda-requirements-unpinned.txt",
      package = get_package_name()
    )
  }
  conda_requirements <- readLines(file_to_conda_requirements)
  conda_requirements <- conda_requirements[!startsWith(conda_requirements, "#")]
  return(conda_requirements)
}

#' Get name of conda environment that belongs to this package
#' @return vector with name of conda environment
get_package_envname <- function() {
  return(digest::digest(get_conda_requirements(), algo = "md5"))
}

#' Check if the package environment exists
#' @return boolean indicating whether environment exists
package_env_exists <- function() {
  list_of_envs <- reticulate::conda_list(conda = get_conda_path())
  return(get_package_envname() %in% list_of_envs$name)
}

#' Create conda environment that belongs to this package.
#' @return Exit code from reticulate::conda_create() call.
#' @export
create_package_env <- function() {
  message("Creating conda environment now.")
  envname <- get_package_envname()
  if (package_env_exists()) {
    message(paste(
      "Environment",
      envname,
      "already exists. Removing it first..."
    ))
    reticulate::conda_remove(envname = envname, conda = get_conda_path())
  }
  conda_create(
    envname = envname,
    packages = get_conda_requirements(),
    conda = get_conda_path()
  )
  message(paste("Created conda environment", envname))
  return(invisible(envname))
}

#' Create conda environment.
#'
#' This function is extending
#' https://github.com/rstudio/reticulate/blob/d30786a7ca1335003c52c458c1b4081d47ddc9bc/R/conda.R#L109 # nolint
#' which is licensed under Apache License 2.0,
#' see https://github.com/rstudio/reticulate/blob/master/LICENSE
#' with copyright 2016-2017 RStudio, Inc.
#'
#' @param envname The name of, or path to, a conda environment.
#' @param packages A character vector, indicating package names which should be
#'   installed.
#' @param conda The path to a `conda` executable. Use `"auto"` to allow
#'   `reticulate` to automatically find an appropriate `conda` binary.
#' @param forge Boolean; include the [Conda Forge](https://conda-forge.org/)
#'   repository?
#' @param channel An optional character vector of Conda channels to include.
#'   When specified, the `forge` argument is ignored. If you need to
#'   specify multiple channels, including the Conda Forge, you can use
#'   `c("conda-forge", <other channels>)`.
#' @return string with path to Python binary
#' @export
conda_create <- function(envname = NULL,
                         packages = "python",
                         conda = "auto",
                         forge = TRUE,
                         channel = character()) {

  # resolve conda binary
  conda <- reticulate::conda_binary(conda)

  # resolve environment name
  envname <- reticulate:::condaenv_resolve(envname)

  # create the environment
  args <- reticulate:::conda_args("create", envname, packages)

  # add user-requested channels
  channels <- if (length(channel)) {
    channel
  } else if (forge) {
    "conda-forge"
  }

  for (ch in channels) {
    args <- c(args, "-c", ch)
  }

  result <- system2(conda, shQuote(args))
  if (result != 0L) {
    stop("Error ", result, " occurred creating conda environment ", envname,
      call. = FALSE
    )
  }

  # return the path to the python binary
  reticulate::conda_python(envname = envname, conda = conda)
}

#' Run function via makeCluster to allow several python bindings in reticulate
#' @param func is the function that will be run
#' @param ... are the function arguments
#' @export
encapsulate <- function(func, ...) {
  if (!exists("cl", envir = pkg.env)) { # nolint
    assign("cl", parallel::makeCluster(1, type = get_cluster_type()), pkg.env) # nolint
  }
  args <- list(...)
  parallel::clusterExport(get("cl", pkg.env), c("args")) # nolint
  results <- parallel::parLapply(get("cl", pkg.env), 1, function(i) { # nolint
    results <- do.call(func, args)
    rm(args)
    return(results)
  })
  return(unlist(results))
}
