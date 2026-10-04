# Case-insensitive, literal (non-regex) keyword search over message text.
# `data` is the output of getDB()/parser(); returns the matching rows in
# their original order. A blank / NULL / NA keyword matches nothing.
searchMessages <- function(data, keyword) {
  if (is.null(keyword) || length(keyword) != 1 || is.na(keyword) ||
      !nzchar(trimws(keyword))) {
    return(data[0, , drop = FALSE])
  }
  keyword <- tolower(trimws(keyword))
  # fixed = TRUE cannot be combined with ignore.case, so lower-case both sides
  hit <- !is.na(data$text) & grepl(keyword, tolower(data$text), fixed = TRUE)
  data[hit, , drop = FALSE]
}
