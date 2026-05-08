# Internal: find the earliest release that contains a given psgc_code.
# Returns NA_character_ if not found in any release.
.resolve_release <- function(code) {
  for (rel in .RELEASES) {
    if (code %in% psgc_releases[[rel]]$psgc_code) return(rel)
  }
  NA_character_
}

# Internal: validate and pad a code vector to 10 digits with trailing zeros.
.pad_psgc_code <- function(code) {
  nch <- nchar(code)
  too_short <- nch < 2L
  too_long  <- nch > 10L
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
      "PSGC code{?s} must not exceed 10 digits: {.val {code[too_long]}}."
    )
  }
  ifelse(nch < 10L, paste0(code, strrep("0", 10L - nch)), code)
}

#' Get metadata for one or more PSGC codes
#'
#' @param code A character vector of 10-digit PSGC codes.
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

  if (!release %in% .RELEASES) {
    cli::cli_abort(
      "Unknown release {.val {release}}. Use {.fn list_releases} to see available releases."
    )
  }

  code <- .pad_psgc_code(code)

  df <- psgc_releases[[release]]
  rows <- lapply(code, function(cd) {
    row <- df[df$psgc_code == cd, , drop = FALSE]
    if (nrow(row) == 0L) {
      cli::cli_abort(
        "Code {.val {cd}} not found in release {.val {release}}."
      )
    }
    row$release <- release
    row
  })

  do.call(rbind, rows)
}
