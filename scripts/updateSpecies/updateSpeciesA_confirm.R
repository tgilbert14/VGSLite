# save speciesA
speciesA(speciesFrom)
# confirm selection
output$selected_siteFrom <- renderPrint({
  cat(paste0("Update species: ", speciesFrom))
})
removeModal()

shinyjs::show("open_sp_modal_B")