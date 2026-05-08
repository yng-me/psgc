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

# Internal: chain a single code from from_idx to to_idx through psgc_crosswalk
.chain_code <- function(code, from_release, from_idx, to_release, to_idx) {
  if (from_idx == to_idx) {
    return(data.frame(
      old_code     = code,
      new_code     = code,
      mapping_type = "direct",
      from_release = from_release,
      to_release   = to_release,
      stringsAsFactors = FALSE
    ))
  }

  # current: data frame tracking the evolving set of codes for this input
  current <- data.frame(
    old_code     = code,
    cur_code     = code,
    mapping_type = "direct",
    stringsAsFactors = FALSE
  )

  for (i in seq(from_idx, to_idx - 1L)) {
    fr_rel <- .RELEASES[i]
    to_rel <- .RELEASES[i + 1L]

    pair <- psgc_crosswalk[
      psgc_crosswalk$from_release == fr_rel &
        psgc_crosswalk$to_release == to_rel,
    ]

    next_rows <- vector("list", nrow(current))
    for (j in seq_len(nrow(current))) {
      row <- current[j, ]
      if (is.na(row$cur_code)) {
        next_rows[[j]] <- row  # already abolished, propagate
        next
      }
      matches <- pair[pair$old_code == row$cur_code, , drop = FALSE]
      if (nrow(matches) == 0) {
        # Code not found in this pair's crosswalk — treat as abolished
        next_rows[[j]] <- data.frame(
          old_code     = row$old_code,
          cur_code     = NA_character_,
          mapping_type = "abolished",
          stringsAsFactors = FALSE
        )
      } else {
        next_rows[[j]] <- data.frame(
          old_code     = row$old_code,
          cur_code     = matches$new_code,
          mapping_type = .update_mapping_type(row$mapping_type, matches$mapping_type),
          stringsAsFactors = FALSE
        )
      }
    }
    current <- do.call(rbind, next_rows)
  }

  data.frame(
    old_code     = current$old_code,
    new_code     = current$cur_code,
    mapping_type = current$mapping_type,
    from_release = from_release,
    to_release   = to_release,
    stringsAsFactors = FALSE
  )
}

#' Map PSGC codes to a target release
#'
#' @param code A character vector of 10-digit PSGC codes.
#' @param from Release the codes come from, or `"auto"` (default) to detect
#'   automatically using the earliest release that contains each code.
#' @param to Target release name. Defaults to [latest_release()].
#' @return A data frame with columns `old_code`, `new_code` (`NA` for
#'   abolished codes), `mapping_type` (`"direct"`, `"renumbered"`, `"split"`,
#'   `"merged"`, or `"abolished"`), `from_release`, and `to_release`. Split
#'   codes produce multiple rows.
#' @export
#' @examples
#' map_psgc("0100000000")
#' map_psgc(c("0100000000", "0102800000"), to = "Q4_2023")
map_psgc <- function(code, from = "auto", to = latest_release()) {
  code <- as.character(code)
  n    <- length(code)

  # Resolve 'from'
  if (identical(from, "auto")) {
    from <- vapply(code, .resolve_release, character(1), USE.NAMES = FALSE)
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

  # Chain each code independently and combine
  results <- mapply(
    .chain_code,
    code, from, from_idx,
    MoreArgs = list(to_release = to, to_idx = to_idx),
    SIMPLIFY = FALSE
  )

  do.call(rbind, results)
}
