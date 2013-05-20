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

  watcher = chokidar.watch root_dir#,
   # ignored:

  # Event
  # chokidarではなぜかFolderのAddだけ取れない.
  # MarkdownがAddされたとき、FolderをfindOneAndUpdateする.
  # @TODO 動画と静止画をpublic/に転送する

  watcher.on 'add', (article_path)->
    console.info "#{article_path} is added"
    basename = path.basename(article_path,".md")
    dirname = (path.dirname(article_path).split(path.sep))[1] || 'root'
    #Markdownファイルの追加時にFolderもFindAndUpdate(upsert)
    if fs.statSync(article_path).isFile() and path.extname(article_path) is '.md'
      Folder.findOneAndUpdate {title: dirname},{title: dirname},{upsert: true}, (err,folder)->
        console.log "Folder #{folder.title} is updated"
        md_update folder,basename,article_path

  watcher.on 'change', (article_path)->
    console.info "#{article_path} is changed"
    basename = path.basename(article_path,".md")
    dirname = (path.dirname(article_path).split(path.sep))[1] || 'root'
    #changeイベントはファイルにしか発生しない
    if path.extname(article_path) is '.md'
      Folder.findOne {title: dirname}, (err,folder)->
        console.error err if err
        md_update folder,basename,article_path

  #@TODO ファイルではなくレコードから削除されたレコードを検出
  watcher.on 'unlink', (article_path)->
    console.info "#{article_path} is unlinked."
    basename = path.basename(article_path,".md")
    dirname = (path.dirname(article_path).split(path.sep))[1] || 'root'

    Folder.findOne {title:dirname}, (err,folder)->
      console.error err if err
      if event_type is 'file_changed'
        Markdown.remove {title:basename,folder:folder.id},(err)->
          console.error err if err

      else if event_type is 'folder_changed' and dirname isnt 'root'
        Markdown.remove {folder:folder.id},(err)->
          console.error err if err
          Folder.remove {title:dirname},(err)->
            console.error err if err

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
    console.log "Markdown #{folder.title}/#{markdown.title} is updated."