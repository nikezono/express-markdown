###

typer
ファイルタイプの判定を行う
ファイルタイプに応じたArrayのパースも行う

###

path = require 'path'
fs = require 'fs'
async = require 'async'
root = process.env.WATCH_DIR

isMarkdown = (target_path)->
  try
    return (fs.statSync(target_path).isFile() and path.extname(target_path) is '.md')
  catch error
    return false

isFolder = (target_path)->
  try
    return (fs.statSync(target_path).isDirectory() and path.extname(target_path) is '')
  catch error
    return false

isImage = (target_path)->
  try
    p = path.extname(target_path)
    return (p is '.png' or p is  '.jpeg' or  p is '.jpg' or p is '.gif')
  catch e
    return false

# 与えられたArrayからmarkdownとfolder以外をpopする
sliceMarkdownAndFolder = (root,array,callback)->
  res = []
  async.forEach array, (el,cb)->
    res.push path.basename(el,'.md') if isMarkdown(path.resolve(root,el)) and path.basename(el,'.md') isnt 'index'
    res.push el if isFolder(path.resolve(root,el))
    cb()
  ,->
    callback res.sort()

exports.typer =
  isMarkdown:isMarkdown
  isFolder:isFolder
  isImage:isImage
  sliceMarkdownAndFolder:sliceMarkdownAndFolder