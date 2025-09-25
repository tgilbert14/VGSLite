# Clean out orphan data

result <- dbExecute(mydb, clear.orphan.siteClass)

showModal(modalDialog(
  title = "Cleaning database...",
  tags$div(
    style = "color: seagreen; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " orphaned Site Class Link(s) cleaned ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.orphan.protocol)
showModal(modalDialog(
  title = "Cleaning database...",
  tags$div(
    style = "color: seagreen; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " orphaned Protocol(s) cleaned ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.orphan.typeList)
showModal(modalDialog(
  title = "Cleaning database...",
  tags$div(
    style = "color: seagreen; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unsued Protocol(s) removed from Protocol Manager ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.orphan.contactLink)
showModal(modalDialog(
  title = "Cleaning database...",
  tags$div(
    style = "color: seagreen; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " orphaned Contact Link(s) cleaned ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

result <- dbExecute(mydb, clear.orphan.contact)
showModal(modalDialog(
  title = "Cleaning database...",
  tags$div(
    style = "color: seagreen; font-weight: bold; margin-bottom: 10px;",
    paste0(result, " unused Contact(s) removed from Contact Manager ✅")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
Sys.sleep(1.5)

showModal(modalDialog(
  title = "Cleaned database ✨",
  tags$div(
    style = "color: green; font-weight: bold; margin-bottom: 10px;",
    paste0("Cleaning database process complete!")
  ),
  footer = tagList(
    modalButton("OK"),
  ),
  easyClose = TRUE
))
