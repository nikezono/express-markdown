fs = require 'fs'
path = require 'path'
async = require 'async'
{exec} = require 'child_process'
assert = require 'assert'
request = require 'supertest'

# @TODO
#process.env.WATCH_DIR = path.resolve 'test', 'assets'
# Blog_dirがどこでも動く

app = require path.resolve 'config', 'app'
root = app.get 'watch_dir'
helper = require path.resolve 'helper','typer'
updater = require(path.resolve('lib','diupdater'))
Folder = (require (path.resolve('models','Folder'))).Folder
Markdown = (require (path.resolve('models','Markdown'))).Markdown

appendTestFiles = (cb)->
  fs.appendFileSync path.resolve(root,"test1.txt"), "test text"
  fs.appendFileSync path.resolve(root,"test2.md"), "### header"
  fs.mkdirSync path.resolve(root, "Test")
  cb() if cb

changeTestFiles = (cb)->
  fs.writeFileSync path.resolve(root,"test1.txt"), "test text"
  fs.writeFileSync path.resolve(root,"test2.md"), "### header"
  cb() if cb

deleteTestFiles = (cb)->
  fs.unlinkSync path.resolve(root,"test1.txt")
  fs.unlinkSync path.resolve(root,"test2.md")
  fs.rmdirSync path.resolve(root, "Test")
  cb() if cb

describe 'Test Environment', ->
  before ->
    updater.watch app.get("watch_dir")
  it 'should work', (done) ->
    console.log app.get("watch_dir")+" is testing directory"
    done null, yes

describe "結合テスト:ルーティング", ->

  describe "トップページ", ->
    it "ステータス:200", (done)->
      request(app).get('/').expect(200,done)

    it "index.mdのhtmlが表示されている",(done)->
      request(app).get('/').expect(/index.md/,done)

    it "メニューにmdファイルとディレクトリが表示されている",(done)->
      list = fs.readdirSync path.resolve(root)
      helper.sliceMarkdownAndFolder root,list, (mdAndFolder)->
        request(app).get('/').expect(new RegExp(mdAndFolder[0])).expect(new RegExp(mdAndFolder[1]),done)

  describe "リストページ", ->
    it "ステータス:200", (done)->
      request(app).get('/Works').expect(200,done)

    it "リストのhtmlが表示されている", (done)->
      request(app).get('/Works').expect(/moge/,done)

    it "記事のビュー数が表示されている",(done)->
      request(app).get('/Works').expect(/views/,done)

    it "ビュー数が増加する", (done)->
      Markdown.findOne {title:'moge'}, (err,md)->
        views = md.meta.views
        request(app).get('/Works/moge').end (err,res)->
          request(app).get('/Works').expect(new RegExp(views+1+' views'),done)

    it "サムネイル画像が表示されている",(done)->
      Markdown.findOne {title:'moge'},(err,md)->
        request(app).get('/Works').expect(new RegExp('<img src="'+md.thumbnail+'">'),done)

  describe "記事ページ", ->

    it "ステータス:200", (done)->
      request(app).get('/Works/moge').expect(200)
      done null,yes

    it "記事の本文のhtmlが表示されている",(done)->
      request(app).get('/Works/moge').expect(/moge.md/,done)

describe "単体テスト:ディレクトリ監視", ->

  describe "新規ファイル作成", ->
    before ->
      appendTestFiles ->
        setTimeout ->
          console.log "settimeout 2000ms for updater"
        ,2000
    after ->
      deleteTestFiles()

    it "Markdownか画像ファイル以外を無視する",(done)->
      Markdown.findOne {title:"test1"}, (err,md)->
        done(null,yes) if md is null

    it "データベースが更新される",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        done(null,yes) if md

    it "markdownコンバートされている",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        done(null,yes) if md.html is '<h3>header</h3>\n'

    it "updated_atが更新されている",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        updated = md.updated
        fs.writeFileSync path.resolve(root,"test2.md"), "### header"
        Markdown.findOne {title:"test2"},(err,md) ->
          done(null,yes) if updated isnt md.updated

    it "フォルダとのリレーションが設定されている",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        Folder.findOne {title:'root'},(err,root_f)->
          done(null,yes) if md.folder.toString() is root_f._id.toString()

  describe "ファイル更新", ->
    before ->
      appendTestFiles ->
        changeTestFiles ->
          setTimeout ->
            console.log "settimeout 2000ms for updater"
          ,2000
    after ->
      deleteTestFiles()

    it "Markdownか画像ファイル以外を無視する",(done)->
      Markdown.findOne {title:"test1"}, (err,md)->
        done(null,yes) if md is null

    it "データベースが更新される",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        done(null,yes) if md isnt null

    it "markdownコンバートされている",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        done(null,yes) if md.html is '<h3>header</h3>\n'

    it "updated_atが更新されている",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        updated = md.updated
        fs.writeFileSync path.resolve(root,"test2.md"), "### header"
        Markdown.findOne {title:"test2"},(err,md) ->
          done(null,yes) if updated isnt md.updated

    it "フォルダとのリレーションが設定されている",(done)->
      Markdown.findOne {title:"test2"},(err,md) ->
        Folder.findOne {title:'root'},(err,root_f)->
          done(null,yes) if md.folder.toString() is root_f._id.toString()


  describe "ファイル削除", ->
    before ->
      appendTestFiles ->
        setTimeout ->
          console.log "settimeout 2000ms for updater"
        ,2000
    after ->
      deleteTestFiles()

    it "Markdownか画像ファイル以外を無視する",(done)->
      fs.unlinkSync path.resolve(root,"test1.txt")
      Markdown.findOne {title:"test1"},(err,md) ->
        done(null,yes) if md is null
    it "データベースが更新される",(done)->
      fs.unlinkSync path.resolve(root,"test2.md")
      Markdown.findOne {title:"test2"},(err,md) ->
        console.log md
        done(null,yes) if md is null
