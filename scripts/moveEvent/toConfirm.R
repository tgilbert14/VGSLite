# save siteB
siteB(sites[sites$SiteID == siteTo, ])
# confirm selection
output$selected_siteTo <- renderPrint({
  cat(paste0("Move Event to: ", siteTo))
})
removeModal()
# hide old selection and add new site B selection
shinyjs::hide("open_site_modal_B")
shinyjs::show("open_event_modal")