# Internal: validate and pad a code vector to `width` digits with trailing
# zeros (10 for current releases, 9 for Q2_2021).
.pad_psgc_code <- function(code, width = 10L) {
  nch <- nchar(code)
  too_short <- nch < 2L
  too_long  <- nch > width
  if (any(too_short)) {
    cli::cli_abort(
      c(
        "PSGC code{?s} must have at least 2 digits: {.val {code[too_short]}}.",
        i = "Provide at least the 2-digit region prefix (e.g. {.val {'01'}})."
      )
    )
  }
  if (any(too_long)) {
    cli::cli_abort(
      "PSGC codes must not exceed {width} digits: {.val {code[too_long]}}."
    )
  }
  ifelse(nch < width, paste0(code, strrep("0", width - nch)), code)
}

#' Get metadata for one or more PSGC codes
#'
#' @param code A character vector of PSGC codes (10 digits; 9 for
#'   `"Q2_2021"`). Shorter codes are padded with trailing zeros.
#' @param release A release name from [list_releases()]. Defaults to
#'   [latest_release()].
#' @return A data frame with one row per code containing metadata columns
#'   (`area_name`, `geographic_level`, `correspondence_code`, etc.) plus
#'   a `release` column indicating which release was used.
#' @export
#' @examples
#' psgc_info("0100000000")
#' psgc_info(c("0100000000", "0102800000"))
#' psgc_info("0100000000", release = "Q1_2023")
psgc_info <- function(code, release = latest_release()) {
  code <- as.character(code)

  if (!release %in% .PSGC_RELEASES) {
    cli::cli_abort(
      "Unknown release {.val {release}}. Use {.fn list_releases} to see available releases."
    )
  }

  df <- psgc_releases[[release]]
  code <- .pad_psgc_code(code, width = nchar(df$psgc_code[1]))
  idx <- match(code, df$psgc_code)
  if (anyNA(idx)) {
    missing <- code[is.na(idx)]
    cli::cli_abort(
      "{cli::qty(missing)}Code{?s} not found in release {.val {release}}: {.val {missing}}."
    )
  }

  out <- df[idx, , drop = FALSE]
  out$release <- release
  rownames(out) <- NULL
  out
}
