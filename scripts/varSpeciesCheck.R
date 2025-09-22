#Check for .var and subspecies in use to clean up data ->

## Check all species being used
sp_check <- paste0("SELECT DISTINCT SiteID, Protocol.Date, Sample.FK_Species, Sample.SpeciesQualifier, SpeciesName, CommonName from Protocol
INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol
INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
INNER JOIN Site ON Site.PK_Site = Event.FK_Site
INNER JOIN Sample ON Sample.FK_Event = Event.PK_Event
INNER JOIN Species ON Species.PK_Species = Sample.FK_Species
where (List = 'NRCS' OR List = 'UDFS') and (eventName LIKE '%Freq%' OR eventName LIKE '%DWR%')
order by Sample.FK_Species")

speciesInUse <- dbGetQuery(mydb, sp_check)

varSpecies <- speciesInUse[grep("var\\.", speciesInUse$SpeciesName),]
sspSpecies <- speciesInUse[grep("ssp\\.", speciesInUse$SpeciesName),]
speciesOfInterest <- rbind(varSpecies, sspSpecies)

if (nrow(speciesOfInterest) > 0) {
  showModal(modalDialog(
    title = "⚠️ Species variety (.var) and subspecies (ssp.) being used",
    tags$div(
      style = "color: blue; font-weight: bold; margin-bottom: 10px;",
      "Species of interest being used in database:"
    ),
    tags$div(
      modalButton("OK"),
      downloadButton("download_var_results", "Download CSV", class = "btn-success"),
    ),
    renderTable({
      speciesOfInterest
    }, striped = TRUE, bordered = TRUE, width = "100%"),
    size = "l"
  ))
} else {
  showModal(modalDialog(
    title = "✅ No species variety (.var) or subspecies (ssp.) being used!",
    easyClose = TRUE
  ))
}
