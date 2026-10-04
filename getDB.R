getDB <- function(file) {
  dbh <- dbConnect(SQLite(), file)
  on.exit(dbDisconnect(dbh), add = TRUE)
  dbGetQuery(
    dbh,
    "SELECT message.date/1000000000+978307200 AS date,
            datetime(message.date/1000000000+978307200,'unixepoch') AS xdate,
            message.text AS text,
            message.is_sent AS sent,
            COALESCE(handle.id, 'Unknown / group') AS who
     FROM message
     LEFT JOIN handle
     ON message.handle_id = handle.ROWID")
}
