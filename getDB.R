getDB <- function(file) {
  dbh <- dbConnect(SQLite(), file)
  on.exit(dbDisconnect(dbh), add = TRUE)
  # Apple epoch (2001-01-01): seconds on older macOS, nanoseconds since High Sierra.
  dbGetQuery(
    dbh,
    "SELECT CASE WHEN message.date > 1000000000000
                 THEN message.date/1000000000 ELSE message.date END + 978307200 AS date,
            datetime(CASE WHEN message.date > 1000000000000
                          THEN message.date/1000000000 ELSE message.date END + 978307200,
                     'unixepoch') AS xdate,
            message.text AS text,
            message.is_sent AS sent,
            COALESCE(handle.id, 'Unknown / group') AS who
     FROM message
     LEFT JOIN handle
     ON message.handle_id = handle.ROWID")
}
