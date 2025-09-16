# Making all data local - no more syncing and cloud data after this...
#continue_app = FALSE
db_loc <- "C:/ProgramData/VGSData/VGS50.db"
mydb <- dbConnect(RSQLite::SQLite(), dbname = db_loc)

# Getting root folders and moving them under Local
rootFolders <- dbGetQuery(mydb, "Select Schema from SyncTracking where Status LIKE '%Complete%'")
locate_pks <- stringr::str_locate_all(rootFolders$Schema, "SelectedSchema")

x=1
while (x <= nrow(locate_pks[[1]])) {
  end <- locate_pks[[1]][x]
  
  # change schema for certain situations (VGSOnline server)
  if (is.na(end)) {
    end <- locate_pks[[2]][x]
    rootPK <- Convert2Hex(substr(rootFolders$Schema, end+17, end+52)[2])
  } else {
    # follow normal conversion
    rootPK <- Convert2Hex(substr(rootFolders$Schema, end+17, end+52)[1])
  }
  
  dbExecute(mydb, paste0("Update SiteClass
          Set CK_ParentClass = X'11111111111111111111111111111111' 
          Where PK_SiteClass = ",rootPK))
  x=x+1
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.contactLinks)
if (result > 0) {
  shinyjs::alert("✅ Contact Links moved to local!")
} else {
  shinyjs::alert("⚠️ No Contact Links found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.sample)
if (result > 0) {
  shinyjs::alert("✅ Sample Data moved to local!")
} else {
  shinyjs::alert("⚠️ No Sample Data found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.events)
if (result > 0) {
  shinyjs::alert("✅ Events moved to local!")
} else {
  shinyjs::alert("⚠️ No Events found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.eventGroups)
if (result > 0) {
  shinyjs::alert("✅ Event Groups moved to local!")
} else {
  shinyjs::alert("⚠️ No Event Groups found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.protocol)
if (result > 0) {
  shinyjs::alert("✅ Protocols moved to local!")
} else {
  shinyjs::alert("⚠️ No Protocols found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.site)
if (result > 0) {
  shinyjs::alert("✅ Sites moved to local!")
} else {
  shinyjs::alert("⚠️ No Sites found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.siteClass)
if (result > 0) {
  shinyjs::alert("✅ Folders moved to local!")
} else {
  shinyjs::alert("⚠️ No Folders found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.siteClassLinks)
if (result > 0) {
  shinyjs::alert("✅ Folder Links moved to local!")
} else {
  shinyjs::alert("⚠️ No Folder Links found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.inquiryDatum)
if (result > 0) {
  shinyjs::alert("✅ Survey Data moved to local!")
} else {
  shinyjs::alert("⚠️ No Inquiry Data found.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, updateToLocal.inquiry)
if (result > 0) {
  shinyjs::alert("✅ Surveys moved to local!")
} else {
  shinyjs::alert("⚠️ No Surveys found.")
}
Sys.sleep(0.5)

shinyjs::alert("✨ Complete! ☑") 
