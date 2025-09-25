# if new species added by accident (not on list, so need to add) -->
showModal(modalDialog(
  title = "Add New Species",
  textInput("new_fk_species", "USDA Code", value = speciesTo),
  textInput("new_qualifier", "SpeciesQualifier"),
  footer = tagList(
    modalButton("Cancel"),
    actionButton("submit_new_species", "Add", class = "btn-success")
  ),
  easyClose = TRUE
))