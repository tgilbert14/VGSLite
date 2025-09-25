# pop up for select FROM site
showModal(modalDialog(
  title = "Check Selections",
  selectInput("confirm_choice_sp", "Confirm",
              choices = paste0("Update '",spFrom,"' to '",spTo,"?")),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_confirm_sp", "OK", class = "btn-info")
  ),
  easyClose = TRUE
))
Sys.sleep(.2)
removeModal()
