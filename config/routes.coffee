###

Router

###

async = require 'async'
path = require 'path'
fs = require 'fs'

Folder = (require (path.resolve('models','Folder'))).Folder
Markdown = (require (path.resolve('models','Markdown'))).Markdown
typer = require path.resolve 'helper', 'typer'

module.exports = (app,root) ->

  # index
  app.get '/', (req,res,next) ->
    getArticle 'root',null, (results)->
      res.render 'index',
        title: app.get("app_name")
        markdown:results[0]
        nav:results[1]

  # Folder or Article
  app.get '/:folder', (req,res,next) ->

    res.render 'list'

  # Article
  app.get '/:folder/:filename', (req,res,next) ->
    getArticle req.params.folder,req.params.filename,(results)->
      res.render 'index',
        title: app.get("app_name")
        markdown:results[0]
        nav:results[1]


getArticle = (folder,filename,callback)->
  async.parallel [(cb)->
    findArticle folder,filename,(markdown)->
      cb(null,markdown)
  ,(cb)->
    findNavigation process.env.WATCH_DIR, (nav)->
      cb(null,nav)
  ],(err,results)->
    console.log results
    callback results

getList = ()->

findArticle = (foldername,filename,callback) ->
    #ルートディレクトリを取得
  Folder.findOne {title:foldername},(err,root_folder)->
    #記事を取得
    Markdown.findOne
      title: filename || root_folder.index
      folder:root_folder.id
    ,(err,markdown)->
      callback markdown

findList = (foldername,callback) ->
  folder_path = path.resolve(app.get("watch_dir"),foldername)
  if fs.statSync(folder_path).isDirectory()
    console.log "aaa"
  else if fs.statSync(folder_path).isFile() and path.extname(folder_path) is '.md'
    console.log "bbb"

findNavigation = (root_dir,callback) ->
  nav = []
  async.parallel [(cb)->
    Folder.find {title:{$ne:'root'}},(err,fds)->
      console.error err if err
      async.forEach fds, (fd,_cb)->
        nav.push fd.title
        _cb()
      ,->
        cb(null,null)
  ,(cb)->
    Folder.findOne {title:'root'},(err,folder)->
      Markdown.find {folder:folder.id},(err,mds)->
        async.forEach mds, (md,_cb)->
          nav.push md.title
          _cb()
        ,->
          cb(null,null)
  ],->
    callback nav
