
# clean to get species name
dash <- gregexpr("\\-", speciesTo)[[1]][1]
spToSlim <- substr(speciesTo, 0, dash-1)
species_name <- VGS_codes$Scientific.Name[VGS_codes$Symbol == spToSlim]

species_selected_to <- input$sp_choice_2

# for when user tries to submit a species not on the list, same as 'New Species' -->
if (species_selected_to == "" || is.na(species_selected_to)) {
  #shinyjs::alert("⚠️ This species needs to be added using the 'New Species' option.")
  showModal(modalDialog(
    title = "⚠️ Species not currently being used in any other samples.",
    tags$div(
      style = "margin-bottom: 10px;",
      "You must add this species first before you continue!"
    ),
    footer = tagList(
      #modalButton("Cancel"),
      actionButton("submit_new_species_accident", "Add", class = "btn-success")
    )
  ))
}

# if new species selected -->
if (species_selected_to == "New Species") {
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
  # only do this if it is not going through previous 'new species' option above
  if (species_selected_to != "" && !is.na(species_selected_to)) {
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
}



