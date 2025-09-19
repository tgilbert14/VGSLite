

## Check all species being used
sp_check <- paste0("SELECT DISTINCT Sample.FK_Species, Sample.SpeciesQualifier from Protocol
INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol
INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
INNER JOIN Site ON Site.PK_Site = Event.FK_Site
INNER JOIN Sample ON Sample.FK_Event = Event.PK_Event
INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
where (List = 'NRCS' OR List = 'UDFS') and (eventName LIKE '%Freq%' OR eventName LIKE '%DWR%')
order by Sample.FK_Species")

speciesInUse <- dbGetQuery(mydb, sp_check)

# Combine both values with a hyphen
species_choices <- paste(speciesInUse$FK_Species, speciesInUse$SpeciesQualifier, sep = "-")

updateSelectInput(session, "sp_choice", selected = "")

# Use combined string as both label and value
showModal(modalDialog(
  title = "Select Species to Update",
  selectInput("sp_choice", "", choices = setNames(species_choices, species_choices), selected = NULL),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_sp_update", "OK", class = "btn-primary")
  ),
  easyClose = TRUE
))


