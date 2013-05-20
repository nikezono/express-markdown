###

  diwatcher
  ディレクトリとレコードを同期させる

  init: 初期化メソッド 全フォルダを探索して、FindAndUpdateする。存在しないレコードをDeleteする。.
    @root watchするルートディレクトリ(絶対パスに展開済み)
    @callback コールバック
      @dir_list [Array] ディレクトリのリスト（絶対パス)。watchに使う
        ex: [/hoge/Works, /hoge/Hide]

  update: 更新メソッド updatedのみ更新する。１ファイルにのみ反映される
    @root watchするルートディレクトリ(絶対パス)
    @filename 更新されたファイル名

###
path = require 'path'
async = require 'async'
fs = require 'fs'
mongoose = require 'mongoose'
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
      console.info "root folder is created:#{root_folder.title}"
      console.error err if err

      #Rootにレコード追加
      fs.readdir root, (err,paths) ->
        async.forEach paths, (val,cb) ->
          # if Markdown
          if path.extname(val) is ".md"
            console.log "#{root}/#{val} is updating"
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
            ,(err,article)->
              #callback
              console.error err if err
              console.log "article #{article.title} is created: "+ article.text.slice(0,10) + "..." if article
              cb()

          # directory
          else if fs.statSync(path.join(root,val)).isDirectory()
            console.log "#{root}/#{val} is updating"
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
              console.log "folder #{folder.title} is created"
              dir_list.push val
              cb()

          # other ext file
          else
            cb()
        , ->
          console.info "All root/* is created"
          # 全ディレクトリに対して探索&レコード作成
          find_markdowns root,dir_list,update_id, ->
            console.log "remove all 'not' referenced record"
            #レコードの探索が終わったら、現在のupdate_idを持たないレコードを削除
            Markdown.find
              update_id:
                $ne:update_id
            ,(err,markdowns)->
              console.log "deleted Markdown:#{markdowns}"
            Markdown.remove
              update_id:
                $ne:update_id
            ,->

            Folder.find
              update_id:
                $ne:update_id
            ,(err,folders)->
              console.log "deleted Folder:#{folders}"

            Folder.remove
              update_id:
                $ne:update_id
            ,->

          #コールバック
          callback dir_list

find_markdowns = (root,array,update_id,callback) ->
  async.forEach array, (dir,cb) ->
    console.log "#{dir}/* is updating..."
    Folder.findOne  { title: dir },(err,folder)->
      console.error err if err
      console.log "direcotry '#{root}/#{folder.title}' updating"
      fs.readdir path.resolve(root, dir), (err,paths)->
        console.error err if err
        async.forEach paths, (article_path,_cb) ->
          console.log "#{root}/#{dir}/#{article_path} is updating..."
          Markdown.findOneAndUpdate
            #condition
            title:article_path
            folder: folder.id
          , #update
            title:article_path
            folder: folder.id
            update_id: update_id
            text: fs.readFileSync(path.resolve(root,dir,article_path))
          , #options
            upsert:true
          ,(err,markdown)->
            console.error err if err
            console.log "article #{dir}/#{article_path} is created: "+ markdown.text.slice(0,10) + "..." if markdown
            _cb()
        , ->
          cb()
  ,->
    console.info "All markdowns is created"
    callback()
