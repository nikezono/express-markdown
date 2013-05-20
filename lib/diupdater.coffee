###

  diupdater
  ディレクトリをwatchして変更があったときにがあったときにレコードを変更する

  @root_dir watchするルートディレクトリ(絶対パスに展開済み)
  @dbname   watchするDBの名前
  @dir_list [Array] ディレクトリのリスト（絶対パス)。
    ex: [/hoge/Works, /hoge/Hide]
  @callback コールバック

###

chokidar = require 'chokidar'
path = require 'path'
async = require 'async'

Folder = (require (path.resolve('models','Folder'))).Folder
Markdown = (require (path.resolve('models','Markdown'))).Markdown

exports.watch = (root_dir,dbname,dir_list) ->

  watcher = chokidar.watch root_dir

  async.forEach dir_list, (val,cb) ->
    watcher.add path.resolve(root_dir,val)
    cb()
  , ->
    #Event
    watcher.on 'add', (path)->
      console.log "#{path} is added"

    watcher.on 'change', (path)->
      console.log "#{path} is changed"

    watcher.on 'unlink', (path)->
      console.log "#{path} is unlinked"

    watcher.on 'error',(err)->
      console.error err