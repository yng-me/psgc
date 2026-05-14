# Internal: update combined mapping_type when chaining through multiple steps
.update_mapping_type <- function(prev, step) {
  ifelse(prev == "abolished" | step == "abolished", "abolished",
    ifelse(prev == "split"    | step == "split",    "split",
      ifelse(prev == "merged"   | step == "merged",   "merged",
        ifelse(prev == "renumbered" | step == "renumbered", "renumbered",
          "direct"
        )
      )
    )
  )
}

# Internal: vectorised resolution of the earliest release for a batch of codes.
# Returns a character vector of the same length as codes, with NA for any code
# not found in any release.
.resolve_release_batch <- function(codes) {
  result <- rep(NA_character_, length(codes))
  for (rel in .RELEASES) {
    unfound <- which(is.na(result))
    if (!length(unfound)) break
    hit          <- codes[unfound] %in% psgc_releases[[rel]]$psgc_code
    result[unfound[hit]] <- rel
  }
  result
}

#' Map PSGC codes to a target release
#'
#' @param code A character vector of 10-digit PSGC codes.
#' @param from Release the codes come from, or `"auto"` (default) to detect
#'   automatically using the earliest release that contains each code.
#' @param to Target release name. Defaults to [latest_release()].
#' @param changes_only Logical. If `TRUE`, only rows where the code actually
#'   changed (i.e. `mapping_type` is not `"direct"`) are returned. Codes that
#'   remained unchanged across all hops are dropped. Defaults to `FALSE`.
#' @return A data frame with columns `old_code`, `new_code` (`NA` for
#'   abolished codes), `mapping_type` (`"direct"`, `"renumbered"`, `"split"`,
#'   `"merged"`, or `"abolished"`), `from_release`, and `to_release`. Split
#'   codes produce multiple rows.
#' @export
#' @examples
#' map_psgc("0100000000")
#' map_psgc(c("0100000000", "0102800000"), to = "Q4_2023")
#' map_psgc(get_psgc(geographic_level = "Bgy")$psgc_code,
#'          from = "Q1_2023", to = "Q4_2023", changes_only = TRUE)
map_psgc <- function(code, from = "auto", to = latest_release(), changes_only = FALSE) {
  code <- as.character(code)
  n    <- length(code)

  # Resolve 'from'
  if (identical(from, "auto")) {
    from <- .resolve_release_batch(code)
  } else {
    from <- rep_len(as.character(from), n)
  }

  # Validate codes found
  not_found <- is.na(from)
  if (any(not_found)) {
    cli::cli_abort(
      "Code{?s} not found in any bundled release: {.val {code[not_found]}}"
    )
  }

  # Validate 'to'
  to_idx <- match(to, .RELEASES)
  if (is.na(to_idx)) {
    cli::cli_abort("Unknown target release {.val {to}}. Use {.fn list_releases}.")
  }

  from_idx <- match(from, .RELEASES)

  # Check for backward mapping
  backward <- from_idx > to_idx
  if (any(backward)) {
    cli::cli_abort(
      c(
        "Backward mapping is not supported.",
        i = "{.val {from[backward]}} is later than target release {.val {to}}."
      )
    )
  }

  # Pre-split crosswalk by hop key — done once per call in O(|crosswalk|).
  # Keys are "from_release\rto_release" to avoid collisions with release names.
  cw_key    <- paste(psgc_crosswalk$from_release, psgc_crosswalk$to_release, sep = "\r")
  hop_pairs <- split(
    psgc_crosswalk[, c("old_code", "new_code", "mapping_type")],
    cw_key,
    drop = TRUE
  )

  # Vectorised traversal: process all codes simultaneously at each hop.
  # cur_code tracks the current code for each input (NA once abolished).
  cur_code     <- code
  mapping_type <- rep("direct", n)

  for (i in seq_len(to_idx - 1L)) {
    key <- paste(.RELEASES[i], .RELEASES[i + 1L], sep = "\r")

    # Only codes whose starting release is at or before this hop's source
    # release, and that have not already been abolished.
    needs_hop <- from_idx <= i & !is.na(cur_code)
    if (!any(needs_hop)) next

    pair <- hop_pairs[[key]]
    if (is.null(pair)) next  # no crosswalk entry for this hop

    idx <- match(cur_code[needs_hop], pair$old_code)

    # Codes not found in the crosswalk are treated as abolished (same as the
    # original implementation).  Codes found with mapping_type "abolished"
    # already have new_code = NA in the data, so both cases yield NA here.
    cur_code[needs_hop]     <- pair$new_code[idx]
    mapping_type[needs_hop] <- .update_mapping_type(
      mapping_type[needs_hop],
      ifelse(is.na(idx), "abolished", pair$mapping_type[idx])
    )
  }

  result <- data.frame(
    old_code     = code,
    new_code     = cur_code,
    mapping_type = mapping_type,
    from_release = from,
    to_release   = to,
    stringsAsFactors = FALSE
  )

  if (changes_only) {
    result <- result[result$mapping_type != "direct", , drop = FALSE]
    rownames(result) <- NULL
  }

  result
}
