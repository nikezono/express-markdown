###
@title  [String] フォルダ名(unique)
@markeds  [Array] MarkdownModelのObjectId
@checked     [Date]     フォルダが存在するかチェックされた日時
###

Mongo = require 'mongoose'

FolderSchema = new Mongo.Schema
  title: { type: String, unique: yes, index: yes }
  markeds: [{ type: Mongo.Schema.Types.ObjectId, ref: 'Markdown' }]
  checked: { type:Date }

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
