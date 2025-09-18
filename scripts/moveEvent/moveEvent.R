# sync Key update ->
max_SyncKey <- paste0("select Max(SyncKey) from event")
SyncKey <- DBI::dbGetQuery(mydb, max_SyncKey)

## <-- Get PKs for table updates -->
site_to_update <- paste0("Select DISTINCT FK_Site from Event
  Where PK_Event IN (
  Select PK_Event from Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site
  where PK_Site = ",moveTo$PK_Site,")")

## EventGroups -->
update_syncKeys_EventGroup <- paste0("Select DISTINCT PK_EventGroup from Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  where PK_Site IN (",site_to_update,")")
eventGroup_updateQ <- paste0("Update EventGroup
                              Set SyncKey = ",SyncKey+1,"
                              where PK_EventGroup IN (",
                             update_syncKeys_EventGroup,")")
## Protocols -->
update_syncKeys_Protocol <- paste0("Select DISTINCT PK_Protocol from Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  where PK_Site IN (",site_to_update,")")
protocol_updateQ <- paste0("Update Protocol
                            Set SyncKey = ",SyncKey+1,"
                            where PK_Protocol IN (",
                           update_syncKeys_Protocol,")")
## Sites -->
update_syncKeys_Site <- paste0("Select DISTINCT PK_Site from Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  where PK_Site IN (",site_to_update,")")
site_updateQ <- paste0("Update Site
                        Set SyncKey = ",SyncKey+1,"
                        where PK_Site IN (",
                       update_syncKeys_Site,")")

## Move event to new site -->
merge_q <- paste0("Update Event
                          SET FK_Site = ",moveTo$PK_Site,", SyncKey = ",SyncKey+1," 
                          Where PK_Event IN (
                            Select PK_Event from Protocol
                            INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
                            INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
                            INNER JOIN Site ON Site.PK_Site = Event.FK_Site
                            where PK_Site = ",moveFrom$PK_Site,"
                            and Date Like '%",onDate,"%')")

r <- DBI::dbExecute(mydb, merge_q)

# update parent Sync Keys ->
DBI::dbExecute(mydb, eventGroup_updateQ)
DBI::dbExecute(mydb, protocol_updateQ)
DBI::dbExecute(mydb, site_updateQ)

# confirm selection
output$selected_results <- renderPrint({
  if (r > 0) {
    cat("Success!")
  } else {
    cat("Something went wrong, please check you database or try again.")
  }
})
removeModal()
shinyjs::hide("open_results_modal")