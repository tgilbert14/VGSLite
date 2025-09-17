# get rid of site selected 'from'
sitesFound <- sites$SiteID
sitesFound <- sitesFound[sitesFound != input$site_choice]
# pop up for select To site
showModal(modalDialog(
  title = "Moving TO",
  selectInput("site_choice_2", "TO", choices = sitesFound),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_site_to", "OK")
  ),
  easyClose = TRUE
))