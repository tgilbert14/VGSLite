# Select Task

showModal(modalDialog(
  title = "Select Task to Run in VGS 5 Desktop",
  selectInput("subject_choice", "Tasks", choices = c("Move Event",
                                                     "Clean Database",
                                                     "Delete Unassigned data",
                                                     "Convert database to Local",
                                                     "Unlock VGS",
                                                     "Empty Tombstone"
                                                     )),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_subject", "OK")
  ),
  easyClose = TRUE
))