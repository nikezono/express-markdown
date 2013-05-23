###
@title  ページ名。unique
@folder 親フォルダ
@html   コンパイル済み
@text   未コンパイルMarkdown
@view   いつ見られたか
  @user   username、デフォルト値はanonymous
  @date   Date.now()
###

path = require 'path'
Mongo = require 'mongoose'

md_extend = require path.resolve 'lib','marked_extend'

MarkdownSchema = new Mongo.Schema
  title: { type: String, index: yes }
  folder: { type: Mongo.Schema.Types.ObjectId, ref: 'folder' }
  html: { type: String, default: '' }
  thumbnail: { type: String, default: '/img/default.jpg'}
  text: { type: String, default: '' }
  update_id: { type: String, default: '' }
  created: { type: Date, default: Date.now() }
  updated: { type: Date, default: Date.now() }
  meta:
    votes: {type: Number, default: 0}
    favs: {type: Number, default: 0}

MarkdownSchema.statics.findByTitle  = (folder, title, done) ->
  @findOne { folder: folderid, title: title }, {}, { populate: 'Folder' }, (err, article) ->
    console.error err if err
    done err, article

#
# productionだと実行されない devだと実行される
MarkdownSchema.pre 'save', (done)->
  console.log "fook"
  md_extend.tohtml @text, (html) ->
    @html = html
    @updated = Date.now()
    done()

exports.Markdown = Mongo.model 'Markdown', MarkdownSchema