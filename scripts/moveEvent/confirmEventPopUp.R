# pop up for select FROM site
showModal(modalDialog(
  title = "Check Selections",
  selectInput("confirm_choice", "Confirm", 
              choices = paste0("Move '",moveFrom$SiteID,"' to '",moveTo$SiteID,
                               "' for ",substr(onDate,1,10),"?")),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_confirm", "OK", class = "btn-primary")
  ),
  easyClose = TRUE
))