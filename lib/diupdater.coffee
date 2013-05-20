###

  diupdater
  ディレクトリをwatchして変更があったときにがあったときにレコードを変更する

  @root_dir watchするルートディレクトリ(絶対パスに展開済み)
  @dbname   watchするDBの名前
    ex: [/hoge/Works, /hoge/Hide]
  @callback コールバック

###

chokidar = require 'chokidar'
path  = require 'path'
async = require 'async'
fs = require 'fs'

Folder = (require (path.resolve('models','Folder'))).Folder
Markdown = (require (path.resolve('models','Markdown'))).Markdown

exports.watch = (root_dir,dbname) ->

  watcher = chokidar.watch root_dir

  # Event
  # chokidarではなぜかFolderのAddだけ取れない.
  # MarkdownがAddされたとき、FolderをfindOneAndUpdateする.
  # @TODO 動画と静止画をpublic/に転送する

  watcher.on 'add', (article_path)->
    console.info "#{article_path} is added"
    basename = path.basename(article_path,".md")
    dirname = (path.dirname(article_path).split(path.sep))[1] || 'root'
    if fs.statSync(path.resolve(article_path)).isFile() and path.extname(article_path) is '.md'
      # サブディレクトリ
      if dirname isnt 'root'
        Folder.findOneAndUpdate
          #conditions
          title: dirname
        , #update
          title: dirname
        , #options
          upsert: true
        , (err,folder)->
          md_update folder,basename,article_path
      #ルートディレクトリ
      else
        Folder.findOne
          title:'root'
        ,(err,root_folder)->
          md_update root_folder,basename,article_path


  watcher.on 'change', (article_path)->
    console.info "#{article_path} is changed"

  watcher.on 'unlink', (article_path)->
    console.info "#{article_path} is unlinked"

  watcher.on 'error',(err)->
    console.error err


md_update = (folder,basename,article_path)->
  Markdown.findOneAndUpdate
  #condition
    title: basename
    folder: folder.id
  , #update
    title: basename
    folder: folder.id
    text: fs.readFileSync(article_path)
  , #options
    upsert: true
  ,(err,markdown)->
    console.error err if err
    console.log "Markdown #{folder.title}/#{markdown.title} is created."