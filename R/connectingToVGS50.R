library(shiny)
library(DT)
library(DBI)
library(RSQLite)
library(uuid)
library(shinytoastr)
library(digest)
library(shinyjs)
library(shinythemes)

# connect to local database
db_loc <- "C:/ProgramData/VGSData/VGS50.db"
mydb <- dbConnect(RSQLite::SQLite(), dbname = db_loc)

# <-- functions -->
# Convert UUID to hexadecimal
Convert2Hex <- function(vgs5_guid) {
  guid <- gsub("[{}-]", "", vgs5_guid)
  hex_guid <- tolower(paste0(
    substr(guid, 7, 8), substr(guid, 5, 6), substr(guid, 3, 4),
    substr(guid, 1, 2), substr(guid, 11, 12), substr(guid, 9, 10),
    substr(guid, 15, 16), substr(guid, 13, 14),
    gsub("-", "", substr(guid, 17, 36))
  ))
  return(paste0("X'", hex_guid, "'"))
}

# Get Data
getData <- function(table) {
  sql <-  "SELECT * FROM ?fromTable"
  query <- sqlInterpolate(mydb, sql, fromTable = table)
  table.data <- dbGetQuery(mydb, query)
}