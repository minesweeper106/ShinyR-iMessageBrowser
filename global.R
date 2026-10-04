#Lib dependencies
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(dplyr)
library(DBI)
library(RSQLite)

#My custom functions
source("parser.R")
source("getDB.R")
source("searchMessages.R")

#Options
options(shiny.maxRequestSize = 20 * 1024^2)
