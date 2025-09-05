
# Get app path
app_path <- getwd()

# <-- UI -->
ui <- fluidPage(
  
  useToastr(),
  useShinyjs(),
  theme = shinytheme("flatly"),
  
  # titlePanel(""),
             
             sidebarLayout(
               sidebarPanel(
                 div(
                   style = "text-align: center; margin-top: 10px;",
                   tags$img(src = "assets/VGSLite.png", width = "220px", style = "margin-bottom:20px;"),
                   
                   actionButton("open_task_modal", "Choose task",width = "100%",
                                icon = icon("list")),
                   br(),br(),
                   #downloadButton("download_db", "Download Backup Database"),
                   br(),
                   textOutput("selected_sub")
                   )
                 ),
               mainPanel(
                 tabsetPanel(id = "tab_menu",

                   tabPanel("Main Window", value = "main", 
                            br(), actionButton("open_readme", "About", icon = icon("book"), width = "100px"), br(),br(),
                            verbatimTextOutput("distText"),
                            DT::dataTableOutput("dataTable")#,
                            #actionButton("open_readme", " ", icon = icon("info"), width = "40px"),
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
                          actionButton("open_results_modal", "Confirm Merge",
                                       icon = icon("play"))
                 )
                 
               )
               )
             )
)

# <-- Server -->
server <- function(input, output, session) {
  continue_app = TRUE
  # hide initial buttons/elements
  shinyjs::hide("open_site_modal_A")
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
    DT::datatable(d, rownames = FALSE, caption = "[ Database Preview of VGS 5 database on device ]", style = "bootstrap4")
  })
  
  # define reactive values for moving site option
  siteA <- reactiveVal()
  siteB <- reactiveVal()
  eventInfo <- reactiveVal()
  eventDate <- reactiveVal() 
  
  # <-- Task Selection ->
  observeEvent(input$open_task_modal, {
    source("scripts/selectTask.R")
  })
  observeEvent(input$submit_subject, {
    shinyjs::hide("open_task_modal")
    shinyjs::show("open_site_modal_A")
    
    subj <- input$subject_choice
    # confirm selection
    output$selected_sub <- renderPrint({
      cat(paste0("Task: ", subj))
    })
    removeModal()
    
    if (input$subject_choice == "Move Event") {
      # move to next tab ->
      updateTabsetPanel(session, "tab_menu", selected = "help")
    }

    ## <-- Make everything Local ONLY --> ##
    if (input$subject_choice == "Convert database to Local") {
      #continue_app = FALSE
      
      # Getting root folders and moving them under Local
      rootFolders <- dbGetQuery(mydb, "Select Schema from SyncTracking where Status = 'Completed'")
      locate_pks <- stringr::str_locate_all(rootFolders$Schema, "SelectedSchema")
       
      x=1
      while (x <= nrow(locate_pks[[1]])) {
        end <-  locate_pks[[1]][x]
        rootPK <- Convert2Hex(substr(rootFolders$Schema, end+17, end+52)[1])
        dbExecute(mydb, paste0("Update SiteClass
          Set CK_ParentClass = X'11111111111111111111111111111111' 
          Where PK_SiteClass = ",rootPK))
        x=x+1
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.contactLinks)
      if (result > 0) {
        shinyjs::alert("✅ Contact Links moved to local!")
      } else {
        shinyjs::alert("⚠️ No Contact Links found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.sample)
      if (result > 0) {
        shinyjs::alert("✅ Sample Data moved to local!")
      } else {
        shinyjs::alert("⚠️ No Sample Data found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.events)
      if (result > 0) {
        shinyjs::alert("✅ Events moved to local!")
      } else {
        shinyjs::alert("⚠️ No Events found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.eventGroups)
      if (result > 0) {
        shinyjs::alert("✅ Event Groups moved to local!")
      } else {
        shinyjs::alert("⚠️ No Event Groups found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.protocol)
      if (result > 0) {
        shinyjs::alert("✅ Protocols moved to local!")
      } else {
        shinyjs::alert("⚠️ No Protocols found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.site)
      if (result > 0) {
        shinyjs::alert("✅ Sites moved to local!")
      } else {
        shinyjs::alert("⚠️ No Sites found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.siteClass)
      if (result > 0) {
        shinyjs::alert("✅ Folders moved to local!")
      } else {
        shinyjs::alert("⚠️ No Folders found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.siteClassLinks)
      if (result > 0) {
        shinyjs::alert("✅ Folder Links moved to local!")
      } else {
        shinyjs::alert("⚠️ No Folder Links found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.inquiryDatum)
      if (result > 0) {
        shinyjs::alert("✅ Survey Data moved to local!")
      } else {
        shinyjs::alert("⚠️ No Inquiry Data found.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, updateToLocal.inquiry)
      if (result > 0) {
        shinyjs::alert("✅ Surveys moved to local!")
      } else {
        shinyjs::alert("⚠️ No Surveys found.")
      }
      Sys.sleep(0.5)
      
      shinyjs::alert("✨ Complete! ☑") 
      
    }
    
    ## <-- Unlock VGS admin features --> ##
    if (input$subject_choice == "Unlock VGS") {
      #continue_app = FALSE
      
      #shinyjs::alert("✨ Complete! ☑") 
      
    }
    
    ## <-- Cleaning up orphan data / non-linked data --> ##
    if (input$subject_choice == "Clean Database") {
      #continue_app = FALSE
      result <- dbExecute(mydb, clear.orphan.siteClass)
      if (result > 0) {
        shinyjs::alert("✅ Cleaned SiteClassLink orphans!")
      } else {
        shinyjs::alert("⚠️ No orphan'd SiteClassLinks.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.orphan.protocol)
      if (result > 0) {
        shinyjs::alert("✅ Cleaned Protocol orphans!")
      } else {
        shinyjs::alert("⚠️ No orphan'd Protocols.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.orphan.typeList)
      if (result > 0) {
        shinyjs::alert("✅ Cleaned unused Protocols in TypeList!")
      } else {
        shinyjs::alert("⚠️ All Protocols in TypeList being used.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.orphan.contactLink)
      if (result > 0) {
        shinyjs::alert("✅ Cleaned ContactLink orphans!")
      } else {
        shinyjs::alert("⚠️ No orphan'd ContactLinks.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.orphan.contact)
      if (result > 0) {
        shinyjs::alert("✅ Cleaned unused Contacts!")
      } else {
        shinyjs::alert("⚠️ All Contacts being used.")
      }
      Sys.sleep(0.5)
      
      shinyjs::alert("✨ Complete! ☑") 
    }
    
    ## <-- Cleaning up orphan data / non-linked data --> ##
    if (input$subject_choice == "Delete Unassigned data") {
      #continue_app = FALSE
      
      result <- dbExecute(mydb, clear.unassigned.sample)
      if (result > 0) {
        shinyjs::alert("✅ Unassigned sample data cleared successfully!")
      } else {
        shinyjs::alert("⚠️ No unassigned sample data.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.unassigned.inq)
      if (result > 0) {
        shinyjs::alert("✅ Unassigned inquiry data cleared successfully!")
      } else {
        shinyjs::alert("⚠️ No unassigned inquiry data.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.unassigned.event)
      if (result > 0) {
        shinyjs::alert("✅ Unassigned events cleared successfully!")
      } else {
        shinyjs::alert("⚠️ No unassigned events.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.unassigned.eventGroup)
      if (result > 0) {
        shinyjs::alert("✅ Unassigned inquiry cleared successfully!")
      } else {
        shinyjs::alert("⚠️ No unassigned event groups.")
      }
      Sys.sleep(0.5)
      
      result <- dbExecute(mydb, clear.unassigned.site)
      if (result > 0) {
        shinyjs::alert("✅ Unassigned sites cleared successfully!")
      } else {
        shinyjs::alert("⚠️ No unassigned sites.")
      }
      Sys.sleep(0.5)
      
      shinyjs::alert("✨ Complete! ☑")  
    }
    
    ## <-- Cleaning up orphan data / non-linked data --> ##
    if (input$subject_choice == "Empty Tombstone") {
      #continue_app = FALSE
      result <- dbExecute(mydb, clear.tombstone)
      if (result > 0) {
        shinyjs::alert("✅ Tombstone cleared successfully!")
      } else {
        shinyjs::alert("⚠️ Tombstone records are empty.")
      }
      Sys.sleep(0.5)
      
      shinyjs::alert("✨ Complete! ☑") 
    }
    
  })
    
  ## <-- Move Event --> ##
  # SITE FROM (A) -->
  # open site selection modal
  observeEvent(input$open_site_modal_A, {
    req(input$subject_choice)
    sites <- data_site()

    if (continue_app == TRUE) {
      # check for sites
      if (nrow(sites) == 0) {
        stop("No Sites Found...")
      }
      # make sure correct task is selected
      if(input$subject_choice == "Move Event") {
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
    }
  })
  observeEvent(input$submit_site_from, {
    siteFrom <- input$site_choice
    sites <- data_site()
    # save siteA
    siteA(sites[sites$SiteID == siteFrom, ])
    # confirm selection
    output$selected_siteFrom <- renderPrint({
      cat(paste0("Move Event from: ", siteFrom))
    })
    removeModal()
    # hide old selection and add new site B selection
    shinyjs::hide("open_site_modal_A")
    shinyjs::show("open_site_modal_B")
  })
  
  # SITE TO (B) -->
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
      cat(paste0("Move Event to: ", siteTo))
    })
    removeModal()
    # hide old selection and add new site B selection
    shinyjs::hide("open_site_modal_B")
    shinyjs::show("open_event_modal")
  })
  
  # EVENT TO MOVE (FROM A TO B) -->
  observeEvent(input$open_event_modal, {
    req(input$subject_choice)
    siteInfo <- siteA()
    
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
      cat(paste0("Moving Event: ",substr(dateTo,1,10)))
    })
    removeModal()
    # hide old selection and add new site B selection
    shinyjs::hide("open_event_modal")
    shinyjs::show("open_results_modal")
  })
  
  # <-- RESULTS
  # open site selection modal
  observeEvent(input$open_results_modal, {
    moveFrom <- siteA()
    moveTo <- siteB()
    onDate_saved <- eventDate()
    onDate <- unique(onDate_saved)
    
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
    moveFrom <- siteA()
    moveTo <- siteB()
    onDate <- unique(eventDate())
    
    # merge event to new site
    merge_q <- paste0("Update Event
                          SET FK_Site = ",moveTo$PK_Site,", SyncKey = SyncKey + 1
                          Where PK_Event IN (
                            Select PK_Event from Protocol
                            INNER JOIN EventGroup ON EventGroup.FK_Protocol = Protocol.PK_Protocol  
                            INNER JOIN Event ON Event.FK_EventGroup = EventGroup.PK_EventGroup
                            INNER JOIN Site ON Site.PK_Site = Event.FK_Site
                            where PK_Site = ",moveFrom$PK_Site,"
                            and Date Like '%",onDate,"%')")
    
    r <- DBI::dbExecute(mydb, merge_q)
    
    # confirm selection
    output$selected_results <- renderPrint({
      if (r > 0) {
        cat("Success!")
      } else {
        cat("Something went wrong, please check you database or try again.")
      }
    })
    # drop modal
    removeModal()
    # hide old selection
    shinyjs::hide("open_results_modal")
  })
  
  ## <-- Read me -->
  observeEvent(input$open_readme, {
    showModal(modalDialog(
      #title = "About VGSLite",
      includeMarkdown("README.html"),
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
  
  ## <-- download button -->
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