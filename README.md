# iMessageBrowser_ShinyR
A simple shiny app that takes an IOS chat.db/sms.db backup file and renders an html chat view.

_Unpackaged; Just a source code_

![Screenshot](https://github.com/minesweeper106/iMessageBrowser_ShinyR/blob/master/screenshot.png)

## Requirements
The following packages need to be install in your R / RStudio environment

- shiny
- shinyWidgets
- shinythemes
- dplyr
- DBI
- RSQLite

You can install a package by running a command
`install.packages("package_name")`

## How to run

1. Navigate to the folder with downloaded code in your RStudio.
2. Set the working directory
3. Install any missing packages from the list above
4. Open app.R
5. Click _Run app_

## Input file
The file you'll need is named `3d0d7e5fb2ce288813306e4d4636395e047a3d28` and resides in a place where your itunes stores local backups. 

## Disclaimer
It is just a stem of a project; a minimum viable code. Over time, it will get more robust and eventually packaged into a release
