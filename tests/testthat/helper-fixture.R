library(dplyr)
library(DBI)
library(RSQLite)
root <- normalizePath(file.path("..", ".."))
source(file.path(root, "parser.R"))
source(file.path(root, "getDB.R"))

make_fixture <- function() {
  f <- tempfile(fileext = ".db")
  con <- dbConnect(SQLite(), f)
  dbExecute(con, "CREATE TABLE handle (ROWID INTEGER PRIMARY KEY, id TEXT)")
  dbExecute(con, "CREATE TABLE message (ROWID INTEGER PRIMARY KEY, date INTEGER, text TEXT, is_sent INTEGER, handle_id INTEGER)")
  dbExecute(con, "INSERT INTO handle VALUES (1,'+111'),(2,'+222')")
  # Apple epoch ns: 0 -> 2001-01-01 (978307200 unix)
  dbExecute(con, "INSERT INTO message VALUES
    (1, 0,                 'a', 0, 1),
    (2, 86400000000000,    'b', 1, 1),
    (3, 172800000000000,   'c', 0, 2),
    (4, 259200000000000,   'd', 1, 0)")
  dbDisconnect(con)
  f
}
