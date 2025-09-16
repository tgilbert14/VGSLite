# Clean out orphan data

result <- dbExecute(mydb, clear.orphan.siteClass)
if (result > 0) {
  shinyjs::alert("✅ Cleaned SiteClassLink orphans!")
} else {
  shinyjs::alert("⚠️ No orphan'd SiteClassLinks.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.orphan.protocol)
if (result > 0) {
  shinyjs::alert("✅ Cleaned Protocol orphans!")
} else {
  shinyjs::alert("⚠️ No orphan'd Protocols.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.orphan.typeList)
if (result > 0) {
  shinyjs::alert("✅ Cleaned unused Protocols in TypeList!")
} else {
  shinyjs::alert("⚠️ All Protocols in TypeList being used.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.orphan.contactLink)
if (result > 0) {
  shinyjs::alert("✅ Cleaned ContactLink orphans!")
} else {
  shinyjs::alert("⚠️ No orphan'd ContactLinks.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.orphan.contact)
if (result > 0) {
  shinyjs::alert("✅ Cleaned unused Contacts!")
} else {
  shinyjs::alert("⚠️ All Contacts being used.")
}
Sys.sleep(0.5)

shinyjs::alert("✨ Complete! ☑") 
