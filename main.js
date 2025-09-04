const {app,BrowserWindow}=require('electron');
const path=require('path');
const sqlite3=require('sqlite3').verbose();
const {spawn}=require('child_process');
const fs=require('fs');

// Generate a dynamic port between 4000–4999
const port=Math.floor(4000+Math.random()*1000);

// Define ProgramData path for database storage
const programDataPath=path.join(process.env.PROGRAMDATA,"VGSData");
const dbPath=path.join(programDataPath,"VGS50.db");

// Ensure ProgramData directory exists
if(!fs.existsSync(programDataPath)) {
  fs.mkdirSync(programDataPath,{recursive: true});
}

// Verify R Portable exists
let execPath=path.join(app.getAppPath(),"R-Portable","App","R-Portable","bin","Rscript.exe").replace(/\\/g,"/");
let appPath=path.join(app.getAppPath(),"app.R").replace(/\\/g,"/");

if(!fs.existsSync(execPath)) {
  console.error(`R Portable not found at ${execPath}. Ensure it's bundled with the app.`);
  process.exit(1);
}

// Launch Shiny App
const childProcess=spawn(execPath,["-e",`shiny::runApp(file.path('${appPath}'), port=${port})`]);

childProcess.stdout.on('data',(data) => {
  console.log(`Shiny App Output: ${data}`);
});

childProcess.stderr.on('data',(data) => {
  console.error(`Error running R Script: ${data}`);
});

// Connect SQLite database
let db=new sqlite3.Database(dbPath,(err) => {
  if(err) {
    console.error('Error opening database:',err.message);
  } else {
    console.log('Connected to SQLite database at:',dbPath);
  }
});

// Launch Electron Window
let mainWindow;
app.on('ready',() => {
  mainWindow=new BrowserWindow({width: 1200,height: 800});
  mainWindow.loadURL(`http://127.0.0.1:${port}/`);
});

app.on('window-all-closed',() => {
  if(db) {
    db.close((err) => {
      if(err) {
        console.error('Error closing database:',err.message);
      } else {
        console.log('SQLite database connection closed.');
      }
    });
  }
  if(process.platform!=='darwin') {
    app.quit();
  }
});