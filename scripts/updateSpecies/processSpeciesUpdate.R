# merge species (update)

# break apart fk_species and qualifiers and format for SQL
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

# sync Key update ->
max_SyncKey <- paste0("select Max(SyncKey) from sample")
SyncKey <- DBI::dbGetQuery(mydb, max_SyncKey)

# setting statement depending on species/qualifier combo later
if (qualifier_insert == TRUE) {
  merge_q <- paste0("Update Sample
                  Set FK_Species = '",fk_species_to,"', FieldSymbol = '",fk_species_to,"',
                  SpeciesQualifier ",qualifier_to,", FieldQualifier ",qualifier_to,", SyncKey = ",SyncKey," 
                  Where FK_Species = '",fk_species_from,"' and SpeciesQualifier ",qualifier_from," 
                  And nValue = 1 And nValue2 IS NULL And nValue3 IS NULL") # added to target Frequency only
} else {
  merge_q <- paste0("Update Sample
                  Set FK_Species = '",fk_species_to,"', FieldSymbol = '",fk_species_to,"',
                  SpeciesQualifier = NULL, FieldQualifier = NULL, SyncKey = ",SyncKey," 
                  Where FK_Species = '",fk_species_from,"' and SpeciesQualifier ",qualifier_from," 
                  And nValue = 1 And nValue2 IS NULL And nValue3 IS NULL") # added to target Frequency only
}

# update reactive value
speciesUpdateQurey(merge_q)

## <-- QAQC CHECK -->
## find where the updates would occur ->
update_check_q <- paste0("Select Transect, SampleNumber, SiteID, Protocol.Date from Sample
inner join event on event.pk_event = sample.FK_Event
inner join site on site.PK_site = event.FK_Site
inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
                  Where FK_Species = '",fk_species_from,"' and speciesQualifier ",qualifier_from)

where_updates_would_occur <- DBI::dbGetQuery(mydb, update_check_q)

# where new updated species occurs ->
update_check_q2 <- paste0("Select Transect, SampleNumber, SiteID, Protocol.Date from Sample
inner join event on event.pk_event = sample.FK_Event
inner join site on site.PK_site = event.FK_Site
inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
                  Where FK_Species = '",fk_species_to,"' and speciesQualifier ",qualifier_to)

where_species_is_already <- DBI::dbGetQuery(mydb, update_check_q2)

# converting to strings for comparison
rows_sp1 <- apply(where_updates_would_occur, 1, paste, collapse = "|")
rows_sp2 <- apply(where_species_is_already, 1, paste, collapse = "|")
common_rows <- intersect(rows_sp1, rows_sp2)
matched_rows <- where_updates_would_occur[rows_sp1 %in% common_rows, ]

if (nrow(matched_rows)>0) {
  showModal(modalDialog(
    title = "⚠️ Species Update Blocked",
    tags$div(
      style = "color: darkred; font-weight: bold; margin-bottom: 10px;",
      "This update would create duplicate species entries in the same Transect / SampleNumber / Site / Date combination which will have to be corrected later."
    ),
    tags$div(
      style = "margin-bottom: 10px;",
      "Please review the overlapping records below before proceeding:"
    ),
    renderTable({
      matched_rows
    }, striped = TRUE, bordered = TRUE, width = "100%"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_check", "Override Anyway", class = "btn-danger")
    ),
    easyClose = TRUE,
    size = "l"
  ))
} else {
  # update species ->
  results <- DBI::dbExecute(mydb, merge_q)
  
  if (results > 0) {
    showModal(modalDialog(
      title = "✅ Update Complete",
      tags$div(
        style = "color: darkgreen; font-weight: bold; margin-bottom: 10px;",
        paste0("No conflicts found. ",results," entries updated from ",fk_species_from," to ",fk_species_to,".")
      ),
      easyClose = TRUE
    ))
  }
}

shinyjs::hide("open_results_modal")