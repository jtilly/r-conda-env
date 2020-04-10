# create package env to store package name
pkg.env <- new.env() # nolint

.onLoad <- function(libname, pkgname) { # nolint
  assign("package_name", pkgname, envir = pkg.env)
}

.onAttach <- function(libname, pkgname) { # nolint
  if (!package_env_exists()) {
    packageStartupMessage(
      "To work with this R-package you need to create the conda ",
      "environment that comes along with it. ",
      "To do so run create_package_env()"
    )
  }
}
