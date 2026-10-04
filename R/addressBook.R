# Address Book helpers: read an iOS AddressBook.sqlitedb and match its
# phone numbers / emails to the message handles found in chat.db.

# Canonical key for a phone number, email or other handle.
#  - emails / text handles: trimmed, lower-case
#  - phone numbers: digits only, keeping a leading "+" ("00" counts as "+")
normalizeHandle <- function(x) {
  x <- trimws(as.character(x))
  vapply(x, function(v) {
    if (is.na(v) || !nzchar(v)) return(NA_character_)
    digits <- gsub("[^0-9]", "", v)
    if (grepl("@", v, fixed = TRUE) || !nzchar(digits)) return(tolower(v))
    plus <- startsWith(v, "+")
    if (!plus && startsWith(digits, "00")) {
      plus <- TRUE
      digits <- sub("^00", "", digits)
    }
    paste0(if (plus) "+" else "", digits)
  }, character(1), USE.NAMES = FALSE)
}

# Read phone numbers (property 3) and emails (property 4) with a display name.
# Returns data.frame(name, key); organisation is used when a person has no name.
getAddressBook <- function(file) {
  dbh <- dbConnect(SQLite(), file)
  on.exit(dbDisconnect(dbh), add = TRUE)
  ab <- dbGetQuery(
    dbh,
    "SELECT p.First AS first, p.Last AS last, p.Organization AS org,
            m.value AS value
     FROM ABPerson p
     JOIN ABMultiValue m ON m.record_id = p.ROWID
     WHERE m.property IN (3, 4) AND m.value IS NOT NULL
     ORDER BY p.ROWID")
  name <- trimws(paste(ifelse(is.na(ab$first), "", ab$first),
                       ifelse(is.na(ab$last),  "", ab$last)))
  org <- ifelse(is.na(ab$org), "", trimws(ab$org))
  name[!nzchar(name)] <- org[!nzchar(name)]
  out <- data.frame(name = name, key = normalizeHandle(ab$value),
                    stringsAsFactors = FALSE)
  out[nzchar(out$name) & !is.na(out$key), , drop = FALSE]
}

# Match handles to Address Book names.
#  1. exact match on the normalised key (first entry wins if a key repeats)
#  2. for "+..." handles still unmatched: an Address Book number saved without
#     a country code (>= 7 digits, leading zeros dropped) that the handle ends
#     with - used only when it identifies exactly one person
# Returns data.frame(who, name); name is NA when nothing matches.
matchContacts <- function(handles, ab) {
  hk <- normalizeHandle(handles)
  exact <- ab[!duplicated(ab$key), , drop = FALSE]
  name <- exact$name[match(hk, exact$key)]

  local <- ab[grepl("^[0-9]+$", ab$key), , drop = FALSE]
  local$digits <- sub("^0+", "", local$key)
  local <- local[nchar(local$digits) >= 7, , drop = FALSE]
  for (i in which(is.na(name) & !is.na(hk) & startsWith(hk, "+"))) {
    hit <- unique(local$name[endsWith(substring(hk[i], 2), local$digits)])
    if (length(hit) == 1) name[i] <- hit
  }
  data.frame(who = handles, name = name, stringsAsFactors = FALSE)
}

# Friendly name for each handle in `who`, falling back to the handle itself.
# `contacts` is the data.frame(who, name) returned by matchContacts().
displayName <- function(who, contacts) {
  nm <- contacts$name[match(who, contacts$who)]
  ifelse(is.na(nm), who, nm)
}

# Choices for the contact dropdown: values are the handles, labels the friendly
# names. If two handles share a label (e.g. one person with two numbers), the
# handle is appended so they stay distinguishable.
contactChoices <- function(contacts) {
  label <- displayName(contacts$who, contacts)
  dup <- label %in% label[duplicated(label)]
  label[dup] <- paste0(label[dup], " (", contacts$who[dup], ")")
  stats::setNames(contacts$who, label)
}
