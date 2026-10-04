make_ab_fixture <- function() {
  f <- tempfile(fileext = ".db")
  con <- dbConnect(SQLite(), f)
  dbExecute(con, "CREATE TABLE ABPerson (ROWID INTEGER PRIMARY KEY, First TEXT, Last TEXT, Organization TEXT)")
  dbExecute(con, "CREATE TABLE ABMultiValue (UID INTEGER PRIMARY KEY, record_id INTEGER, property INTEGER, value TEXT)")
  dbExecute(con, "INSERT INTO ABPerson VALUES (1,'Ann','Lee',NULL),(2,'Bob',NULL,NULL),
                  (3,NULL,NULL,'Acme Pizza'),(4,'Cy','Dee',NULL),(5,'Di','Ex',NULL),(6,'Ed','Ex',NULL)")
  dbExecute(con, "INSERT INTO ABMultiValue (record_id, property, value) VALUES
    (1,3,'+44 20 7946 0958'),
    (2,4,'Bob@Example.com'),
    (3,3,'+1 (555) 010-9999'),
    (4,3,'0612 345 678'),
    (4,5,'1 Some Street'),
    (5,3,'0700 111 222'),
    (6,3,'0700-111-222'),
    (1,3,'+44 20 7946 0958')")
  dbDisconnect(con)
  f
}

test_that("normalizeHandle canonicalises phones, emails and text", {
  expect_equal(normalizeHandle(c("+44 20 7946 0958", "+1 (555) 010-9999", "0044 20 7946 0958")),
               c("+442079460958", "+15550109999", "+442079460958"))
  expect_equal(normalizeHandle(c(" Bob@Example.com ", "ACME")), c("bob@example.com", "acme"))
  expect_equal(normalizeHandle("0612 345 678"), "0612345678")
  expect_true(is.na(normalizeHandle(NA)))
})

test_that("getAddressBook reads phones and emails with display names", {
  ab <- getAddressBook(make_ab_fixture())
  expect_named(ab, c("name", "key"))
  expect_true(all(c("Ann Lee", "Bob", "Acme Pizza") %in% ab$name))
  expect_false(any(grepl("Some Street", ab$key)))   # addresses (property 5) ignored
})

test_that("exact matches work for phones and emails, case-insensitively", {
  ab <- getAddressBook(make_ab_fixture())
  m <- matchContacts(c("+442079460958", "bob@example.com", "+15550109999", "+99999999999"), ab)
  expect_equal(m$name, c("Ann Lee", "Bob", "Acme Pizza", NA))
  expect_equal(m$who[1], "+442079460958")
})

test_that("numbers saved without a country code match a unique handle suffix", {
  ab <- getAddressBook(make_ab_fixture())
  expect_equal(matchContacts("+33612345678", ab)$name, "Cy Dee")
})

test_that("ambiguous suffix matches stay unmatched", {
  ab <- getAddressBook(make_ab_fixture())
  expect_true(is.na(matchContacts("+4700111222", ab)$name))
})

test_that("duplicate Address Book entries do not duplicate handles", {
  ab <- getAddressBook(make_ab_fixture())
  expect_equal(nrow(matchContacts(c("+442079460958", "+442079460958"), ab)), 2)
})

test_that("displayName falls back to the handle", {
  contacts <- data.frame(who = c("+1", "+2", "x@y.z"), name = c("Ann", NA, "Bob"),
                         stringsAsFactors = FALSE)
  expect_equal(displayName(c("+2", "+1", "x@y.z", "+9"), contacts),
               c("+2", "Ann", "Bob", "+9"))
})

test_that("contactChoices maps labels to handles and disambiguates duplicates", {
  contacts <- data.frame(who = c("+1", "+2", "+3", "+4"),
                         name = c("Ann", "Ann", NA, "Cy"), stringsAsFactors = FALSE)
  ch <- contactChoices(contacts)
  expect_equal(unname(ch), c("+1", "+2", "+3", "+4"))
  expect_equal(names(ch), c("Ann (+1)", "Ann (+2)", "+3", "Cy"))
})
