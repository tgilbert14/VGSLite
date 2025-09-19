# merge species (update) -->

# break apart fk_species and qualifiers and format for SQL insert
parts_from <- strsplit(spFrom, "-", fixed = TRUE)[[1]]
fk_species_from <- parts_from[1]
qualifier_from <- parts_from[2]
if (qualifier_from == "NA") {
  qualifier_from <- "IS NULL"
} else {
  qualifier_from <- paste0("= '",qualifier_from,"'")
}

parts_to <- strsplit(spTo, "-", fixed = TRUE)[[1]]
fk_species_to <- parts_to[1]
qualifier_to <- parts_to[2]
if (qualifier_to == "NA") {
  qualifier_to <- "IS NULL"
  qualifier_insert = FALSE
} else {
  qualifier_to <- paste0("= '",qualifier_to,"'")
  qualifier_insert = TRUE
}

## <-- Get PKs for table updates -->
## Samples -->
update_syncKeys_Sample <- paste0("Select DISTINCT PK_Sample from Sample
  inner join event on event.pk_event = sample.FK_Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  where List = 'NRCS' and (eventName LIKE '%Freq%' OR eventName LIKE '%DWR%')
  and FK_Species = '",fk_species_from,"' and speciesQualifier ",qualifier_from," 
  order by SiteID, Protocol.Date, Transect, SampleNumber")
## Events -->
update_syncKeys_Event <- paste0("Select DISTINCT PK_Event from Sample
  inner join event on event.pk_event = sample.FK_Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  where List = 'NRCS' and (eventName LIKE '%Freq%' OR eventName LIKE '%DWR%')
  and FK_Species = '",fk_species_from,"' and speciesQualifier ",qualifier_from," 
  order by SiteID, Protocol.Date, Transect, SampleNumber")
event_updateQ <- paste0("Update Event
                         Set SyncKey = ",SyncKey+1,"
                         where PK_Event IN (",
                        update_syncKeys_Event,")")
## EventGroups -->
update_syncKeys_EventGroup <- paste0("Select DISTINCT PK_EventGroup from Sample
  inner join event on event.pk_event = sample.FK_Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  where List = 'NRCS' and (eventName LIKE '%Freq%' OR eventName LIKE '%DWR%')
  and FK_Species = '",fk_species_from,"' and speciesQualifier ",qualifier_from," 
  order by SiteID, Protocol.Date, Transect, SampleNumber")
eventGroup_updateQ <- paste0("Update EventGroup
                              Set SyncKey = ",SyncKey+1,"
                              where PK_EventGroup IN (",
                              update_syncKeys_EventGroup,")")
## Protocols -->
update_syncKeys_Protocol <- paste0("Select DISTINCT PK_Protocol from Sample
  inner join event on event.pk_event = sample.FK_Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  where List = 'NRCS' and (eventName LIKE '%Freq%' OR eventName LIKE '%DWR%')
  and FK_Species = '",fk_species_from,"' and speciesQualifier ",qualifier_from," 
  order by SiteID, Protocol.Date, Transect, SampleNumber")
protocol_updateQ <- paste0("Update Protocol
                            Set SyncKey = ",SyncKey+1,"
                            where PK_Protocol IN (",
                            update_syncKeys_Protocol,")")
## Sites -->
update_syncKeys_Site <- paste0("Select DISTINCT PK_Site from Sample
  inner join event on event.pk_event = sample.FK_Event
  inner join site on site.PK_site = event.FK_Site
  inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
  inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  where List = 'NRCS' and (eventName LIKE '%Freq%' OR eventName LIKE '%DWR%')
  and FK_Species = '",fk_species_from,"' and speciesQualifier ",qualifier_from," 
  order by SiteID, Protocol.Date, Transect, SampleNumber")
site_updateQ <- paste0("Update Site
                        Set SyncKey = ",SyncKey+1,"
                        where PK_Site IN (",
                        update_syncKeys_Site,")")

# update reactive value (sql statement) for species update - parent sync keys
syncUpdateEvent(update_syncKeys_Event)
syncUpdateEventGroup(update_syncKeys_EventGroup)
syncUpdateProtocol(update_syncKeys_Protocol)
syncUpdateSite(update_syncKeys_Site)

# setting statement depending on species/qualifier combo later
if (qualifier_insert == TRUE) {
  merge_q <- paste0("Update Sample
                  Set FK_Species = '",fk_species_to,"', FieldSymbol = '",fk_species_to,"',
                  SpeciesQualifier ",qualifier_to,", FieldQualifier ",qualifier_to,", SyncKey = ",SyncKey+1," 
                  Where FK_Species = '",fk_species_from,"' and SpeciesQualifier ",qualifier_from," 
                  And PK_Sample IN (",update_syncKeys_Sample,")")
} else {
  merge_q <- paste0("Update Sample
                  Set FK_Species = '",fk_species_to,"', FieldSymbol = '",fk_species_to,"',
                  SpeciesQualifier = NULL, FieldQualifier = NULL, SyncKey = ",SyncKey+1," 
                  Where FK_Species = '",fk_species_from,"' and SpeciesQualifier ",qualifier_from," 
                  And PK_Sample IN (",update_syncKeys_Sample,")")
}

# update reactive value (sql statement) for species update
speciesUpdateQurey(merge_q)

## <-- QAQC CHECK FIRST-->
## find where the updates would occur -> 
## *** ONLY CHECKING FREQUENCY FRAMES, DUPLICATES OKAY FOR DWR ***
update_check_q <- paste0("Select Transect, SampleNumber, SiteID, Protocol.Date from Sample
inner join event on event.pk_event = sample.FK_Event
inner join site on site.PK_site = event.FK_Site
inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
where List = 'NRCS' and eventName LIKE '%Freq%'
and FK_Species = '",fk_species_from,"' and speciesQualifier ",qualifier_from," 
order by SiteID, Protocol.Date, Transect, SampleNumber")

where_updates_would_occur <- DBI::dbGetQuery(mydb, update_check_q)

# where new updated species occurs ->
update_check_q2 <- paste0("Select Transect, SampleNumber, SiteID, Protocol.Date from Sample
inner join event on event.pk_event = sample.FK_Event
inner join site on site.PK_site = event.FK_Site
inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
where List = 'NRCS' and eventName LIKE '%Freq%'
and FK_Species = '",fk_species_to,"' and speciesQualifier ",qualifier_to," 
order by SiteID, Protocol.Date, Transect, SampleNumber")

where_species_is_already <- DBI::dbGetQuery(mydb, update_check_q2)

# converting to strings for comparison
rows_sp1 <- apply(where_updates_would_occur, 1, paste, collapse = "|")
rows_sp2 <- apply(where_species_is_already, 1, paste, collapse = "|")
common_rows <- intersect(rows_sp1, rows_sp2)
matched_rows <- where_updates_would_occur[rows_sp1 %in% common_rows, ]

# update matched_rows data frame for download
if (nrow(matched_rows)>0) {
  displayMatchedRows <- matched_rows
  displayMatchedRows$SpeciesCodeChanged <- paste0("From ",parts_from[1],"(",parts_from[2],") to ",parts_to[1],"(",parts_to[2],")")
  # update reactive variable for download
  matchedRows(displayMatchedRows)
} else{
  matchedRows(matched_rows)
}

# update where_updates_would_occur data frame for download
speciesOccured <- where_updates_would_occur
speciesOccured$SpeciesCodeChanged <- paste0("From ",parts_from[1],"(",parts_from[2],") to ",parts_to[1],"(",parts_to[2],")")
# update reactive values for download
speciesChanged(speciesOccured)

# pop up to override anyway or not
if (nrow(matched_rows)>0) {
  showModal(modalDialog(
    title = "⚠️ Species Update Blocked",
    tags$div(
      style = "color: darkred; font-weight: bold; margin-bottom: 10px;",
      paste0("This update would create duplicate species entries for ",nrow(matched_rows)," samples which will need to be corrected later.")
    ),
    tags$div(
      style = "margin-bottom: 10px;",
      "Please review the overlapping records below before proceeding:"
    ),
    tags$div(
      modalButton("Cancel"),
      actionButton("submit_check", "Override Anyway", class = "btn-danger"),
      downloadButton("download_conflicts", "Download CSV", class = "btn-info")
    ),
    renderTable({
      displayMatchedRows
    }, striped = TRUE, bordered = TRUE, width = "100%"),
    # footer = tagList(
    #   modalButton("Cancel"),
    #   downloadButton("download_conflicts", "Download CSV", class = "btn-info"),
    #   actionButton("submit_check", "Override Anyway", class = "btn-danger")
    # ),
    #easyClose = TRUE,
    size = "l"
  ))
} else {
  # update species ->
  results <- DBI::dbExecute(mydb, merge_q)
  
  # clean up results statement
  qualifier_to <- gsub("=","-",qualifier_to)
  qualifier_from <- gsub("=","-",qualifier_from)
  
  if (qualifier_to == "IS NULL") {
    qualifier_to <- ""
  }
  if (qualifier_from == "IS NULL") {
    qualifier_from <- ""
  }

  
  if (results > 0) {
    showModal(modalDialog(
      title = "✅ Update Complete",
      tags$div(
        style = "color: darkgreen; font-weight: bold; margin-bottom: 10px;",
        paste0("No conflicts found, ",results," entries updated from ",fk_species_from,qualifier_from," to ",fk_species_to,qualifier_to,".")
      ),
      tags$div(
        style = "margin-bottom: 10px;",
        "Updates occured at these locations:"
      ),
      tags$div(
        modalButton("OK"),
        downloadButton("download_update_results", "Download CSV", class = "btn-success"),
      ),
      renderTable({
        speciesOccured
      }, striped = TRUE, bordered = TRUE, width = "100%"),
      # footer = tagList(
      #   downloadButton("download_update_results", "Download CSV", class = "btn-success"),
      #   modalButton("OK")
      # ),
      #easyClose = TRUE
    ))
    # update parent Sync Keys ->
    DBI::dbExecute(mydb, event_updateQ)
    DBI::dbExecute(mydb, eventGroup_updateQ)
    DBI::dbExecute(mydb, protocol_updateQ)
    DBI::dbExecute(mydb, site_updateQ)
  }
}

shinyjs::hide("open_sp_modal")