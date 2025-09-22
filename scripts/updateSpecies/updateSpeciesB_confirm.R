
# clean to get species name
dash <- gregexpr("\\-", speciesTo)[[1]][1]
spToSlim <- substr(speciesTo, 0, dash-1)
species_name <- VGS_codes$Scientific.Name[VGS_codes$Symbol == spToSlim]

# if new species -->
if (input$sp_choice_2 == "New Species") {
  showModal(modalDialog(
    title = "Add New Species",
    textInput("new_fk_species", "USDA Code"),
    textInput("new_qualifier", "SpeciesQualifier"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("submit_new_species", "Add", class = "btn-success")
    ),
    easyClose = TRUE
  ))
} else {
  # continue as usual ->
  speciesB(speciesTo)
  # confirm selection
  output$selected_siteTo <- renderPrint({
    cat(paste0("Update species to: ", speciesTo," (",species_name,")"))
  })
  Sys.sleep(.2)
  removeModal()
  # hide old selection and add new site B selection
  shinyjs::hide("open_sp_modal_B")
  shinyjs::show("open_sp_modal")
}



