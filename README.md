# iMessageBrowser
A simple shiny app that takes an IOS chat.db/sms.db backup file and renders an html chat view.

_Unpackaged; Just a source code_

![Screenshot](https://github.com/minesweeper106/iMessageBrowser_ShinyR/blob/master/screenshot.png)

## Dependencies
The following packages need to be installed in your R / RStudio environment

- shiny
- shinythemes
- dplyr
- DBI
- RSQLite

You can install a package by running a command
`install.packages("package_name")`

## How to run

1. Set the working directory to the location where you cloned or downloaded this repo.
2. Install any missing packages from the list above
3. Open app.R
4. Click _Run app_ in RStudio.

*OR*

Assuming that you have all the necessary libraries installed in your R environment, you can simply run this line from your R console:

`shiny::runGitHub('iMessageBrowser_ShinyR', 'minesweeper106')`

## Input file
The file you'll need is named `3d0d7e5fb2ce288813306e4d4636395e047a3d28` and it's stored somewhere in the backup folder created by ITunes.

## Disclaimer
It is just a stem of a project; a minimum viable code. Over time, it will get more robust and eventually packaged into a release
