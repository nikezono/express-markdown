path = require 'path'
fs = require 'fs'
async = require 'async'

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

articleHasImage = (article_path,basename,foldername,callback)->
  dirname = path.dirname(article_path)
  foldername = '' if foldername is 'root'
  image_path = ''
  async.parallel [(cb)->
    existsAndCopy '.png',dirname,basename,foldername,(dest)->
      image_path = dest
      cb(null)
  ,(cb) ->
    existsAndCopy '.gif',dirname,basename,foldername,(dest)->
      image_path = dest
      cb(null)
  ,(cb)->
    existsAndCopy '.jpg',dirname,basename,foldername,(dest)->
      image_path = dest
      cb(null)
  ],(err,results)->
    console.log "Destination path:#{image_path}"
    callback image_path

existsAndCopy = (extention,dirname,basename,foldername,callback)->
  fs.exists (path.resolve(dirname,basename))+extention, (exists)->
    if exists
      console.log foldername+'/'+basename+extention+" is exists"
      dest_path = path.normalize "/img/#{foldername}/#{basename}#{extention}"
      fs.stat path.normalize("public/img/#{foldername}"), (err,stats)->
        if stats
          if stats.isDirectory()
            console.log "Copy #{foldername}/#{basename}#{extention} to public/img"
            fs.createReadStream(path.resolve(dirname,basename)+extention).pipe fs.createWriteStream(path.normalize("public/img/#{foldername}/#{basename}#{extention}"))
            callback dest_path
          else
            callback ''
        else
          console.log "Create Folder And Copy #{foldername}/#{basename}#{extention} to public/img"
          fs.mkdirSync "public/img/#{foldername}"
          fs.createReadStream(path.resolve(dirname,basename)+extention).pipe fs.createWriteStream(path.normalize("public/img/#{foldername}/#{basename}#{extention}"))
          callback dest_path
    else
      callback ''
      console.log foldername+'/'+basename+extention+" isn't exists"


sliceMarkdownAndFolder = (root,array,callback)->
  res = []
  async.forEach array, (el,cb)->
    res.push path.basename(el,'.md') if isMarkdown(path.resolve(root,el))
    res.push el if isFolder(path.resolve(root,el))
    cb()
  ,->
    callback res

exports.articleHasImage = articleHasImage
exports.isImage = isImage
exports.isMarkdown = isMarkdown
exports.isFolder = isFolder
exports.sliceMarkdownAndFolder = sliceMarkdownAndFolder