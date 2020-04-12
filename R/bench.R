#' Benchmark the overhead.
#'
#' @param n number of observation in the data
#' @param k_numeric number of numeric columns
#' @param k_char number of character columns
#' @param k_date number of date columns
#' @param seed seed for random number generation
#' @return a list with benchmark results
#' @importFrom "utils" "head"
#' @export
bench <- function(n = 1e6,
                  k_numeric = 10,
                  k_char = 10,
                  k_date = 10,
                  seed = 1234) {
  stopifnot(log10(n) %% 1 == 0)

  # generate data
  set.seed(seed)

  df <- tibble::as_tibble(c(
    # numerics
    lapply(
      seq_len(k_numeric),
      function(x) {
        sample(c(seq(0, 1, 0.01), NA_real_),
          size = n,
          replace = TRUE
        )
      }
    ),
    # strings
    lapply(
      seq_len(k_char),
      function(x) {
        sample(c(letters, NA_character_),
          size = n,
          replace = TRUE
        )
      }
    ),
    # dates
    lapply(
      seq_len(k_date),
      function(x) {
        sample(as.Date(
          c(
            "2000-01-01", "2010-01-01", "2020-01-01"
          )
        ), size = n, replace = TRUE)
      }
    )
  ),
  .name_repair = ~ paste0("x", seq_len(k_numeric + k_char + k_date))
  )

  # these functions will be benchmarked
  encapsulate <- function(df) {
    set_encapsulate(TRUE)
    python_model_predict(df)
  }

  do_not_encapsulate <- function(df) {
    set_encapsulate(FALSE)
    python_model_predict(df)
  }

  # create cluster only once
  create_cluster()

  # run comparison
  results <- bench::press(
    n = 10^c(0, seq_len(log10(n))),
    { # nolint
      df <- head(df, n)
      bench::mark(
        encapsulate = encapsulate(df),
        do_not_encapsulate = do_not_encapsulate(df)
      )
    }
  )

  return(results)
}
