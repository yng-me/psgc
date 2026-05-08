.RELEASES <- c(
  "Q1_2023", "Q4_2023", "April_2024", "Q2_2024",
  "Q3_2024", "Q4_2024", "Q1_2025", "Q2_2025",
  "July_2025", "Q3_2025", "Q4_2025", "Q1_2026"
)

#' List available PSGC releases
#'
#' @return A character vector of release names in chronological order.
#' @export
#' @examples
#' list_releases()
list_releases <- function() {
  .RELEASES
}

#' The most recent bundled PSGC release
#'
#' @return A single character string naming the latest available release.
#' @export
#' @examples
#' latest_release()
latest_release <- function() {
  .RELEASES[length(.RELEASES)]
}
