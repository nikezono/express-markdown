exports.dbhelper = (app) ->
  async = require 'async'
  fs = require 'fs'
  root = app.get "watch_dir"
  Folder = app.get("models").Folder
  Markdown = app.get("models").Markdown
  typer = app.get("helper").typer

  # NavigationとArticleを取得しマージする
  getArticle: (folder,filename,callback)->
    async.parallel [(cb)->
      Folder.findOne {title:folder},(err,root_folder)->
        Markdown.findOne
          title: filename || 'index'
          folder:root_folder.id
        ,(err,markdown)->
          cb(null,markdown)
    ,(cb)->
      typer.sliceMarkdownAndFolder fs.readdirSync(root),(nav)->
        cb(null,nav)
    ],(err,results)->
      callback results[0],results[1]

  getList: (foldername,callback)->
    results = new Object
    async.parallel [(cb)->
      Folder.findOne {title:foldername},(err,folder)->
        results.folder = folder
        Markdown.find {folder:folder.id},(err,mds)->
          results.markdowns = mds
          cb(null)
    ,(cb)->
      typer.sliceMarkdownAndFolder fs.readdirSync(root),(nav)->
        results.nav = nav
        cb(null)
    ],(err)->
      callback results.folder,results.markdowns,results.nav
