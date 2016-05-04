'use strict'
var app = require('app')
var BrowserWindow = require('browser-window')
var electron = require('electron')
var Menu = require("menu")
var ipcMain = electron.ipcMain,
  dialog = electron.dialog,
  fs = require('mz/fs'),
  path = require('path'),
  koa = require('koa'),
  koaBody = require('koa-body'),
  router = require('koa-router')(),
  swig = require('koa-swig'),
  staticServe = require('koa-static-cache'),
  http = require('http'),
  rename = require('fs').renameSync


var mainWindow = null,
  server,
  ipcRenderer

app.on('window-all-closed', function() {
  if (process.platform != 'darwin') {
    app.quit()
  }
  server && server.close()
  server = app = ipcRenderer = null
})

app.on('ready', function() {
  mainWindow = new BrowserWindow({
    width: 1024,
    height: 650,
    minWidth: 1024,
    minHeight: 650,
    center: true
  })

  mainWindow.loadURL('file://' + __dirname + '/dist/index.html')

  mainWindow.on('closed', function() {
    mainWindow = null
  })

  ipcMain.on('server:create', function(evt) {
    var app = koa()
    app.use(koaBody({
      multipart: true,
      formidable: {
        keepExtensions: true,
        hash: 'sha1'
      }
    }))
    app.use(staticServe(path.join(__dirname, 'static'), {
      maxAge: 0
    }))
    app.use(router.routes()).use(router.allowedMethods())
    app.context.render = swig({
      root: path.join(__dirname, 'views'),
      autoescape: true,
      cache: false,
      varControls: ['[[', ']]'],
      ext: 'swig'
    })

    genRouter(router)
    server = http.createServer(app.callback())
    server.listen(0)
    server.on('listening', function() {
      ipcRenderer = evt.sender
      evt.sender.send('server:created', server.address().port)
    })
  })

  ipcMain.on('openFolder', function(evt, filepath) {
    dialog.showSaveDialog({
      title: '另存为...',
      defaultPath: filepath
    }, function(path) {
      if (path) {
        evt.sender.send('getSavedPath', path)
      }
    })
  })



  // https://pracucci.com/atom-electron-enable-copy-and-paste.html
  var template = [{
    label: "Application",
    submenu: [{
      label: "About Application",
      selector: "orderFrontStandardAboutPanel:"
    }, {
      type: "separator"
    }, {
      label: "Quit",
      accelerator: "Command+Q",
      click: function() {
        app.quit()
      }
    }]
  }, {
    label: "Edit",
    submenu: [{
      label: "Undo",
      accelerator: "CmdOrCtrl+Z",
      selector: "undo:"
    }, {
      label: "Redo",
      accelerator: "Shift+CmdOrCtrl+Z",
      selector: "redo:"
    }, {
      type: "separator"
    }, {
      label: "Cut",
      accelerator: "CmdOrCtrl+X",
      selector: "cut:"
    }, {
      label: "Copy",
      accelerator: "CmdOrCtrl+C",
      selector: "copy:"
    }, {
      label: "Paste",
      accelerator: "CmdOrCtrl+V",
      selector: "paste:"
    }, {
      label: "Select All",
      accelerator: "CmdOrCtrl+A",
      selector: "selectAll:"
    }]
  }]

  Menu.setApplicationMenu(Menu.buildFromTemplate(template))
})

function genRouter(router) {
  router.post('/upload', function*() {
    var body = this.request.body
    if (body && body.files) {
      var files = [].concat(body.files.file)
      files.forEach(function(file) {
        var dist = path.join(path.dirname(file.path), file.name)
        rename(file.path, dist)
        file.path = dist
        file.type = path.extname(file.path).replace('.', '')
      })
      ipcRenderer.send('uploaded', files)
      this.body = {
        code: 200
      }
    } else {
      this.throw('file is required', 400)
    }

  })
  router.get('/', function*() {
    yield this.render('index')
  })
}