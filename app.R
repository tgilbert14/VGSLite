

# Get app path
app_path <- getwd()

# <-- UI -->
ui <- fluidPage(
  
  useToastr(),
  useShinyjs(),
  theme = shinytheme("flatly"),
  #theme = shinytheme("journal"),
      
  # for Read me link
  tags$script('Shiny.addCustomMessageHandler("jsCode", function(message) {
  eval(message.code); });'),
  
             sidebarLayout(
               sidebarPanel(
                 div(
                   style = "text-align: center; margin-top: 10px; background-color: seagreen;",
                   tags$img(src = "assets/VGSLite2.png", width = "360px", style = "margin-bottom:30px;"),
                   
                   # choose task
                   actionButton(
                     title = "Select task to run",
                     inputId = "open_task_modal",
                     label = tags$img(
                       src = "icons8-plus-144.png",
                       height = "140px",
                       style = "margin: 0 8px; cursor: pointer; border: none; background: none; box-shadow: none;"
                     ),
                     style = "background: none; border: none; padding: 0;",
                     class = "no-outline"
                   ),
                   # old version
                   # actionButton("open_task_modal", "Choose task",width = "100%",nicon = icon("list")),
                   
                   br(),br(),
                   textOutput("selected_sub"),br(),
                   # for running another task after 1st task ran
                   uiOutput("task_complete_ui")
                   ) # end of div
                 ), # end of side panel
               
               mainPanel(
                 tabsetPanel(id = "tab_menu",

                   tabPanel("Overview", value = "main", br(),
                            fluidRow(

                              # GitHub link button
                              column(width = 1,
                                     div(
                                       title = "Link to GitHub repository",
                                       tags$a(
                                         href = "https://github.com/tgilbert14/VGSLite",
                                         target = "_blank",
                                         tags$img(src = "GitHub-Mark.png",
                                                  height = "60px",
                                                  style = "margin: 0 4px; margin-top:5px; cursor: pointer; border: none; background: none; box-shadow: none;")
                                         ))
                                     ),
                              
                              # download button
                              column(width = 1,
                                     div(
                                       title = "Download VGS5 database backup",
                                       tags$a(
                                         id = "download_db",
                                         href = "download_db",
                                         class = "shiny-download-link",
                                         target = "_blank",
                                         download = NA,
                                         tags$img(
                                           src = "icons8-download-96.png",
                                           height = "60px",
                                           style = "margin: 0 4px; margin-top:5px; cursor: pointer; border: none; background: none; box-shadow: none;")
                                       ))
                                     ),
                              
                              # About button linked to ReadMe
                              column(width = 8), # spacer to push About button to the right
                              column(width = 2,
                                     div(
                                       title = "About VGSLite application",
                                       style = "text-align: right;",
                                       actionButton(
                                         inputId = "open_readme",
                                         label = tags$img(
                                           src = "icons8-about-104.png",
                                           height = "60px",
                                           style = "margin: 0 8px; margin-top:5px; cursor: pointer; border: none; background: none; box-shadow: none;"
                                         ),
                                         style = "background: none; border: none; padding: 0;",
                                         class = "no-outline"
                                       )
                                     ))
                              
                              ), # end of fluid row
                            
                            br(),br(),
                            verbatimTextOutput("distText"),
                            DT::dataTableOutput("dataTable",width = "80%")
                            ), # end main window tab
                   
                   tabPanel("Task Window", value = "help", br(),
                            actionButton("open_site_modal_A", "FROM",
                                         icon = icon(	"arrow-left")), br(),
                            # for printing confirmation outputs
                            textOutput("selected_siteFrom"),
                            textOutput("selected_siteTo"),
                            textOutput("selected_eventTo"),
                            textOutput("selected_results"),
                            # move events modals
                            actionButton("open_site_modal_B", "TO",
                                         icon = icon(	"arrow-right")), br(),
                            actionButton("open_event_modal", "Select Event to MOVE",
                                         icon = icon("exchange-alt")), br(),
                            actionButton("open_results_modal", "Move Event",
                                         icon = icon("play")),
                            # update species modals
                            actionButton("open_sp_modal_B", "TO",
                                         icon = icon(	"arrow-right")), br(),
                            actionButton("open_sp_modal", "Update Species",
                                         icon = icon("play"))
                            ) # end help window tab
                   
                   ) # end of all tabs
                ) # end of Main Panel
               ) # end of Side Bar layout
  ) # end of UI

# <-- Server -->
server <- function(input, output, session) {
  # re-establish connection after refresh button hit
  source("R/connectingToVGS50.R", local = TRUE)
  
  continue_app = TRUE
  
  # hide initial buttons/elements
  shinyjs::hide("open_site_modal_A")
  shinyjs::hide("open_site_modal_B")
  shinyjs::hide("open_event_modal")
  shinyjs::hide("open_results_modal")
  shinyjs::hide("open_site_sp_B")
  shinyjs::hide("open_sp_modal")
  shinyjs::hide("open_sp_modal_B")
  
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
  
  # define reactive values for updating species
  speciesA <- reactiveVal()
  speciesB <- reactiveVal()
  speciesInfo <- reactiveVal()
  speciesUpdateQurey <- reactiveVal()
  matchedRows <- reactiveVal()
  speciesChanged <- reactiveVal()
  
  # updating sync keys for species
  syncUpdateEvent <- reactiveVal()
  syncUpdateEventGroup <- reactiveVal()
  syncUpdateProtocol <- reactiveVal()
  syncUpdateSite <- reactiveVal()
  
  # <-- Task Selection ->
  observeEvent(input$open_task_modal, {
    source("scripts/selectTask.R")
  })
  observeEvent(input$submit_subject, {
    shinyjs::hide("open_task_modal")
    
    subj <- input$subject_choice
    # confirm selection
    output$selected_sub <- renderPrint({
      cat(paste0("Task Selected: ", subj))
    })
    Sys.sleep(.2)
    removeModal()
    
    # Move to help window tab for multi-step tasks
    if (input$subject_choice == "Move Event") {
      updateTabsetPanel(session, "tab_menu", selected = "help")
      shinyjs::show("open_site_modal_A")
    }
    if (input$subject_choice == "Update Species (Frequency/DWR)") {
      updateTabsetPanel(session, "tab_menu", selected = "help")
    }
    
    ## <-- Check for var. and subspecies in use to fix or update --> ##
    if (input$subject_choice == "Check for var and sub species") {
      source("scripts/varSpeciesCheck.R", local = TRUE)
    }

    ## <-- Make everything Local ONLY --> ##
    if (input$subject_choice == "Convert database to Local") {
      source("scripts/localOnly.R", local = TRUE)
    }
    
    ## <-- Unlock VGS admin features --> ##
    if (input$subject_choice == "Unlock VGS") {
      source("scripts/unlockVGS.R", local = TRUE)
    }
    
    ## <-- Cleaning up orphan data / non-linked data --> ##
    if (input$subject_choice == "Clean Database") {
      source("scripts/cleanOrphanLinks.R", local = TRUE)
    }
    
    ## <-- Deleting everything in unassigned bin --> ##
    if (input$subject_choice == "Delete Unassigned data") {
      source("scripts/deleteUnassigned.R", local = TRUE)
    }
    
    ## <-- Clear Deletion cache --> ##
    if (input$subject_choice == "Empty Tombstone") {
      source("scripts/emptyTombstone.R", local = TRUE)
    }
    
    ## <-- Update species --> ##
    observeEvent(input$subject_choice, {
      if (input$subject_choice == "Update Species (Frequency/DWR)") {
        if (adminLevel == "TRUE") {
          # SPECIES (A) -->
          source("scripts/updateSpecies/updateSpeciesA.R", local = TRUE)
        } else {
          showModal(modalDialog(
            title = "🔐 Enter Access PIN",
            passwordInput("pin_input", "PIN:", value = ""),
            footer = tagList(
              actionButton("submit_pin", "Submit"),
              modalButton("Cancel")
            ),
            easyClose = FALSE
          ))
        }
      }
    })
    # admin check -->
    observeEvent(input$submit_pin, {
      source("scripts/checkPin.R", local = TRUE)
    })
    observeEvent(input$submit_sp_update, {
      speciesFrom <- input$sp_choice
      source("scripts/updateSpecies/updateSpeciesA_confirm.R", local = TRUE)
    })
    
    # SPECIES TO (B) -->
    observeEvent(input$open_sp_modal_B, {
      req(input$sp_choice)
      source("scripts/updateSpecies/updateSpeciesB.R", local = TRUE)
    })
    observeEvent(input$submit_sp_update_to, {
      speciesTo <- input$sp_choice_2
      source("scripts/updateSpecies/updateSpeciesB_confirm.R", local = TRUE)
    })
    observeEvent(input$submit_new_species, {
      newSp <- input$new_fk_species
      newSpQualifier <- input$new_qualifier
      source("scripts/updateSpecies/updateNewSpecies.R", local = TRUE)
    })
    
    # UPDATE SPECIES CHECK (A TO B) -->
    observeEvent(input$open_sp_modal, {
      spFrom <- speciesA()
      spTo <- speciesB()
      source("scripts/updateSpecies/confirmSpeciesUpdate.R", local = TRUE)
    })
    observeEvent(input$confirm_choice_sp, {
      confirmTo <- input$confirm_choice_sp
      spFrom <- speciesA()
      spTo <- speciesB()
      SyncKey <- getSyncKey()
      source("scripts/updateSpecies/processSpeciesUpdate.R", local = TRUE)
    })
    observeEvent(input$submit_check, {
      update_speciesQ <- speciesUpdateQurey()
      event_updateQ <- syncUpdateEvent()
      eventGroup_updateQ <- syncUpdateEventGroup()
      protocol_updateQ <- syncUpdateProtocol()
      site_updateQ <- syncUpdateSite()
      spFrom <- speciesA()
      spTo <- speciesB()
      source("scripts/updateSpecies/overrideCheck.R", local = TRUE)
    })
    
    ## <-- REFRESH tasks button -->
    output$task_complete_ui <- renderUI({
      div(
        title = "Refresh app to run another task",
        actionButton(
          inputId = "run_another_task",
          label = tags$img(
            src = "icons8-refresh-500.png",
            height = "240px",
            style = "margin: 0 8px; margin-top:5px; cursor: pointer; border: none; background: none; box-shadow: none;"
          ),
          style = "background: none; border: none; padding: 0;",
          class = "no-outline"
        )
      )
    })
    
  }) # End of task selection on main view
    
  ## <-- Move Event --> ##
  # SITE FROM (A) -->
  observeEvent(input$open_site_modal_A, {
    req(input$subject_choice)
    sites <- data_site()
    source("scripts/moveEvent/fromPopUp.R", local = TRUE)
  })
  observeEvent(input$submit_site_from, {
    siteFrom <- input$site_choice
    sites <- data_site()
    source("scripts/moveEvent/fromConfirm.R", local = TRUE)
  })
  
  # SITE TO (B) -->
  observeEvent(input$open_site_modal_B, {
    req(input$subject_choice)
    sites <- data_site()
    source("scripts/moveEvent/toPopUp.R", local = TRUE)
  })
  observeEvent(input$submit_site_to, {
    siteTo <- input$site_choice_2
    sites <- data_site()
    source("scripts/moveEvent/toConfirm.R", local = TRUE)
  })
  
  # EVENT TO MOVE (FROM A TO B) -->
  observeEvent(input$open_event_modal, {
    req(input$subject_choice)
    siteInfo <- siteA()
    source("scripts/moveEvent/gettingEvents.R", local = TRUE)
  })
  observeEvent(input$submit_event, {
    dateTo <- input$event_choice
    info <- eventInfo()
    source("scripts/moveEvent/confirmEventCheck.R", local = TRUE)
  })
  
  # <-- RESULTS -->
  observeEvent(input$open_results_modal, {
    moveFrom <- siteA()
    moveTo <- siteB()
    onDate_saved <- eventDate()
    onDate <- unique(onDate_saved)
    source("scripts/moveEvent/confirmEventPopUp.R", local = TRUE)
  })
  observeEvent(input$submit_confirm, {
    confirmTo <- input$confirm_choice
    moveFrom <- siteA()
    moveTo <- siteB()
    onDate <- unique(eventDate())
    SyncKey <- getSyncKey()
    source("scripts/moveEvent/moveEvent.R", local = TRUE)
  })
  
  ## <-- Read me -->
  observeEvent(input$open_readme, {
    session$sendCustomMessage(type = "jsCode", list(code = "window.open('README.html', '_blank');"))
  })
  
  ## <--  Run another task/refresh app button -->
  observeEvent(input$run_another_task, {
    source("scripts/refreshTask.R", local = TRUE)
  })
  
  ## <-- download database button -->
  output$download_db <- downloadHandler(
    filename = function() {
      paste0("VGSLite_Backup_", Sys.Date(), ".db")
    },
    content = function(file) {
      if (file.exists(db_loc)) {
        file.copy(from = db_loc, to = file, overwrite = TRUE)
      } else {
        stop("Database file not found at: ", db_loc)
      }
    },
    contentType = "application/octet-stream"
  )
  
  ## <-- download conflict updates button -->
  output$download_conflicts <- downloadHandler(
    filename = function() {
      paste0(speciesB(),"_duplicationsToFix_",Sys.Date(),".csv")
    },
    content = function(file) {
      write.csv(matchedRows(), file, row.names = FALSE)
    },
    contentType = "text/csv"
  )

  ## <-- download species changed updates button -->
  output$download_update_results <- downloadHandler(
    filename = function() {
      paste0(speciesA(),"_updatedTo_",speciesB(),"_",Sys.Date(),".csv")
    },
    content = function(file) {
      write.csv(speciesChanged(), file, row.names = FALSE)
    },
    contentType = "text/csv"
  )
  
  ## <-- download species of interest button -->
  output$download_var_results <- downloadHandler(
    filename = function() {
      paste0("SpeciesOfInterest_",Sys.Date(),".csv")
    },
    content = function(file) {
      write.csv(speciesChanged(), file, row.names = FALSE)
    },
    contentType = "text/csv"
  )
  
  # disconnect database on session end
  session$onSessionEnded(function() {
    dbDisconnect(mydb)
  })
  
}

# run app
shinyApp(ui = ui, server = server)