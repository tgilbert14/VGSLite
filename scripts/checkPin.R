
if (pin == "123") {
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














