d <- function() getDB(make_fixture())
day <- 978307200

test_that("no filters returns all rows, newest first", {
  p <- parser(d())
  expect_equal(nrow(p), 4)
  expect_false(is.unsorted(rev(p$date)))
})
test_that("id filter works", {
  expect_equal(nrow(parser(d(), "+111")), 2)
})
test_that("date filters work alone and combined", {
  expect_equal(nrow(parser(d(), dateStart = day + 86400)), 3)
  expect_equal(nrow(parser(d(), dateEnd = day + 86400)), 2)
  expect_equal(nrow(parser(d(), dateStart = day + 86400, dateEnd = day + 172800)), 2)
})
test_that("id plus dates are all applied (regression)", {
  p <- parser(d(), "+111", dateStart = day + 86400)
  expect_equal(p$text, "b")
})

test_that("localTime converts UTC strings to the given zone", {
  expect_equal(localTime("2024-01-01 23:30:00", tz = "Europe/Warsaw"), "2024-01-02 00:30:00")
  expect_equal(localTime(c("2024-07-01 12:00:00", NA), tz = "UTC"),
               c("2024-07-01 12:00:00", NA))
})

test_that("recentOrder sorts handles by latest message, unknown last", {
  d <- data.frame(who = c("a", "b", "a", "c"), date = c(10, 50, 30, 20))
  h <- c("a", "x", "b", "c")
  expect_equal(h[recentOrder(h, d)], c("b", "a", "c", "x"))
})
