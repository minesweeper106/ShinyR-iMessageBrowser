

getDB<-function(file) {
  dbh <- dbConnect(SQLite(), file)
  dbtest <- dbGetQuery(
    dbh, 
    "SELECT date/1000000000+978307200 AS date, datetime(date/1000000000+978307200,'unixepoch') AS xdate ,text, is_sent AS sent, id AS who
        FROM message
        JOIN handle
        ON message.handle_id = handle.ROWID")
  dbDisconnect(dbh)
  dbtest
}
