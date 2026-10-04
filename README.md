# iMessage Browser

A local [Shiny](https://shiny.posit.co/) app for browsing iMessage backup files.

## Purpose

iPhone backups contain your whole message history, but locked away in raw database files that are hard to read. iMessage Browser opens those files and presents them the way a chat app would, so you can look back through old conversations, find a specific message, or keep a readable copy of a chat, without needing the phone itself.

Point it at a message database from an iPhone backup (or a Mac), pick a contact, and read the conversation in a chat-style view, search across all chats, or export a conversation as a single HTML file.

Everything runs on your own machine. Files you select are read locally and nothing is uploaded anywhere.

## What it offers

- **Contact list**: a scrollable, filterable sidebar list of everyone you have messages with, most recent conversation first.
- **Friendly names**: optionally load an iPhone Address Book file to show names instead of phone numbers / e-mail addresses. Numbers saved without a country code are matched too, when they identify exactly one person.
- **Chat view**: the conversation with the selected contact, with your messages labelled "Me".
- **Contact profile**: handle, number of messages, first and last message date.
- **Export**: download the selected conversation as one self-contained, nicely formatted HTML file (chat bubbles, grouped by day, light/dark aware, printable, no external requests).
- **Search**: case-insensitive keyword search across all contacts, with results shown in a sortable table.
- **Local time**: dates and times are shown in the time zone of the machine running the app.

## What it does not do

- **No attachments**: photos, videos and files are not shown or exported; such messages appear as empty / "(attachment or empty message)".
- **No group chats as such**: messages without a single contact handle are lumped together under "Unknown / group". Participants and group names are not resolved.
- **Read-only**: it never modifies your databases, sends messages or deletes anything.
- **No encrypted backups**: if your iPhone backup is encrypted, the files are unreadable. Make an unencrypted backup, or decrypt the files first with another tool (see [Encrypted backups](#encrypted-backups)).
- **iPhone Address Book format only**: the Address Book file must be the iOS `AddressBook.sqlitedb`. The Mac `AddressBook-v22.abcddb` uses a different layout and is not supported.
- **No reactions, edits, read receipts or message threading.**
- **Text only**: on some newer macOS versions message text can be stored in a form this app does not decode, so some messages from a Mac `chat.db` may appear empty. iPhone backups are the primary use case.
- **20 MB upload limit** per file (set in `run_app()`, `R/run_app.R`). Larger databases need the limit raised (`shiny.maxRequestSize`).
- **Not a backup or forensic tool**: no deleted-message recovery, no integrity checks.

## Getting the files

You need the message database, and optionally the Address Book. Work on a **copy**, not the original files.

### Locating the files

**iPhone backups (iTunes / Finder / Apple Devices app)**

| OS | Backup folder |
|---|---|
| macOS | `~/Library/Application Support/MobileSync/Backup/<device-UDID>/` |
| Windows (iTunes from apple.com) | `%APPDATA%\Apple Computer\MobileSync\Backup\<device-UDID>\` |
| Windows (iTunes or Apple Devices from Microsoft Store) | `%USERPROFILE%\Apple\MobileSync\Backup\<device-UDID>\` |
| Linux (libimobiledevice `idevicebackup2`) | No default; whatever directory you pass to the command |

Inside a backup, files are renamed to the SHA-1 hash of `Domain-relativePath` and stored in a subfolder named after the first two characters of the hash:

| Data | Original path on iPhone | File in backup |
|---|---|---|
| iMessage/SMS database | `HomeDomain-Library/SMS/sms.db` | `3d/3d0d7e5fb2ce288813306e4d4636395e047a3d28` |
| Contacts (Address Book) | `HomeDomain-Library/AddressBook/AddressBook.sqlitedb` | `31/31bb7ba8914766d4ba40d6dfb6113c8b614be442` |

`Manifest.db` in the backup root is a SQLite file that maps every hash to its original domain and path. If the backup is encrypted, these files are unreadable without the backup password.

**Live data on a Mac (Messages and Contacts synced via iCloud)**

| Data | Path |
|---|---|
| iMessage database | `~/Library/Messages/chat.db` |
| Message attachments | `~/Library/Messages/Attachments/` |
| Contacts | `~/Library/Application Support/AddressBook/AddressBook-v22.abcddb` |
| Contacts per account (iCloud, Exchange, etc.) | `~/Library/Application Support/AddressBook/Sources/<UUID>/AddressBook-v22.abcddb` |

On recent macOS versions, Terminal (or whatever app you use to read these files) needs Full Disk Access (System Settings → Privacy & Security).

> Only the message database and the iPhone-format Address Book work with this app (see limitations above). The Mac contacts files and the attachments folder are listed for reference.

**On the iPhone itself** (only reachable on a jailbroken device or through forensic tools)

The message database is at `/private/var/mobile/Library/SMS/sms.db` and contacts are at `/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb`.

All of these are SQLite databases, so you can also inspect them with `sqlite3` or DB Browser for SQLite.

### Encrypted backups

iMessage Browser cannot decrypt encrypted iPhone backups. The files inside are scrambled, and without decryption `sms.db` will fail to open. You have three options:

1. **Make an unencrypted backup.** In Finder (macOS) or iTunes / Apple Devices (Windows), untick *Encrypt local backup* and create a new backup. Your password-protected backup is not changed. Note that an unencrypted backup does not include some data (e.g. saved passwords, Health data), which does not matter for messages.
2. **Decrypt the backup you have, using another tool**, then load the resulting `sms.db` (and `AddressBook.sqlitedb`) here as usual. You need the backup password. Examples of tools that can do this:
   - [`iphone_backup_decrypt`](https://github.com/jsharkey13/iphone_backup_decrypt) (Python, open source)
   - [`iOSbackup`](https://github.com/avibrazil/iOSbackup) (Python, open source)
   - commercial apps such as iMazing

   These are third-party tools. This project does not endorse or test them, so check their documentation and work on a copy of your backup.
3. **Use a Mac's live `chat.db`** (see above), which is not encrypted at the file level.

Keep decrypted files somewhere safe and delete them when you are done: they contain your messages in plain form.

### Tip

Copy the hashed files out of the backup to somewhere convenient and give them recognisable names, e.g. `sms.db` and `AddressBook.sqlitedb`. The app does not care about file names, only about content.

## Installation

Requires [R](https://www.r-project.org/) 4.1 or newer.

```r
install.packages("remotes")
remotes::install_github("minesweeper106/ShinyR-iMessageBrowser")
```

Or install a downloaded release file (`imessagebrowser_1.0.0.tar.gz` from the GitHub Releases page):

```r
install.packages("imessagebrowser_1.0.0.tar.gz", repos = NULL, type = "source")
```

### Double-click launchers

After installing, the `launch/` folder has `iMessageBrowser.command` (macOS) and `iMessageBrowser.bat` (Windows) that start the app without opening R. On macOS you may need to right-click, then Open, the first time. They need `Rscript` to be on your PATH.

## Usage

1. Start the app:

   ```r
   imessagebrowser::run_app()
   ```

2. In the sidebar, click **Select backup file** and choose your message database (`sms.db` / `chat.db`).
3. *(Optional)* Click **Select Address Book file** and choose `AddressBook.sqlitedb` to show names instead of numbers. You can do this before or after picking a contact.
4. Pick a contact from the list. Use **Filter contacts** to narrow it by name or number.
5. Use the tabs:
   - **Chat View**: the conversation and the contact profile.
   - **Export**: **Download HTML** saves the selected conversation (oldest message first) as `chat-<name>.html`.
   - **Search**: type a word or phrase to search all conversations.

## Development

The project is an R package. Packages for development are pinned with [renv](https://rstudio.github.io/renv/) (`renv::restore()`).

```r
pkgload::load_all()                 # load the code
run_app()                           # start the app
testthat::test_local()              # run the tests
```

Build and check: `R CMD build .` then `R CMD check imessagebrowser_1.0.0.tar.gz`.

## Privacy

Message databases are highly personal. The app runs locally and makes no external requests: the avatars are SVG files bundled in `inst/app/www/`. Exported HTML files contain your full conversation text, so store and share them with care.

## Author

[minesweeper106](https://github.com/minesweeper106)

## Licence

MIT, see `LICENSE.md`.
