#' @export
store_new.fst_tbl <- function(class, file = NULL, resources = NULL) {
  fst_tbl_new(file, resources)
}

fst_tbl_new <- function(file = NULL, resources = NULL) {
  force(file)
  force(resources)
  enclass(environment(), c("tar_fst_tbl", "tar_fst", "tar_store"))
}

#' @export
store_assert_format_setting.fst_tbl <- function(class) {
}

#' @export
store_read_path.tar_fst_tbl <- function(store, path) {
  tibble::as_tibble(fst::read_fst(path))
}

#' @export
store_coerce_object.tar_fst_tbl <- function(store, object) {
  tibble::as_tibble(object)
}

#' @export
store_get_packages.tar_fst_tbl <- function(store) {
  c("tibble", NextMethod())
}
