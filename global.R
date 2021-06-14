#Lib dependencies
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(shinydashboard)
library(shinydashboardPlus)
library(dplyr)
library(DBI)
library(RSQLite)

#My custom functions
source("datacalc.R")
source("parser.R")
source("generate.R")
source("getDB.R")

#Options
options(shiny.maxRequestSize = 20 * 1024^2)

#Global Vars
messages_per_contact<-0

