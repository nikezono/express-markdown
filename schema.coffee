mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

mongoose.connect "mongodb://localhost/express-markdown"

MarkdownSchema = new Schema
  name: String
  path:
    type: String
    unique: true #一意性制約かけて問題あるだろうか
  text: String
  data: Date
  folder:
    type: ObjectId
    ref: FolderSchema

Markdown = mongoose.model "Markdown", MarkdownSchema


module.exports.markdown = Markdown

FolderSchema = new Schema
  name:
  	type: String
  	unique: true #階層構造ではないため一意性制約
  md: [
    type: ObjectId
    ref: MarkdownSchema
  ]


Folder = mongoose.model "Folder", FolderSchema

module.exports.folder = Folder