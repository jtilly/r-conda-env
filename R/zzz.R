# create package env to store package name
pkg.env <- new.env() # nolint

.onLoad <- function(libname, pkgname) { # nolint
  assign("package_name", pkgname, envir = pkg.env)
  assign("conda", "auto", envir = pkg.env)
  assign("cluster_type", "PSOCK", envir = pkg.env)
  assign("encapsulate", TRUE, envir = pkg.env)
}

.onAttach <- function(libname, pkgname) { # nolint
  show_startup_message <- tryCatch(
    !package_env_exists(),
    error = function(cond) {
      TRUE
    }
  )
  if (show_startup_message) {
    packageStartupMessage(
      "To work with this R-package you need to create the conda ",
      "environment that comes along with it. ",
      "To do so run create_package_env()"
    )
  }
}
