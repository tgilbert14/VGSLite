# Select Task

showModal(modalDialog(
  title = "Select Task to Run in VGS 5 Desktop",
  selectInput("subject_choice", "Tasks", choices = c("Clean Database",
                                                     "Convert database to Local",
                                                     "Delete Unassigned data",
                                                     "Empty Tombstone",
                                                     "Move Event"#,
                                                     #"Unlock VGS"
                                                     )),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_subject", "OK")
  ),
  easyClose = TRUE
))