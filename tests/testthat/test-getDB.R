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
