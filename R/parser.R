parser <- function(data, id = NULL, dateStart = NULL, dateEnd = NULL) {
  message <- data
  if (!is.null(id)) {
    message <- message[!is.na(message$who) & message$who == id, , drop = FALSE]
  }
  if (!is.null(dateStart)) {
    message <- message[!is.na(message$date) & message$date >= as.numeric(dateStart), , drop = FALSE]
  }
  if (!is.null(dateEnd)) {
    message <- message[!is.na(message$date) & message$date <= as.numeric(dateEnd), , drop = FALSE]
  }
  message[order(-message$date), , drop = FALSE]
}

# Convert the UTC `xdate` strings from getDB() to local time (tz = "" is this
# machine's zone). Returns "YYYY-MM-DD HH:MM:SS" strings; NA stays NA.
localTime <- function(xdate, tz = "") {
  t <- as.POSIXct(as.character(xdate), tz = "UTC")
  format(t, "%Y-%m-%d %H:%M:%S", tz = tz)
}

# Order of `handles` by their most recent message in `data` (newest first).
# Handles without any message go last, keeping their given order.
recentOrder <- function(handles, data) {
  last <- tapply(data$date, data$who, max)
  order(-as.numeric(last[handles]), na.last = TRUE)
}
