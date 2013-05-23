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

helper = require path.resolve('helper', 'typer')
md_extend = require path.resolve('lib', 'marked_extend')
Folder = (require (path.resolve('models','Folder'))).Folder
Markdown = (require (path.resolve('models','Markdown'))).Markdown

exports.watch = (root_dir,dbname) ->

  watcher = chokidar.watch root_dir#,
   # ignored:

  # Event
  # chokidarではなぜかFolderのAddだけ取れない.
  # MarkdownがAddされたとき、FolderをfindOneAndUpdateする.

  watcher.on 'add', (article_path)->
    console.info "#{article_path} is added"
    basename = path.basename(article_path,".md")
    dirname = (path.dirname(article_path).split(path.sep))[1] || 'root'
    #Markdownファイルの追加時にFolderもFindAndUpdate(upsert)
    if helper.isMarkdown(article_path)
      Folder.findOneAndUpdate {title: dirname},{title: dirname},{upsert: true}, (err,folder)->
        console.log "Folder #{folder.title} is updated"
        md_update folder,basename,article_path

    else if helper.isImage(article_path)
      basename = path.basename(article_path,path.extname(article_path))
      Folder.findOneAndUpdate {title: dirname},{title: dirname},{upsert: true}, (err,folder)->
        console.log "Folder #{folder.title} is updated"
        if folder.title is 'root'
          fdname = ''
        else
          fdname = folder.title
        Markdown.findOne {title:basename,folder:folder.id}, (err,md)->
          console.error err if err
          md_update folder,basename,path.normalize("#{root_dir}/#{fdname}/#{basename}.md") if md

  watcher.on 'change', (article_path)->
    console.info "#{article_path} is changed"
    basename = path.basename(article_path,".md")
    dirname = (path.dirname(article_path).split(path.sep))[1] || 'root'
    #changeイベントはファイルにしか発生しない
    if helper.isMarkdown(article_path)
      Folder.findOne {title: dirname}, (err,folder)->
        console.error err if err
        md_update folder,basename,article_path
    if helper.isImage(article_path)
      basename = path.basename(article_path,path.extname(article_path))
      Folder.findOneAndUpdate {title: dirname},{title: dirname},{upsert: true}, (err,folder)->
        console.log "Folder #{folder.title} is updated"
        if folder.title is 'root'
          fdname = ''
        else
          fdname = folder.title
        Markdown.findOne {title:basename,folder:folder.id}, (err,md)->
          console.error err if err
          md_update folder,basename,path.normalize("#{root_dir}/#{fdname}/#{basename}.md") if md

  #@TODO ファイルではなくレコードから削除されたレコードを検出
  watcher.on 'unlink', (article_path)->
    console.info "#{article_path} is unlinked."
    extname = path.extname(article_path)
    basename = path.basename(article_path,".md")
    dirname = (path.dirname(article_path).split(path.sep))[1] || 'root'

    event_type = 'file_deleted' if extname is '.md'
    event_type = 'folder_deleted' if extname is ''
    event_type = 'image_deleted' if helper.isImage(article_path)

    console.log "ext:#{extname} base:#{basename} dir:#{dirname}. event_type: #{event_type}"

    Folder.findOne {title:dirname}, (err,folder)->
      console.error err if err
      if event_type is 'file_deleted'
        Markdown.findOne {title:basename,folder:folder.id},(err,md)->
          console.error err if err
          console.log "Markdown #{folder.title}/#{md.title} is deleted."
          md.remove()

      else if event_type is 'folder_deleted'
        Folder.findOne {title:basename},(err,fd)->
          console.error err if err
          if fd
            Markdown.find {folder:fd.id}, (err,mds)->
              async.forEach mds,(md,cb)->
                console.log "Markdown #{folder.title}/#{md.title} is deleted."
                md.remove()
                cb()
              ,->
                console.log "Folder #{folder.title}/#{fd.title} is deleted."
                fd.remove()
      else if event_type is 'image_deleted'
        basename = path.basename(article_path,path.extname(article_path))
        Markdown.findOne {title:basename,folder:folder.id},(err,md)->
          console.error err if err
          if md
            console.log "Markdown #{folder.title}/#{md.title}'s image file is deleted."
            if folder.title is 'root'
              fdname = ''
            else
              fdname = folder.title
            md_update folder,basename,path.normalize("#{root_dir}/#{fdname}/#{md.title}.md")
      else
        console.log "#{article_path}'s unlink is ignored"

  watcher.on 'error',(err)->
    console.error err

md_update = (folder,basename,article_path)->
  fs.readFile article_path,"utf-8",(err,text)->
    md_extend.tohtml text, (html)->
      helper.articleHasImage article_path,basename,folder.title, (image_path)->
        Markdown.findOne
        #condition
          title: basename
          folder: folder.id
        , (err,md)->
          console.error err if err
          if md
            md.update#update
              title: basename
              folder: folder.id
              text: text
              thumbnail: image_path || '/img/default.jpg'
              updated: Date.now()
              html: html
            ,(err,num,raw)->
              console.error err if err
              console.log "Markdown #{folder.title}/#{md.title} is updated in #{md.updated}"
          else unless err
            Markdown.create
              created: Date.now()
              title: basename
              folder: folder.id
              thumbnail: image_path || '/img/default.jpg'
              text: text
              updated: Date.now()
              html :html
            ,(err,md)->
              console.error err if err
              console.log "Markdown #{folder.title}/#{md.title} is updated in #{md.updated}"