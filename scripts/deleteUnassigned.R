# Deleting everything in unassigned folder

result <- dbExecute(mydb, clear.unassigned.sample)
showModal(modalDialog(
  title = "Deleting unassigned data...",
  tags$div(
    style = "color: red; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unassigned Samples(s) deleted ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.unassigned.inq)
showModal(modalDialog(
  title = "Deleting unassigned data...",
  tags$div(
    style = "color: red; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unassigned Inquiry samples(s) deleted ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.unassigned.event)
showModal(modalDialog(
  title = "Deleting unassigned data...",
  tags$div(
    style = "color: red; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unassigned Event(s) deleted ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.unassigned.eventGroup)
showModal(modalDialog(
  title = "Deleting unassigned data...",
  tags$div(
    style = "color: red; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unassigned Event Groups(s) deleted ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.unassigned.site)
showModal(modalDialog(
  title = "Deleting unassigned data...",
  tags$div(
    style = "color: red; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unassigned Site(s) deleted ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

showModal(modalDialog(
  title = "Deleting unassigned data...",
  tags$div(
    style = "color: red; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unassigned Inquiry samples(s) deleted ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))

showModal(modalDialog(
  title = "Unassigned Data Deleted ✨",
  tags$div(
    style = "color: green; font-weight: bold; margin-bottom: 10px;",
    paste0("Process Complete!")
  ),
  tags$div(
    style = "color: orange; font-weight: bold; margin-bottom: 10px;",
    paste0("Please run 'Empty Tombstone' task after this if Syncing.")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))