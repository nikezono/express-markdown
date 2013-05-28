###

  imagecopier
  指定されたフォルダ内のファイル名について、
  basenameが同じで、拡張子が画像ファイルのものを探索し、
  見つかった画像ファイルを、
  静的ファイルがホストされているpublic/img/にコピーする

###

fs = require 'fs'
path = require 'path'
async = require 'async'

exports.imagecopier = ->

  articleHasImage: (article_path,basename,foldername,callback)->
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


#private
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
