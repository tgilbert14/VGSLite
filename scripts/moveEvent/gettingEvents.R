# get events
site_q <- paste0(
  "SELECT Protocol.Date AS Date FROM Protocol
          INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol
          INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
          INNER JOIN Site ON Site.PK_Site = Event.FK_Site
          WHERE Site.PK_Site = ", siteInfo$PK_Site, "
          Order By Protocol.Date DESC, Protocol.ProtocolName"
)

event_info <- DBI::dbGetQuery(mydb, site_q)
eventInfo(event_info)
# pop up for select events from site A
showModal(modalDialog(
  title = paste0("Moving Event"),
  selectInput("event_choice", "Move", choices = event_info$Date),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_event", "OK", class = "btn-primary")
  ),
  easyClose = TRUE
))