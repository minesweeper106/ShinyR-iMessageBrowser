# Communication timeline: one entry per day of conversation with a contact.

# Summarise a conversation per local day, newest day first.
# `messages`: data.frame from parser() with columns xdate (UTC string), text, sent.
# `tz`: time zone for day boundaries / times ("" = this machine's zone).
# Returns one row per day: day, month (label), n_sent, n_received, first_time,
# last_time ("HH:MM"), first_sent (did I write first that day?) and snippet
# (first text message of the day, "(attachment)" if the day has none).
buildTimeline <- function(messages, tz = "") {
  out <- data.frame(day = character(), month = character(),
                    n_sent = integer(), n_received = integer(),
                    first_time = character(), last_time = character(),
                    first_sent = logical(), snippet = character(),
                    stringsAsFactors = FALSE)
  if (is.null(messages) || nrow(messages) == 0) return(out)

  local <- as.POSIXct(as.character(messages$xdate), tz = "UTC")
  ok <- !is.na(local)
  if (!any(ok)) return(out)
  messages <- messages[ok, , drop = FALSE]
  local <- local[ok]
  o <- order(local)
  messages <- messages[o, , drop = FALSE]
  local <- local[o]

  day   <- format(local, "%Y-%m-%d", tz = tz)
  time  <- format(local, "%H:%M", tz = tz)
  month <- format(local, "%B %Y", tz = tz)
  sent  <- !is.na(messages$sent) & messages$sent == 1
  text  <- gsub("\\s+", " ", trimws(ifelse(is.na(messages$text), "", messages$text)))
  has_text <- nzchar(text)
  width <- 120L
  text <- ifelse(nchar(text) > width, paste0(substr(text, 1, width - 1L), "\u2026"), text)

  rows <- lapply(split(seq_along(day), day), function(i) {   # days ascending
    t <- i[has_text[i]]
    data.frame(day = day[i[1]], month = month[i[1]],
               n_sent = sum(sent[i]), n_received = sum(!sent[i]),
               first_time = time[i[1]], last_time = time[i[length(i)]],
               first_sent = sent[i[1]],
               snippet = if (length(t)) text[t[1]] else "(attachment)",
               stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out[rev(seq_len(nrow(out))), , drop = FALSE]
}

# Build the timeline widget from buildTimeline() output, showing the newest
# `limit` days. Text is escaped by htmltools (never raw HTML).
timelineUI <- function(tl, limit = 30) {
  shown <- tl[seq_len(min(nrow(tl), limit)), , drop = FALSE]
  items <- list(timelineStart(color = "red"))
  prev <- NULL
  for (i in seq_len(nrow(shown))) {
    r <- shown[i, ]
    if (!identical(prev, r$month)) {
      items[[length(items) + 1]] <- timelineLabel(r$month, color = "orange")
      prev <- r$month
    }
    items[[length(items) + 1]] <- timelineItem(
      icon = icon(if (r$first_sent) "arrow-up" else "arrow-down"),
      color = if (r$first_sent) "blue" else "green",
      time = if (r$first_time == r$last_time) r$first_time
             else paste(r$first_time, "-", r$last_time),
      title = r$day,
      p(r$snippet),
      tags$small(class = "text-muted",
                 paste0(r$n_sent, " sent / ", r$n_received, " received")),
      border = FALSE
    )
  }
  if (nrow(shown) >= nrow(tl)) items[[length(items) + 1]] <- timelineEnd(color = "gray")
  do.call(timelineBlock, c(items, list(reversed = FALSE, width = 12)))
}
