const {app,BrowserWindow}=require('electron');
const path=require('path');
const sqlite3=require('sqlite3').verbose();
const {spawn}=require('child_process');
const fs=require('fs');
const http=require('http');

let mainWindow;
let rProcess;

// Prevent multiple instances
const gotTheLock=app.requestSingleInstanceLock();
if(!gotTheLock) {
  app.quit();
} else {
  app.on('second-instance',() => {
    if(mainWindow) {
      if(mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
    }
  });

  app.on('ready',() => {
    // Generate dynamic port
    const port=Math.floor(4000+Math.random()*1000);

    // Paths
    const programDataPath=path.join(process.env.PROGRAMDATA,"VGSData");
    const dbPath=path.join(programDataPath,"VGS50.db");
    const execPath=path.join(app.getAppPath(),"R-Portable","App","R-Portable","bin","Rscript.exe").replace(/\\/g,"/");
    const appPath=path.join(app.getAppPath(),"app.R").replace(/\\/g,"/");

    // Ensure ProgramData exists
    if(!fs.existsSync(programDataPath)) {
      fs.mkdirSync(programDataPath,{recursive: true});
    }

    // Verify R exists
    if(!fs.existsSync(execPath)) {
      console.error(`R Portable not found at ${execPath}`);
      process.exit(1);
    }

    // Launch R Shiny
    rProcess=spawn(execPath,["-e",`shiny::runApp(file.path('${appPath}'), port=${port})`]);

    rProcess.stdout.on('data',(data) => {
      console.log(`Shiny Output: ${data}`);
    });

    rProcess.stderr.on('data',(data) => {
      console.error(`Shiny Error: ${data}`);
    });

    // Connect SQLite
    let db=new sqlite3.Database(dbPath,(err) => {
      if(err) {
        console.error('DB Error:',err.message);
      } else {
        console.log('Connected to DB at:',dbPath);
      }
    });

    // Wait for shiny app
    function waitForShiny(port,callback) {
      const interval=setInterval(() => {
        http.get(`http://127.0.0.1:${port}/`,(res) => {
          if(res.statusCode===200) {
            clearInterval(interval);
            callback();
          }
        }).on('error',() => {
          // Still waiting...
        });
      },500);
    }

    // Create window
    waitForShiny(port,() => {
      console.log('Shiny app is ready.');
      mainWindow=new BrowserWindow({width: 1200,height: 800});
      mainWindow.loadURL(`http://127.0.0.1:${port}/`);
    });

    // kill db connection and R process on exit
    app.on('before-quit',() => {
      if(rProcess) rProcess.kill();
      if(db) {
        db.close((err) => {
          if(err) console.error('DB close error:',err.message);
          else console.log('DB closed.');
        });
      }
    });

    app.on('window-all-closed',() => {
      if(process.platform!=='darwin') {
        app.quit();
      }
    });
  });
}