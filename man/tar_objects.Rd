% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tar_objects.R
\name{tar_objects}
\alias{tar_objects}
\title{List saved targets}
\usage{
tar_objects(names = NULL)
}
\arguments{
\item{names}{Optional \code{tidyselect} selector to return
a tactical subset of target names.
If \code{NULL}, all names are selected.}
}
\value{
Character vector of targets saved to \verb{_targets/objects/}.
}
\description{
List targets currently saved to \verb{_targets/objects/}.
Does not include dynamic files or cloud storage.
}
\examples{
if (identical(Sys.getenv("TAR_LONG_EXAMPLES"), "true")) {
tar_dir({ # tar_dir() runs code from a temporary directory.
tar_script({
  tar_option_set(workspace = "x")
  list(tar_target(x, "value"))
}, ask = FALSE)
tar_make()
tar_objects()
tar_objects(starts_with("x"))
})
}
}
