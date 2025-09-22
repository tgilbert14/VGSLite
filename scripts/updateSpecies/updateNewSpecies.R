# save speciesB
newSp <- toupper(newSp)
newSpQualifier <- gsub("['\"]", "", newSpQualifier)

# update qualifier if none
if(nchar(newSpQualifier)==0){
  newSpQualifier <- "NA"
}

# check for special characters and length of qualifier
if (length(newSpQualifier)>20 || grepl("[[:punct:]]", newSpQualifier)) {
  showModal(modalDialog(
    title = "❌ Invalid Qualifier",
    paste("Qualifier", newSpQualifier, "is too long or contains special characters. Max 20 characters, no punctuation."),
    footer = modalButton("OK"),
    easyClose = TRUE
  ))
} else {
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
      cat(paste0("Update species to: ", speciesTo," (",VGS_codes$Scientific.Name[VGS_codes$Symbol == speciesTo],")"))
    })
    
    Sys.sleep(.2)
    removeModal()
    shinyjs::hide("open_sp_modal_B")
    shinyjs::show("open_sp_modal")
  }
}






