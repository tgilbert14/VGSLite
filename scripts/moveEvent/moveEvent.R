# merge event to new site
merge_q <- paste0("Update Event
                          SET FK_Site = ",moveTo$PK_Site,", SyncKey = SyncKey + 1
                          Where PK_Event IN (
                            Select PK_Event from Protocol
                            INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
                            INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
                            INNER JOIN Site ON Site.PK_Site = Event.FK_Site
                            where PK_Site = ",moveFrom$PK_Site,"
                            and Date Like '%",onDate,"%')")

r <- DBI::dbExecute(mydb, merge_q)

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