# Deleting everything in unassigned folder

result <- dbExecute(mydb, clear.unassigned.sample)
if (result > 0) {
  shinyjs::alert("✅ Unassigned sample data cleared successfully!")
} else {
  shinyjs::alert("⚠️ No unassigned sample data.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.unassigned.inq)
if (result > 0) {
  shinyjs::alert("✅ Unassigned inquiry data cleared successfully!")
} else {
  shinyjs::alert("⚠️ No unassigned inquiry data.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.unassigned.event)
if (result > 0) {
  shinyjs::alert("✅ Unassigned events cleared successfully!")
} else {
  shinyjs::alert("⚠️ No unassigned events.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.unassigned.eventGroup)
if (result > 0) {
  shinyjs::alert("✅ Unassigned inquiry cleared successfully!")
} else {
  shinyjs::alert("⚠️ No unassigned event groups.")
}
Sys.sleep(0.5)

result <- dbExecute(mydb, clear.unassigned.site)
if (result > 0) {
  shinyjs::alert("✅ Unassigned sites cleared successfully!")
} else {
  shinyjs::alert("⚠️ No unassigned sites.")
}
Sys.sleep(0.5)

shinyjs::alert("✨ Complete! ☑")  
