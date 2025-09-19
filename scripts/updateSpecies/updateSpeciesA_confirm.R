# save speciesA
speciesA(speciesFrom)
# confirm selection
output$selected_siteFrom <- renderPrint({
  cat(paste0("Update species: ", speciesFrom))
})
Sys.sleep(.2)
removeModal()

shinyjs::show("open_sp_modal_B")