###
@title       [String]   ページ名
@folder      [ObjectId] 親フォルダ(id)
@text        [String]   ファイル内容(markdown)
@html        [String]   コンパイル済みhtml
@thumbnail   [String]   サムネイル(アドレス)
@updated     [Date]     更新日時
@created     [Date]     作成日時
@checked     [Date]     ファイルが存在するかチェックされた日時
@meta
  @views     閲覧回数
###

path = require 'path'
Mongo = require 'mongoose'

MarkdownSchema = new Mongo.Schema
  title: { type: String, index: yes }
  folder: { type: Mongo.Schema.Types.ObjectId, ref: 'folder' }
  text: { type: String, default: '' }
  html: { type: String, default: '' }
  thumbnail: { type: String, default: '/img/default.jpg'}
  created: { type: Date, default: Date.now() }
  updated: { type: Date, default: Date.now() }
  checked: { type:Date }
  meta:
    views: {type: Number, default: 0}

MarkdownSchema.statics.findByTitle  = (folder, title, done) ->
  @findOne { folder: folderid, title: title }, {}, { populate: 'Folder' }, (err, article) ->
    console.error err if err
    done err, article


exports.Markdown = Mongo.model 'Markdown', MarkdownSchema