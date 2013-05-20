###

  diwatcher
  ディレクトリとレコードを同期させる

  init: 初期化メソッド 全フォルダを探索して、FindAndUpdateする。存在しないレコードをDeleteする。.
    @root watchするルートディレクトリ(絶対パスに展開済み)
    @callback コールバック
      @dir_list [Array] ディレクトリのリスト（絶対パス)。watchに使う
        ex: [/hoge/Works, /hoge/Hide]

###
path = require 'path'
async = require 'async'
fs = require 'fs'
uuid = require 'node-uuid'

Folder = (require (path.resolve('models','Folder'))).Folder
Markdown = (require (path.resolve('models','Markdown'))).Markdown

exports.init = (root,dbname,callback)->
  console.log "WATCH DIR :#{root}"
  console.log "DB NAME: #{dbname}"

  #このUpdateのuuidを生成
  update_id = uuid.v4()
  console.log "update uuid : #{update_id}"

  #watchするディレクトリのリスト
  dir_list = []

  #Root作成
  Folder.findOneAndUpdate
    #condition
    title: 'root'
  , #update
    title: 'root'
    update_id: update_id
  , #option
    upsert:true
  ,(err,root_folder)->
      console.error err if err
      console.info "Folder #{root_folder.title} is created. "
      console.info "#{root_folder.title}/* is updating..."

      #Rootにレコード追加
      fs.readdir root, (err,paths) ->
        async.forEach paths, (val,cb) ->
          # if Markdown
          if path.extname(val) is ".md"
            md_title = path.basename(val, ".md")
            Markdown.findOneAndUpdate
              #condition
              title: md_title
              folder: root_folder.id
            , #Update
              title: md_title
              folder: root_folder.id
              update_id: update_id
              text: fs.readFileSync(path.join(root,val))
            , #Options
              upsert: true
            ,(err,markdown)->
              #callback
              console.error err if err
              console.log "Markdown #{markdown.title} is created. text: "+ markdown.text.slice(0,10) + "..." if markdown
              cb()

          # directory
          else if fs.statSync(path.join(root,val)).isDirectory() and path.join(root,val) isnt '.DS_Store'
            Folder.findOneAndUpdate
              #condition
              title: val
            , #update
              update_id: update_id
              title: val
            , #options
              upsert: true
            ,(err,folder)->
              console.error err if err
              console.log "Folder #{folder.title} is created."
              dir_list.push val
              cb()

          # other ext file
          else
            cb()
        , ->
          console.info "All root/* Record is created."
          # 全ディレクトリに対して探索&レコード作成
          find_markdowns root,dir_list,update_id, ->
            console.log "Remove all 'not' referenced record"
            #レコードの探索が終わったら、現在のupdate_idを持たないレコードを削除
            Markdown.find
              update_id:
                $ne:update_id
            ,(err,markdowns)->
              async.forEach markdowns,(md,cb)->
                console.log "Markdown #{md.title} is deleted."
                cb()
              ,->
            Markdown.remove
              update_id:
                $ne:update_id
            ,(err)->
              console.error err if err

            Folder.find
              update_id:
                $ne:update_id
            ,(err,folders)->
              async.forEach folders,(fd,cb)->
                console.log "Folder #{fd.title} is deleted."
                cb()
              ,->

            Folder.remove
              update_id:
                $ne:update_id
            ,(err)->
              console.error err if err

          #コールバック
          callback dir_list

find_markdowns = (root,array,update_id,callback) ->
  async.forEach array, (dir,cb) ->
    console.log "#{dir}/* is updating..."
    Folder.findOne  { title: dir },(err,folder)->
      console.error err if err
      fs.readdir path.resolve(root, dir), (err,paths)->
        console.error err if err
        async.forEach paths, (article_path,_cb) ->
          if fs.statSync(path.join(root,folder.title,article_path)).isFile and path.extname(article_path) is '.md'
            md_title = path.basename(article_path, ".md")
            Markdown.findOneAndUpdate
              #condition
              title: md_title
              folder: folder.id
            , #update
              title: md_title
              folder: folder.id
              update_id: update_id
              text: fs.readFileSync(path.resolve(root,dir,article_path))
            , #options
              upsert:true
            ,(err,markdown)->
              console.error err if err
              console.log "Markdown #{markdown.title} is created. text:"+ markdown.text.slice(0,10) + "..." if markdown
              _cb()
          else
            console.log "#{article_path} is ignored"
        , ->
          cb()
  ,->
    console.info "All markdowns is created"
    callback()
