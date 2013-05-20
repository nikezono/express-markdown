###
@title  フォルダ名。再帰的探索しないためunique
@index  インデックスとして評価するページ名
@markeds  MarkdownModelのObjectId
###

Mongo = require 'mongoose'

FolderSchema = new Mongo.Schema
  title: { type: String, unique: yes, index: yes }
  index: { type: String, default: 'index' }
  update_id: { type: String, default: '' }
  markeds: [{ type: Mongo.Schema.Types.ObjectId, ref: 'Markdown' }]

FolderSchema.statics.findByTitle = (title, done) ->
  @findOne title: title, {}, {}, (err, repo) ->
    console.error err if err
    return done err, folder

FolderSchema.statics.findMarkdownByTitle = (title, done) ->
  ###
  @TODO
  ###

FolderSchema.statics.findAllMarkdown = (done) ->
  @find {}, {}, {}, (err,markdowns)->
    return (done err, null) unless markdowns
    done null, markdowns

exports.Folder = Mongo.model 'Folder', FolderSchema
