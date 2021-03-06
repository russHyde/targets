#' @title Write a `_targets.R` script to the current working directory.
#' @export
#' @description The `tar_script()` function is a convenient
#'   way to create the required target script (`_targets.R` file)
#'   in the current working directory.
#'   It always overwrites the existing target script,
#'   and it requires you to be in the working directory
#'   where you intend to write the file, so be careful.
#'   See the "Target script" section for details.
#' @section Target script:
#'   Every `targets` project requires a target script in the project root.
#'   The target script must always be named `_targets.R`.
#'   Functions [tar_make()] and friends look for `_targets.R` in the
#'   current working directory and use it to set up the pipeline.
#'   Every `_targets.R` file should run the following steps in the order below:
#'     1. Package: load the `targets` package. This step is automatically
#'       inserted at the top of `_targets.R` files produced by `tar_script()`
#'       if `library_targets` is `TRUE`,
#'       so you do not need to explicitly include it in `code`.
#'     1. Globals: load custom functions and global objects into memory.
#'       Usually, this section is a bunch of calls to `source()` that run
#'       scripts defining user-defined functions. These functions support
#'       the R commands of the targets.
#'     2. Options: call [tar_option_set()] to set defaults for targets-specific
#'       settings such as the names of required packages. Even if you have no
#'       specific options to set, it is still recommended to call
#'       [tar_option_set()] in order to register the proper environment.
#'     3. Targets: define one or more target objects using [tar_target()].
#'     4. Pipeline: call [list()] to bring the targets from (3)
#'       together in a pipeline object. Every `_targets.R` script must return
#'       a pipeline object, which usually means ending with a call to
#'       [list()]. In practice, (3) and (4) can be combined together
#'       in the same function call.
#' @return `NULL` (invisibly).
#' @param code R code to write to `_targets.R`. If `NULL`, an example
#'   target script is written instead.
#' @param library_targets logical, whether to write a `library(targets)`
#'   line at the top of `_targets.R` automatically (recommended).
#'   If `TRUE`, you do not need to explicitly put `library(targets)`
#'   in `code`.
#' @param ask Logical, whether to ask before writing if `_targets.R`
#'   already exists. If `NULL`, defaults to `Sys.getenv("TAR_ASK")`.
#'   (Set to `"true"` or `"false"` with `Sys.setenv()`).
#'   If `ask` and the `TAR_ASK` environment variable are both
#'   indeterminate, defaults to `interactive()`.
#' @param tidy_eval Logical, whether to enable tidy evaluation
#'   to customize the script output. Disabled by default
#'   because [tar_target()] also has a `tidy_eval` argument.
#' @param envir Environment for tidy evaluation.
#' @examples
#' tar_dir({ # tar_dir() runs code from a temporary directory.
#' tar_script() # Writes an example target script.
#' # Writes a user-defined target script:
#' tar_script({
#'   x <- tar_target(x, 1 + 1)
#'   tar_option_set()
#'   list(x)
#' }, ask = FALSE)
#' writeLines(readLines("_targets.R"))
#' # With tidy eval:
#' name <- quote(my_target)
#' tar_script({
#'   x <- tar_target(!!name, 1 + 1)
#'   tar_option_set()
#'   list(x)
#' }, ask = FALSE, tidy_eval = TRUE)
#' writeLines(readLines("_targets.R"))
#' })
tar_script <- function(
  code = NULL,
  library_targets = TRUE,
  ask = NULL,
  tidy_eval = FALSE,
  envir = parent.frame()
) {
  if (!tar_should_overwrite(ask, path_script())) {
    # covered in tests/interactive/test-tar_script.R # nolint
    return(invisible()) # nocov
  }
  force(envir)
  assert_lgl(library_targets, "library_targets must be logical.")
  assert_scalar(library_targets, "library_targets must have length 1.")
  assert_lgl(tidy_eval, "tidy_eval must be logical.")
  assert_envir(envir, "envir must be an environment.")
  code <- tidy_eval(substitute(code), envir, tidy_eval)
  text <- trn(
    length(code),
    parse_target_script_code(code),
    example_target_script()
  )
  assert_chr(text, "code arg of tar_script() must be parseable R code.")
  if (library_targets) {
    text <- c("library(targets)", text)
  }
  writeLines(text, path_script())
}

example_target_script <- function() {
  path <- system.file("_targets.R", package = "targets", mustWork = TRUE)
  readLines(path)
}

parse_target_script_code <- function(code) {
  trn(
    length(code) > 1L && identical(deparse_safe(code[[1]]), "`{`"),
    map_chr(code[-1], deparse_safe),
    deparse_safe(code)
  )
}
