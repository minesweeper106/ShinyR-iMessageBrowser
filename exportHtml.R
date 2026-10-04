# Export a conversation as one self-contained HTML file (inline CSS, no
# external requests, so it can be archived, emailed or printed as-is).

# `messages`: data.frame from parser() with columns xdate, text, sent
#             (any order; the export is chronological, oldest first)
# `contactName`: friendly name of the contact; `handle`: number / e-mail
# `tz`: time zone for the displayed times ("" = this machine's local zone);
#       xdate is stored in UTC and converted here
buildChatHtml <- function(messages, contactName, handle, myName = "Me", tz = "") {
  esc <- function(x) htmltools::htmlEscape(x, attribute = FALSE)
  messages <- messages[order(messages$xdate), , drop = FALSE]
  n <- nrow(messages)

  local <- as.POSIXct(as.character(messages$xdate), tz = "UTC")
  day <- format(local, "%Y-%m-%d", tz = tz)
  time <- format(local, "%H:%M", tz = tz)
  text <- ifelse(is.na(messages$text), "", messages$text)
  # attachments / empty messages have no text
  empty <- !nzchar(trimws(text))
  body_html <- ifelse(empty, "<em>(attachment or empty message)</em>",
                      gsub("\n", "<br>", esc(text), fixed = TRUE))
  sent <- !is.na(messages$sent) & messages$sent == 1

  rows <- character(0)
  if (n > 0) {
    new_day <- c(TRUE, day[-1] != day[-n])
    rows <- paste0(
      ifelse(new_day, paste0('<div class="day"><span>', esc(day), "</span></div>\n"), ""),
      '<div class="msg ', ifelse(sent, "sent", "received"), '">',
      '<div class="bubble">', body_html, "</div>",
      '<div class="meta">', esc(ifelse(sent, myName, contactName)), " &middot; ", esc(time), "</div>",
      "</div>")
  }

  range_txt <- if (n > 0) paste(day[1], "to", day[n]) else "no messages"
  title <- paste("Chat with", contactName)

  paste0(
'<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>', esc(title), '</title>
<style>
:root { --bg:#f2f2f7; --card:#fff; --text:#1c1c1e; --muted:#8e8e93;
        --sent:#0a84ff; --sent-text:#fff; --recv:#e5e5ea; --recv-text:#1c1c1e; }
@media (prefers-color-scheme: dark) {
  :root { --bg:#000; --card:#1c1c1e; --text:#f2f2f7; --muted:#8e8e93;
          --recv:#2c2c2e; --recv-text:#f2f2f7; } }
* { box-sizing: border-box; }
body { margin:0; background:var(--bg); color:var(--text);
       font:16px/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
header { position:sticky; top:0; background:var(--card); padding:12px 16px;
         border-bottom:1px solid rgba(128,128,128,.25); text-align:center; }
header h1 { margin:0; font-size:18px; }
header p { margin:2px 0 0; font-size:12px; color:var(--muted); }
main { max-width:760px; margin:0 auto; padding:16px; }
.day { text-align:center; margin:20px 0 8px; font-size:12px; color:var(--muted); }
.msg { display:flex; flex-direction:column; margin:4px 0; }
.msg.sent { align-items:flex-end; } .msg.received { align-items:flex-start; }
.bubble { max-width:78%; padding:8px 12px; border-radius:18px;
          overflow-wrap:anywhere; word-break:break-word; }
.sent .bubble { background:var(--sent); color:var(--sent-text); border-bottom-right-radius:4px; }
.received .bubble { background:var(--recv); color:var(--recv-text); border-bottom-left-radius:4px; }
.meta { font-size:11px; color:var(--muted); margin:2px 6px 0; }
footer { text-align:center; font-size:12px; color:var(--muted); padding:24px 16px; }
@media print { header { position:static; } body { background:#fff; } }
</style>
</head>
<body>
<header>
<h1>', esc(contactName), '</h1>
<p>', esc(handle), " &middot; ", n, " messages &middot; ", esc(range_txt), '</p>
</header>
<main>
', paste(rows, collapse = "\n"), '
</main>
<footer>Exported from iMessage Browser</footer>
</body>
</html>
')
}

# Safe file name for the download, e.g. "chat-Jane_Doe.html"
exportFileName <- function(contactName) {
  safe <- gsub("[^A-Za-z0-9._-]+", "_", contactName)
  safe <- gsub("^_+|_+$", "", safe)
  paste0("chat-", if (nzchar(safe)) safe else "contact", ".html")
}
