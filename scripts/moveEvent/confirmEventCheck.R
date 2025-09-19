# save event info
eventDate(info[info$Date == dateTo, ])
# confirm selection
output$selected_eventTo <- renderPrint({
  cat(paste0("Moving Event: ",substr(dateTo,1,10)))
})
Sys.sleep(.2)
removeModal()
# hide old selection and add new site B selection
shinyjs::hide("open_event_modal")
shinyjs::show("open_results_modal")