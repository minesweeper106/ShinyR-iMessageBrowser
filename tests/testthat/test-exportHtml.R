msgs <- data.frame(
  xdate = c("2024-01-02 10:05:00", "2024-01-01 09:00:00", "2024-01-02 10:06:00"),
  text  = c("second <b>day</b>\nline2", "hello", NA),
  sent  = c(1, 0, 0),
  stringsAsFactors = FALSE)

test_that("buildChatHtml is chronological, escaped and self-contained", {
  html <- buildChatHtml(msgs, "Jane & Co", "+123")
  expect_match(html, "<!DOCTYPE html>", fixed = TRUE)
  expect_lt(regexpr("hello", html), regexpr("second", html))
  expect_match(html, "&lt;b&gt;day&lt;/b&gt;<br>line2", fixed = TRUE)
  expect_false(grepl("<b>day</b>", html, fixed = TRUE))
  expect_match(html, "Jane &amp; Co", fixed = TRUE)
  expect_match(html, "attachment or empty message", fixed = TRUE)
  expect_match(html, "3 messages", fixed = TRUE)
  expect_false(grepl("https?://", html))
})

test_that("buildChatHtml labels sent and received and groups by day", {
  html <- buildChatHtml(msgs, "Jane", "+123", tz = "UTC")
  expect_equal(lengths(regmatches(html, gregexpr('class="msg sent"', html))), 1)
  expect_equal(lengths(regmatches(html, gregexpr('class="msg received"', html))), 2)
  expect_equal(lengths(regmatches(html, gregexpr('class="day"', html))), 2)
  expect_match(html, "Me &middot; 10:05", fixed = TRUE)
})

test_that("buildChatHtml handles an empty conversation", {
  html <- buildChatHtml(msgs[0, ], "Jane", "+123")
  expect_match(html, "0 messages", fixed = TRUE)
})

test_that("exportFileName is filesystem-safe", {
  expect_equal(exportFileName("Jane Doe"), "chat-Jane_Doe.html")
  expect_equal(exportFileName("+48 123/456"), "chat-48_123_456.html")
  expect_equal(exportFileName("///"), "chat-contact.html")
})

test_that("buildChatHtml converts UTC timestamps to the requested time zone", {
  m <- data.frame(xdate = "2024-01-01 23:30:00", text = "hi", sent = 1,
                  stringsAsFactors = FALSE)
  html <- buildChatHtml(m, "Jane", "+1", tz = "Europe/Warsaw")
  expect_match(html, "2024-01-02", fixed = TRUE)
  expect_match(html, "Me &middot; 00:30", fixed = TRUE)
  expect_match(buildChatHtml(m, "Jane", "+1", tz = "UTC"), "Me &middot; 23:30", fixed = TRUE)
})
