# get rid of species selected 'from'

## Check all species being used
sp_check <- paste0("
  SELECT DISTINCT Sample.FK_Species, Sample.SpeciesQualifier
  FROM Protocol
  INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol
  INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
  INNER JOIN Site ON Site.PK_Site = Event.FK_Site
  INNER JOIN Sample ON Sample.FK_Event = Event.PK_Event
  INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
  WHERE List = 'NRCS' AND eventName LIKE '%Frequency%'
  ORDER BY Sample.FK_Species
")

speciesInUse <- dbGetQuery(mydb, sp_check)

speciesLeft <- subset(speciesInUse, paste(FK_Species, SpeciesQualifier, sep = "-") != input$sp_choice)
species_choices_2 <- c(
  paste(speciesLeft$FK_Species, speciesLeft$SpeciesQualifier, sep = "-"),
  "New Species"
)

updateSelectInput(session, "sp_choice_2", selected = "")

# pop up for update TO species
showModal(modalDialog(
  title = "Update TO",
  selectInput("sp_choice_2", "TO", choices = setNames(species_choices_2, species_choices_2), selected = NULL),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_sp_update_to", "OK", class = "btn-primary")
  ),
  easyClose = TRUE
))
