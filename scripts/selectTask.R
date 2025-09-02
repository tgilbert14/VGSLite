# Select Task

showModal(modalDialog(
  title = "Select Task to Run in VGS 5 Desktop",
  selectInput("subject_choice", "Tasks", choices = c("Move Event","Migrate to Local ONLY","Unlock VGS")),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_subject", "OK")
  ),
  easyClose = TRUE
))