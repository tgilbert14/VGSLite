# Reset reactive values
siteA(NULL)
siteB(NULL)
eventInfo(NULL)
eventDate(NULL)

shinyjs::show("open_task_modal")
shinyjs::hide("run_another_task")

# Reset tab
updateTabsetPanel(session, "tab_menu", selected = "main")

# Clear outputs
output$selected_sub <- renderPrint({"Select new task to run"})
output$selected_siteFrom <- renderPrint({"Select new task attributes"})
output$selected_siteTo <- renderPrint({"Select new task attributes"})
output$selected_eventTo <- renderPrint({"Select new task attributes"})
output$selected_results <- renderPrint({"Select new task attributes"})