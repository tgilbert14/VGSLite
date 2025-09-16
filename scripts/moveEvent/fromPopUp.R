if (continue_app == TRUE) {
  # check for sites
  if (nrow(sites) == 0) {
    stop("No Sites Found...")
  }
  # make sure correct task is selected
  if(input$subject_choice == "Move Event") {
    sitesFound <- sites$SiteID
  } else {
    sitesFound <- "Select A Site first"
  }
  # pop up for select FROM site
  showModal(modalDialog(
    title = "Moving FROM",
    selectInput("site_choice", "FROM", choices = sitesFound),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_site_from", "OK")
    ),
    easyClose = TRUE
  ))
}