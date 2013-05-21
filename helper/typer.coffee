path = require 'path'
fs = require 'fs'
async = require 'async'

isMarkdown = (target_path)->
  return (fs.statSync(target_path).isFile() and path.extname(target_path) is '.md')

isFolder = (target_path)->
  return (fs.statSync(target_path).isDirectory() and path.extname(target_path) is '')

sliceMarkdownAndFolder = (root,array,callback)->
  res = []
  async.forEach array, (el,cb)->
    res.push path.basename(el,'.md') if isMarkdown(path.resolve(root,el))
    res.push el if isFolder(path.resolve(root,el))
    cb()
  ,->
    callback res

exports.isMarkdown = isMarkdown
exports.isFolder = isFolder
exports.sliceMarkdownAndFolder = sliceMarkdownAndFolder