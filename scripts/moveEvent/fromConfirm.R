# save siteA
siteA(sites[sites$SiteID == siteFrom, ])
# confirm selection
output$selected_siteFrom <- renderPrint({
  cat(paste0("Move Event from: ", siteFrom))
})
Sys.sleep(.2)
removeModal()
# hide old selection and add new site B selection
shinyjs::hide("open_site_modal_A")
shinyjs::show("open_site_modal_B")