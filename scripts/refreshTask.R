# Reset tab
updateTabsetPanel(session, "tab_menu", selected = "main")

# Reset reactive values
siteA(NULL)
siteB(NULL)
eventInfo(NULL)
eventDate(NULL)

speciesA(NULL)
speciesB(NULL)
speciesInfo(NULL)
speciesUpdateQurey(NULL)
syncUpdateEvent(NULL)
syncUpdateEventGroup(NULL)
syncUpdateProtocol(NULL)
syncUpdateSite(NULL)

shinyjs::show("open_task_modal")
shinyjs::hide("run_another_task")
shinyjs::hide("open_sp_modal")

# Clear outputs
output$selected_sub <- renderPrint({"Select new task to run"})
output$selected_siteFrom <- renderPrint({"Select new task attributes"})
output$selected_siteTo <- renderPrint({"Select new task attributes"})
output$selected_eventTo <- renderPrint({"Select new task attributes"})
output$selected_results <- renderPrint({"Select new task attributes"})

# reload app
shinyjs::runjs("location.reload();")
