# save speciesA
speciesA(speciesFrom)
# confirm selection
output$selected_siteFrom <- renderPrint({
  cat(paste0("Update species to: ", speciesFrom," (",VGS_codes$Scientific.Name[VGS_codes$Symbol == speciesFrom],")"))
})
Sys.sleep(.2)
removeModal()

shinyjs::show("open_sp_modal_B")