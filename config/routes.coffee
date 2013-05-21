###


###

async = require 'async'
path = require 'path'

module.exports = (app,root) ->

  Markdown = (app.get 'models').Markdown
  Folder = (app.get 'models').Folder

  # index
  app.get '/', (req,res,next) ->
    findArticle 'root', null,(nav,markdown)->
      res.render 'index',
        nav:nav
        markdown:markdown

  # Folder or Article
  app.get '/:folder', (req,res,next) ->

    res.render 'list'

  # Article
  app.get '/:folder/:filename', (req,res,next) ->

    res.render 'article'

findArticle = (foldername,filename,callback)->
      #ルートディレクトリを取得
    Folder.findOne {title:foldername},(err,root_folder)->
      #@TODO
      async.parallel [->
        #記事を取得
        Markdown.findOne
          title: filename || folder.index
          folder:folder.id
        ,(err,markdown)->

      , getNavigation folder.title,(nav)->

      ],(err,results)->
        callback results.nav,results.markdown

findList = (foldername,callback)->
  folder_path = path.resolve(app.get("watch_dir"),foldername)
  if fs.statSync(folder_path).isDirectory()
    console.log "aaa"
  else if fs.statSync(folder_path).isFile() and path.extname(folder_path) is '.md'
    console.log "bbb"

getNavigation = (foldername,callback)->
  Folder.findOne {title:foldername},(err,folder)->
    console.error err if err
    Markdown.find {folder:folder.id},(err,mds)->
      console.error err if err
      callback mds

