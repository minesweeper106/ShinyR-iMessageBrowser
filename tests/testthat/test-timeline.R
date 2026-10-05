msgs <- function(xdate, text, sent) {
  data.frame(xdate = xdate, text = text, sent = sent, stringsAsFactors = FALSE)
}

test_that("one row per day, newest first, with sent/received counts", {
  p <- parser(getDB(make_fixture()), "+111")   # 2001-01-02 sent 'b'; 2001-01-01 received 'a'
  tl <- buildTimeline(p, tz = "UTC")
  expect_equal(tl$day, c("2001-01-02", "2001-01-01"))
  expect_equal(tl$n_sent, c(1, 0))
  expect_equal(tl$n_received, c(0, 1))
  expect_equal(tl$first_sent, c(TRUE, FALSE))
  expect_equal(tl$snippet, c("b", "a"))
})

test_that("messages on the same day are aggregated", {
  m <- msgs(c("2024-05-01 08:00:00", "2024-05-01 20:30:00", "2024-05-01 09:15:00"),
            c("hi", "bye", "hello"), c(1, 0, 0))   # unsorted on purpose
  tl <- buildTimeline(m, tz = "UTC")
  expect_equal(nrow(tl), 1)
  expect_equal(tl$n_sent, 1)
  expect_equal(tl$n_received, 2)
  expect_equal(tl$first_time, "08:00")
  expect_equal(tl$last_time, "20:30")
  expect_true(tl$first_sent)
  expect_equal(tl$snippet, "hi")
  expect_equal(tl$month, tl$month[1])
})

test_that("days are assigned in the requested time zone", {
  m <- msgs("2024-01-01 23:30:00", "late", 0)
  expect_equal(buildTimeline(m, tz = "UTC")$day, "2024-01-01")
  expect_equal(buildTimeline(m, tz = "Europe/Warsaw")$day, "2024-01-02")
  expect_equal(buildTimeline(m, tz = "Europe/Warsaw")$first_time, "00:30")
})

test_that("snippet uses the first text message, skips attachments, truncates", {
  long <- paste(rep("word", 60), collapse = " ")
  m <- msgs(c("2024-05-01 08:00:00", "2024-05-01 09:00:00", "2024-05-02 10:00:00"),
            c(NA, long, NA), c(0, 0, 1))
  tl <- buildTimeline(m, tz = "UTC")
  expect_equal(tl$snippet[2], paste0(substr(gsub("\\s+", " ", long), 1, 119), "…"))
  expect_lte(nchar(tl$snippet[2]), 120)
  expect_equal(tl$snippet[1], "(attachment)")   # 2024-05-02: only an attachment
})

test_that("newlines in snippets are collapsed", {
  m <- msgs("2024-05-01 08:00:00", "line1\n\nline2", 0)
  expect_equal(buildTimeline(m, tz = "UTC")$snippet, "line1 line2")
})

test_that("empty / NULL input gives a zero-row frame with the same columns", {
  full <- buildTimeline(msgs("2024-05-01 08:00:00", "x", 0), tz = "UTC")
  for (e in list(msgs(character(), character(), numeric()), NULL)) {
    tl <- buildTimeline(e, tz = "UTC")
    expect_equal(nrow(tl), 0)
    expect_equal(names(tl), names(full))
  }
})

test_that("rows with an unparseable date are ignored", {
  m <- msgs(c("2024-05-01 08:00:00", NA), c("a", "b"), c(0, 0))
  expect_equal(buildTimeline(m, tz = "UTC")$n_received, 1)
})

test_that("timelineUI renders limited days, month labels and escapes text", {
  m <- msgs(c("2024-04-30 08:00:00", "2024-05-01 08:00:00", "2024-05-02 08:00:00"),
            c("<b>x</b>", "b", "c"), c(0, 1, 0))
  tl <- buildTimeline(m, tz = "UTC")
  html <- as.character(timelineUI(tl, limit = 2))
  expect_match(html, "2024-05-02", fixed = TRUE)
  expect_match(html, "2024-05-01", fixed = TRUE)
  expect_no_match(html, "2024-04-30", fixed = TRUE)   # beyond the limit
  expect_equal(lengths(regmatches(html, gregexpr("time-label", html))), 1)  # one month shown
  full <- as.character(timelineUI(tl, limit = 10))
  expect_no_match(full, "<b>x</b>", fixed = TRUE)      # escaped, not raw HTML
  expect_match(full, "&lt;b&gt;x&lt;/b&gt;", fixed = TRUE)
  expect_equal(lengths(regmatches(full, gregexpr("time-label", full))), 2)
})
