
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

results <- DBI::dbExecute(mydb, update_speciesQ)

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
    paste0("Species update was applied despite overlap. ",results," entries updated from ",fk_species_from,qualifier_from," to ",fk_species_to,qualifier_to,"."),
    tags$div(
      style = "color: darkred; font-weight: bold; margin-bottom: 10px;",
      "Please look over generated .csv file and correct duplicates in VGS5."
    ),
    tags$div(
      style = "color: gray; margin-bottom: 10px;",
      "This can be done by going to each sample and de-selecting, then re-selecting the duplicated species."
    ),
    easyClose = TRUE
  ))
  # update parents Sync Keys ->
  DBI::dbExecute(mydb, event_updateQ)
  DBI::dbExecute(mydb, eventGroup_updateQ)
  DBI::dbExecute(mydb, protocol_updateQ)
  DBI::dbExecute(mydb, site_updateQ)
  # should add code to get rid of duplicates...
} else {
  showModal(modalDialog(
    title = "⚠️ Something went wrong!",
    "Update did not occur.",
    easyClose = TRUE
  ))
}

# create list of duplicated frequency events in same frame for user to fix ->
dup_freq <- paste0("Select SiteID, Protocol.Date, EventName, FK_Species, Transect, SampleNumber, Count(*) as summ from sample
inner join event on event.pk_event = sample.FK_Event
inner join site on site.PK_site = event.FK_Site
inner join eventgroup on eventgroup.PK_EventGroup = Event.FK_EventGroup
inner join protocol on protocol.PK_protocol = EventGroup.FK_Protocol
inner join species on species.PK_species = sample.FK_Species
where EventName LIKE '%Freq%'
group by FK_Species, Transect, SampleNumber, Protocol.Date
having summ > 1
order by SiteID, Protocol.Date, EventName, Transect, SampleNumber, FK_Species")

dup_freq_data <- DBI::dbGetQuery(mydb, dup_freq)

out_path <- file.path(tempdir(), "duplicatedSpeciesToFix.csv")
write.csv(dup_freq_data, out_path, row.names = FALSE)
shell.exec(out_path)
