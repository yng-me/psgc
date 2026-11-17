.PSGC_RELEASES <- c(
  "Q2_2021", "Q1_2023", "Q4_2023", "April_2024", "Q2_2024",
  "Q3_2024", "Q4_2024", "Q1_2025", "Q2_2025",
  "July_2025", "Q3_2025", "Q4_2025", "Q1_2026", "Q2_2026",
  "Q3_2026"
)

#' List available PSGC releases
#'
#' @return A character vector of release names in chronological order.
#' @export
#' @examples
#' list_releases()
list_releases <- function() {
  .PSGC_RELEASES
}

#' The most recent bundled PSGC release
#'
#' @return A single character string naming the latest available release.
#' @export
#' @examples
#' latest_release()
latest_release <- function() {
  .PSGC_RELEASES[length(.PSGC_RELEASES)]
}
