# empty everything in the tombstone table (deletion cache)

result <- dbExecute(mydb, clear.tombstone)
if (result > 0) {
  shinyjs::alert("✅ Tombstone cleared successfully!")
} else {
  shinyjs::alert("⚠️ Tombstone records are empty.")
}
Sys.sleep(0.5)

shinyjs::alert("✨ Complete! ☑") 