# save speciesA
speciesA(speciesFrom)

# clean to get species name
dash <- gregexpr("\\-", speciesFrom)[[1]][1]
spFromSlim <- substr(speciesFrom, 0, dash-1)
species_name <- VGS_codes$Scientific.Name[VGS_codes$Symbol == spFromSlim]

# confirm selection
output$selected_siteFrom <- renderPrint({
  cat(paste0("Update species to: ", speciesFrom," (",species_name,")"))
})
Sys.sleep(.2)
removeModal()

shinyjs::show("open_sp_modal_B")