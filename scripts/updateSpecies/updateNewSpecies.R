# save speciesB
newSp <- toupper(newSp)
newSpQualifier <- gsub("'","",newSpQualifier)
newSpQualifier <- gsub('"','',newSpQualifier)

if(nchar(newSpQualifier)==0){
  newSpQualifier <- "NA"
}

if (length(newSp)>6 || grepl("[[:punct:]]", newSp)) {
  stop("Code is too long or has special characters not allowed")
}
if (length(newSpQualifier)>20 || grepl("[[:punct:]]", newSpQualifier)) {
  stop("Qualifier is too long or has special characters not allowed.")
}

speciesTo <- paste0(newSp,"-",newSpQualifier)
speciesB(speciesTo)
# confirm selection
output$selected_siteTo <- renderPrint({
  cat(paste0("Update species to: ", speciesTo))
})
removeModal()
# hide old selection and add new site B selection
shinyjs::hide("open_sp_modal_B")
shinyjs::show("open_sp_modal")