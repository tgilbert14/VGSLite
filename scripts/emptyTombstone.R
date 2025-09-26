# empty everything in the tombstone table (deletion cache)

result <- dbExecute(mydb, clear.tombstone)

showModal(modalDialog(
  title = "Cleaned Deletion Cache ✨",
  tags$div(
    style = "color: seagreen; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " Tombstone record(s) cleaned ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))