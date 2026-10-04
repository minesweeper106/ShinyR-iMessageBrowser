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
