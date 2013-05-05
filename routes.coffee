fs = require 'fs'
async = require 'async'
md = (require "markdown").markdown

module.exports = (app,root) ->

  app.get '/', (req,res,next) ->
    fs.readdir root, (err,paths) ->
      console.log paths
      exists = []
      async.forEach paths, (val,cb) ->
        exists.push val if (fs.statSync(root+"/"+val).isFile() && val.slice(-2) is "md") || fs.statSync(root+"/"+val).isDirectory()
        cb()
      , ->
        fs.readFile root+"/index.md","utf-8",(err,data) ->
          res.render "index",
            nav: exists
            content: md.toHTML(data)
            articles: null

  #@TODO 再帰で書けば無限にディレクトリ辿れる
  #@TODO コントローラに書くべきではない
  #@TODO mongodbに格納すべき
  #@TODO キャッシュできる
  app.get '/:folder', (req,res,next) ->
    fs.readdir root, (err,paths)->
      console.log paths
      fs.stat root+"/"+req.params.folder, (err,stats)->
        if stats
          if stats.isDirectory()
            fs.readFile root+"/"+req.params.folder+"/index.md","utf-8",(err,data) ->
              fs.readdir root+"/"+req.params.folder,(err,articles)->
                arts = []
                async.forEach articles,(val,cb) ->
                  arts.push val if val.slice(-2) is "md"
                  cb()
                , ->
                  res.render "index",
                    type: "folder"
                    nav: paths
                    content: md.toHTML(data)
                    articles: arts

        else if fs.statSync(root+"/"+req.params.folder+".md").isFile()
          fs.readFile root+"/"+req.params.folder+".md","utf-8",(err,data) ->
            res.render "index",
              content:md.toHTML(data)
              nav:paths
              type: "file"
              articles : null

  app.get '/:folder/:filename', (req,res,next) ->
    fs.readdir root, (err,paths)->
      console.log paths
      if fs.statSync(root+"/"+req.params.folder+"/"+req.params.filename+".md").isFile()
        fs.readFile root+"/"+req.params.folder+"/"+req.params.filename+".md","utf-8",(err,data) ->
          res.render "index",
            content:md.toHTML(data)
            nav:paths
            type: "file"
            articles : null
