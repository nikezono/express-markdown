###

Router

###

async = require 'async'
path = require 'path'
fs = require 'fs'

Folder = (require (path.resolve('models','Folder'))).Folder
Markdown = (require (path.resolve('models','Markdown'))).Markdown
helper = require path.resolve 'helper', 'typer'

module.exports = (app) ->

  root = app.get "watch_dir"

  # index
  app.get '/', (req,res,next) ->
    getArticle 'root',null, (results)->
      res.render 'index',
        title: app.get("app_name")
        markdown:results[0]
        nav:results[1]
        moment: require 'moment'

  # Folder or Article
  app.get '/:folder', (req,res,next) ->
    if helper.isMarkdown(path.resolve(root,req.params.folder+'.md'))
      getArticle 'root',req.params.folder, (results)->
        res.render  'index',
          title: app.get("app_name")
          markdown:results[0]
          nav:results[1]
          moment: require 'moment'

    else if helper.isFolder(path.resolve(root,req.params.folder))
      getList req.params.folder, (results)->
        res.render 'list',
          title: app.get("app_name")
          folder:results.folder
          markdowns:results.markdowns
          nav:results.nav
          moment: require 'moment'

  # Article
  app.get '/:folder/:filename', (req,res,next) ->
    getArticle req.params.folder,req.params.filename,(results)->
      res.render 'index',
        title: app.get("app_name")
        markdown:results[0]
        nav:results[1]
        moment: require 'moment'


getArticle = (folder,filename,callback)->
  async.parallel [(cb)->
    findArticle folder,filename,(markdown)->
      cb(null,markdown)
  ,(cb)->
    findNavigation process.env.WATCH_DIR, (nav)->
      cb(null,nav)
  ],(err,results)->
    callback results

getList = (foldername,callback)->
  results = new Object
  async.parallel [(cb)->
    Folder.findOne {title:foldername},(err,folder)->
      console.error err if err
      results.folder = folder
      Markdown.find {folder:folder.id},(err,mds)->
        console.error err if err
        results.markdowns = mds
        cb(null)
  ,(cb)->
    findNavigation process.env.WATCH_DIR, (nav)->
      results.nav = nav
      cb(null)
  ],(err)->
    console.error err if err
    callback results

findArticle = (foldername,filename,callback) ->
    #ルートディレクトリを取得
  Folder.findOne {title:foldername},(err,root_folder)->
    #記事を取得
    Markdown.findOne
      title: filename || root_folder.index
      folder:root_folder.id
    ,(err,markdown)->
      callback markdown

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
