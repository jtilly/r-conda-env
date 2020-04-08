.onLoad <- function(libname, pkgname) {

  if (!package_env_exists()) {
    message("To work with this R-package you need to create the conda environment that comes along with it.")
    message("To do so run create_package_env()")
  }

}
