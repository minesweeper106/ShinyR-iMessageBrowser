test_that("getDB keeps messages without a handle", {
  d <- getDB(make_fixture())
  expect_equal(nrow(d), 4)
  expect_true("Unknown / group" %in% d$who)
})
test_that("getDB converts Apple epoch and returns expected columns", {
  d <- getDB(make_fixture())
  expect_named(d, c("date", "xdate", "text", "sent", "who"))
  expect_equal(min(d$date), 978307200)
  expect_equal(d$xdate[d$date == 978307200], "2001-01-01 00:00:00")
})

test_that("getDB handles legacy dates stored in seconds", {
  f <- make_fixture()
  con <- dbConnect(SQLite(), f)
  DBI::dbExecute(con, "DELETE FROM message")
  DBI::dbExecute(con, "INSERT INTO message VALUES (1, 504203016, 'old', 0, 1)")
  DBI::dbDisconnect(con)
  d <- getDB(f)
  expect_equal(d$date, 504203016 + 978307200)
  expect_equal(substr(d$xdate, 1, 4), "2016")
})
