msgs <- data.frame(
  date  = c(3, 2, 1, 0),
  xdate = c("d3", "d2", "d1", "d0"),
  text  = c("Hello World", "price is $5 (approx.)", NA, "nothing here"),
  sent  = c(1, 0, 0, 1),
  who   = "+111",
  stringsAsFactors = FALSE
)

test_that("matching is case-insensitive and substring-based", {
  expect_equal(searchMessages(msgs, "hello")$date, 3)
  expect_equal(searchMessages(msgs, "WORLD")$date, 3)
  expect_equal(searchMessages(msgs, "ello wor")$date, 3)
})

test_that("regex metacharacters are treated literally", {
  expect_equal(searchMessages(msgs, "(approx.)")$date, 2)
  expect_equal(nrow(searchMessages(msgs, ".")), 1)  # only the literal '.'
  expect_equal(nrow(searchMessages(msgs, "(")), 1)
  expect_equal(nrow(searchMessages(msgs, "$5")), 1)
})

test_that("NA text rows are skipped", {
  expect_false(any(is.na(searchMessages(msgs, "e")$text)))
})

test_that("blank, NULL and NA keywords return no rows", {
  expect_equal(nrow(searchMessages(msgs, "")), 0)
  expect_equal(nrow(searchMessages(msgs, "   ")), 0)
  expect_equal(nrow(searchMessages(msgs, NULL)), 0)
  expect_equal(nrow(searchMessages(msgs, NA_character_)), 0)
})

test_that("columns and order are preserved", {
  r <- searchMessages(msgs, "e")
  expect_named(r, names(msgs))
  expect_false(is.unsorted(rev(r$date)))
})

test_that("works on real getDB output", {
  r <- searchMessages(parser(getDB(make_fixture())), "a")
  expect_true(all(grepl("a", r$text, ignore.case = TRUE)))
})
