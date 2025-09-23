
if (pin == "8872391") {
  # update access level
  update_access <- data.frame(admin = "TRUE")
  write.csv(update_access, access_path, row.names = FALSE)
  removeModal()
  # and run task
  source("scripts/updateSpecies/updateSpeciesA.R", local = TRUE)
} else {
  showModal(modalDialog(
    title = "❌ Incorrect PIN",
    "Access denied. Please try again or contact tsgilbert@arizona.edu for access.",
    footer = modalButton("OK"),
    easyClose = TRUE
  ))
}














