parser <- function(data, id = NULL, dateStart = NULL, dateEnd = NULL) {

  message <- data

  if (!is.null(id)) {
    message <- message %>% filter(who == id)
  }
  if (!is.null(dateStart)) {
    message <- message %>% filter(date >= as.numeric(dateStart))
  }
  if (!is.null(dateEnd)) {
    message <- message %>% filter(date <= as.numeric(dateEnd))
  }

  message %>% arrange(desc(date))
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
