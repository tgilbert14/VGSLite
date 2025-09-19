# Select Task

showModal(modalDialog(
  title = "Select Task to Run in VGS 5 Desktop",
  selectInput("subject_choice", "Tasks",
              choices = c("Clean Database",
                          #"Clean Species Up",
                          "Convert database to Local",
                          "Delete Unassigned data",
                          "Empty Tombstone",
                          "Move Event",
                          "Update Species (Frequency/DWR)"#,
                          #"Unlock VGS"
                          )),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_subject", "OK", class = "btn-primary")
  ),
  easyClose = TRUE
))