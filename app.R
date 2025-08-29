
# Get app path
app_path <- getwd()

# <-- UI -->
ui <- fluidPage(
  
  useToastr(),
  useShinyjs(),
  theme = shinytheme("paper"),
  
  titlePanel("VGSLite"),
  
             
             sidebarLayout(
               sidebarPanel(
                 actionButton("open_task_modal", "Choose task",width = "240px",
                              icon = icon("list")),
                 br(),br(),
                 downloadButton("download_db", "Download Backup Database"),
                 br(),
                 textOutput("selected_sub")
               ),
               mainPanel(
                 tabsetPanel(id = "tab_menu",

                   tabPanel("Main Window", value = "main",
                            br(),
                            verbatimTextOutput("distText"),
                            DT::dataTableOutput("dataTable")#,
                            # br(),
                            # actionButton("delete", "Delete Selected")
                 ),
                 
                 tabPanel("Help Window", value = "help", br(),
                          actionButton("open_site_modal_A", "Moving FROM",
                                       icon = icon(	"arrow-left")), br(),
                          textOutput("selected_siteFrom"),
                          textOutput("selected_siteTo"),
                          textOutput("selected_eventTo"),
                          textOutput("selected_results"),
                          actionButton("open_site_modal_B", "Moving TO",
                                       icon = icon(	"arrow-right")), br(),
                          actionButton("open_event_modal", "Select Event to MOVE",
                                       icon = icon("exchange-alt")), br(),
                          actionButton("open_results_modal", "Confirm Move",
                                       icon = icon("play"))
                 )
                 
               )
             )
)
)

# <-- Server -->
server <- function(input, output, session) {

# hide initial buttons/elements
shinyjs::hide("open_site_modal_B")
shinyjs::hide("open_event_modal")
shinyjs::hide("open_results_modal")
  
# get data
data_site <- reactive({
  dbGetQuery(mydb, "SELECT SiteID, Notes, quote(PK_Site) AS PK_Site FROM Site Order By SiteID")
})

# initial table render
output$dataTable <- DT::renderDataTable({
  d <- data.frame(data_site())
  d <- d[names(d) != "PK_Site"]
  DT::datatable(d, rownames = FALSE, caption = "[VGS50.db]", style = "bootstrap4")
})

# define reactiveVal to hold selected site A
siteA <- reactiveVal()
siteB <- reactiveVal()
eventInfo <- reactiveVal()
eventDate <- reactiveVal() 

# <-- Task Selection ->
# open task modal
observeEvent(input$open_task_modal, {
  showModal(modalDialog(
    title = "Select Task to Run in VGS 5 Desktop",
    selectInput("subject_choice", "Tasks", choices = c("Move Event to different Site")),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_subject", "OK")
    ),
    easyClose = TRUE
  ))
})
observeEvent(input$submit_subject, {
  subj <- input$subject_choice
  # confirm selection
  output$selected_sub <- renderPrint({
    paste0("Task: ", subj)
  })
  # drop modal
  removeModal()
  # move to next tab
  updateTabsetPanel(session, "tab_menu", selected = "help")
})

# <-- SITE FROM (A) -->
# open site selection modal
observeEvent(input$open_site_modal_A, {
  req(input$subject_choice)
  sites <- data_site()
  
  # check for sites
  if (nrow(sites) == 0) {
    stop("No Sites Found...")
  }
  # make sure correct task is selected
  if(input$subject_choice == "Move Event to different Site") {
    sitesFound <- sites$SiteID
  } else {
    sitesFound <- "Select A Site first"
  }
  # pop up for select FROM site
  showModal(modalDialog(
    title = "Moving FROM",
    selectInput("site_choice", "FROM", choices = sitesFound),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_site_from", "OK")
    ),
    easyClose = TRUE
  ))
})
observeEvent(input$submit_site_from, {
  siteFrom <- input$site_choice
  sites <- data_site()
  # save siteA
  siteA(sites[sites$SiteID == siteFrom, ])
  # confirm selection
  output$selected_siteFrom <- renderPrint({
    paste0("Move Event from: ", siteFrom)
  })
  # drop modal
  removeModal()
  # hide old selection and add new site B selection
  shinyjs::hide("open_site_modal_A")
  shinyjs::show("open_site_modal_B")
})

# <-- SITE TO (B) -->
# open site selection modal
observeEvent(input$open_site_modal_B, {
  req(input$subject_choice)
  sites <- data_site()
  
  # get rid of site selected 'from'
  sitesFound <- sites$SiteID
  sitesFound <- sitesFound[sitesFound != input$site_choice]
  # pop up for select To site
  showModal(modalDialog(
    title = "Moving TO",
    selectInput("site_choice_2", "TO", choices = sitesFound),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_site_to", "OK")
    ),
    easyClose = TRUE
  ))
})
observeEvent(input$submit_site_to, {
  siteTo <- input$site_choice_2
  sites <- data_site()
  # save siteB
  siteB(sites[sites$SiteID == siteTo, ])
  # confirm selection
  output$selected_siteTo <- renderPrint({
    paste0("Move Event to: ", siteTo)
  })
  # drop modal
  removeModal()
  # hide old selection and add new site B selection
  shinyjs::hide("open_site_modal_B")
  shinyjs::show("open_event_modal")
})

# <-- EVENT TO MOVE (FROM A TO B) -->
# open site selection modal
observeEvent(input$open_event_modal, {
  req(input$subject_choice)
  siteInfo <- siteA()
  
  # get events
  site_q <- paste0(
    "SELECT Protocol.Date AS Date
   FROM Protocol
   INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol
   INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
   INNER JOIN Site ON Site.PK_Site = Event.FK_Site
   WHERE Site.PK_Site = ", siteInfo$PK_Site ," Order By Protocol.ProtocolName, Protocol.Date"
  )
  
  event_info <- DBI::dbGetQuery(mydb, site_q)
  eventInfo(event_info)
  
  # pop up for select events from site A
  showModal(modalDialog(
    title = paste0("Moving Event"),
    selectInput("event_choice", "Move", choices = event_info$Date),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_event", "OK")
    ),
    easyClose = TRUE
  ))
})
observeEvent(input$submit_event, {
  dateTo <- input$event_choice
  info <- eventInfo()

  # save event info
  eventDate(info[info$Date == dateTo, ])
  
  # confirm selection
  output$selected_eventTo <- renderPrint({
    paste0("Moving Event: ",substr(dateTo,1,10))
  })
  # drop modal
  removeModal()
  # hide old selection and add new site B selection
  shinyjs::hide("open_event_modal")
  shinyjs::show("open_results_modal")
  
})

# <-- RESULTS -->
# open site selection modal
observeEvent(input$open_results_modal, {
  moveFrom <- siteA()
  moveTo <- siteB()
  onDate <- eventDate()
  onDate <- unique(onDate)

  # pop up for select FROM site
  showModal(modalDialog(
    title = "Check Selections",
    selectInput("confirm_choice", "Confirm", 
                choices = paste0("Move '",moveFrom$SiteID,"' to '",moveTo$SiteID,
                                 "' for ",substr(onDate,1,10),"?")),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_confirm", "OK")
    ),
    easyClose = TRUE
  ))
})
observeEvent(input$submit_confirm, {
  confirmTo <- input$confirm_choice

  # merge sites!!
  merge_q <- paste0("Update Site
                    Set SiteID = 'WPF'
                    where SiteID = 'WPF'")
  r <- DBI::dbExecute(mydb, merge_q)
  
  # confirm selection
  output$selected_results <- renderPrint({
    if (r > 0) {
      paste0("Success!")
    } else {
      paste0("Something went wrong, please check you database or try again.")
    }
  })
  # drop modal
  removeModal()
  # hide old selection
  shinyjs::hide("open_results_modal")
})





# download button
output$download_db <- downloadHandler(
  filename = function() {
    paste0("SQL_storage_", Sys.Date(), ".db")
  },
  content = function(file) {
    file.copy(db_loc, file, overwrite = TRUE)
  },
  contentType = "application/octet-stream"
)

# disconnect database on session end
session$onSessionEnded(function() {
  dbDisconnect(mydb)
})

}

# run app
shinyApp(ui = ui, server = server)