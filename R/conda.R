#' Return package name
#'
#' There's probably a more elegant way of doing this.
#'
#' @return str with package name
get_package_name = function() {
  return("rcondaenv")
}

#' Get conda requirements that are shipped with this package
#' @return vector with requirements
get_conda_requirements = function() {
  if (Sys.info()["sysname"] == "Linux") {
    file_to_conda_requirements = system.file("conda-requirements.txt", package =
                                               "rcondaenv")
  } else {
    file_to_conda_requirements = system.file("conda-requirements-unpinned.txt", package =
                                               "rcondaenv")
  }
  conda_requirements = readLines(file_to_conda_requirements)
  conda_requirements = conda_requirements[!startsWith(conda_requirements, "#")]
  return (conda_requirements)
}

#' Get name of conda environment that belongs to this package
#' @return vector with name of conda environment
get_package_envname = function() {
  envname = digest::digest(get_conda_requirements(), algo = "md5")
}

#' Check if the package environment exists
#' @return boolean indicating whether environment exists
package_env_exists = function() {
  list_of_envs = reticulate::conda_list()
  return (get_package_envname() %in% list_of_envs$name)
}

#' Create conda environment that belongs to this package.
#' @return Exit code from reticulate::conda_create() call.
#' @export
create_package_env = function() {
  message("Creating conda environment now.")
  envname = get_package_envname()
  if (package_env_exists()) {
    message(paste(
      "Environment",
      envname,
      "already exists. Removing it first..."
    ))
    reticulate::conda_remove(envname = envname)
  }
  message(
    paste(
      "Created conda environment with Python executable",
      reticulate::conda_create(envname = envname, packages = get_conda_requirements())
    )
  )
  return(NULL)
}