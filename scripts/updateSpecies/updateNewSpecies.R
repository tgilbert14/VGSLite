# save speciesB
newSp <- toupper(newSp)
newSpQualifier <- gsub("['\"]", "", newSpQualifier)

if (length(newSp)>6 || grepl("[[:punct:]]", newSp)) {
  stop("Code is too long or has special characters not allowed")
}
if (length(newSpQualifier)>20 || grepl("[[:punct:]]", newSpQualifier)) {
  stop("Qualifier is too long or has special characters not allowed.")
}
if(nchar(newSpQualifier)==0){
  newSpQualifier <- "NA"
}

# Check if code is in accepted list
if (!(newSp %in% VGScodes)) {
  showModal(modalDialog(
    title = "❌ Invalid Species Code",
    paste("The code", newSp, "is not in the accepted VGScodes list."),
    footer = modalButton("OK"),
    easyClose = TRUE
  ))
} else {
  speciesTo <- paste0(newSp, "-", newSpQualifier)
  speciesB(speciesTo)
  
  output$selected_siteTo <- renderPrint({
    cat(paste0("Update species to: ", speciesTo))
  })
  
  Sys.sleep(.2)
  removeModal()
  shinyjs::hide("open_sp_modal_B")
  shinyjs::show("open_sp_modal")
}




