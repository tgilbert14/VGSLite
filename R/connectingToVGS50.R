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

## <-- Clean out / Delete unassigned sites -->

#-- Use to delete unassigned sample data (everything in unassigned folder)
clear.unassigned.sample <- paste0("delete from sample
  where PK_Sample NOT IN (
  select PK_Sample from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
  INNER JOIN Sample ON Sample.FK_Event = Event.PK_Event  
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site 
  INNER JOIN SiteClassLink on SiteClassLink.FK_Site = Site.PK_Site
  INNER JOIN SiteClass on SiteClass.PK_SiteClass = SiteClassLink.FK_SiteClass)")

#-- Use to delete unassigned inq data
clear.unassigned.inq <- paste0("delete from Inquiry
where PK_Inquiry NOT IN (
  select PK_Inquiry from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
  INNER JOIN Inquiry ON Inquiry.FK_Event = Event.PK_Event  
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site 
  INNER JOIN SiteClassLink on SiteClassLink.FK_Site = Site.PK_Site
  INNER JOIN SiteClass on SiteClass.PK_SiteClass = SiteClassLink.FK_SiteClass)")

#-- Use to delete unassigned Event Data
clear.unassigned.event <- paste0("Delete from Event
Where PK_Event NOT IN(
  SELECT DISTINCT PK_Event from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup  
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site 
  INNER JOIN SiteClassLink on SiteClassLink.FK_Site = Site.PK_Site
  INNER JOIN SiteClass on SiteClass.PK_SiteClass = SiteClassLink.FK_SiteClass)")

#--Use to delete unassigned event groups
clear.unassigned.eventGroup <- paste0("Delete from EventGroup
Where PK_EventGroup NOT IN(
  SELECT DISTINCT PK_EventGroup from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup)")

#-- then use this to delete unassined sites
clear.unassigned.site <- paste0("delete from site
where PK_Site NOT IN (
  select DISTINCT PK_Site from Site
  INNER JOIN SiteClassLink on SiteClassLink.FK_Site = Site.PK_Site
  INNER JOIN SiteClass on SiteClass.PK_SiteClass = SiteClassLink.FK_SiteClass)")


# <-- Empty the Tombstone/trash folder, gets rid of deletion tracking -->

#-- delete everything from tombstone to avoid possible sync conflicts
clear.tombstone <- paste0("delete from tombstone")


# <-- Cleaning up orphan data / non-linked data (SiteFolders, Contacts, Protocols)

#-- checking Orphan links
clear.orphan.siteClass <- paste0("delete from SiteClassLink
where PK_SiteClassLink NOT IN (
  select DISTINCT PK_SiteClassLink from Site
  INNER JOIN SiteClassLink on SiteClassLink.FK_Site = Site.PK_Site
  INNER JOIN SiteClass on SiteClass.PK_SiteClass = SiteClassLink.FK_SiteClass)")

clear.orphan.protocol <- paste0("Delete from Protocol
Where PK_Protocol NOT IN(
  SELECT DISTINCT PK_protocol from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup)")

#--delete protocols not in use from typeList
clear.orphan.typeList <- paste0("delete from typeList
WHERE List = 'PROTOCOL'
AND PK_Type NOT IN (
  select DISTINCT FK_Type_Protocol from Protocol
  INNER JOIN typeList ON typeList.PK_Type = Protocol.FK_Type_Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
  INNER JOIN Sample ON Sample.FK_Event = Event.PK_Event  
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site 
  INNER JOIN SiteClassLink on SiteClassLink.FK_Site = Site.PK_Site
  INNER JOIN SiteClass on SiteClass.PK_SiteClass = SiteClassLink.FK_SiteClass)")

#-- checking Orphan links - Contact
clear.orphan.contactLink <- paste0("delete from ContactLink
where PK_ContactLink NOT IN (
  select DISTINCT PK_ContactLink from Contact
  INNER JOIN ContactLink on ContactLink.FK_Contact = Contact.PK_Contact)")

#-- getting rid of unused contacts
clear.orphan.contact <- paste0("delete from contact
where PK_Contact NOT IN (
  select DISTINCT PK_Contact from Contact
  RIGHT JOIN ContactLink on ContactLink.FK_Contact = Contact.PK_Contact)")

