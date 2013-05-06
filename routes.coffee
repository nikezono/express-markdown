fs = require 'fs'
async = require 'async'
md = (require "markdown").markdown
fs_util = require './fs_util'

module.exports = (app,root) ->

  app.get '/', (req,res,next) ->
    fs_util.getNav root,"nav", (nav)->
      fs.readFile root+"/index.md","utf-8",(err,data) ->
        res.render "index",
          nav: nav
          content: md.toHTML(data)
          articles: null
          title: root
          logo : root


  #@TODO 再帰で書けば無限にディレクトリ辿れる
  #@TODO コントローラに書くべきではない
  #@TODO mongodbに格納すべき
  #@TODO キャッシュできる
  #@TODO きたないよ！！！
  app.get '/:folder', (req,res,next) ->
    fs_util.getNav root,"nav",(nav) ->
      if fs.existsSync(root+"/"+req.params.folder)
        if fs.statSync(root+"/"+req.params.folder).isDirectory()
          fs_util.getNav root+"/"+req.params.folder, "sub", (sub) ->
            fs.readFile root+"/"+req.params.folder+"/index.md","utf-8",(err,data) ->
              res.render "index",
                type: "folder"
                nav: nav
                content: md.toHTML(data)
                articles: sub
                title:"#{root}:#{req.params.folder}"
                logo:"#{req.params.folder}の一覧"
                folder:"#{req.params.folder}"

      else if fs.existsSync(root+"/"+req.params.folder+".md")
        if fs.statSync(root+"/"+req.params.folder+".md").isFile()
          fs.readFile root+"/"+req.params.folder+".md","utf-8",(err,data) ->
            res.render "index",
              content:md.toHTML(data)
              nav:nav
              title:"#{root}:#{req.params.folder}"
              logo: "#{req.params.folder}"
              type: "file"
              articles : null
      else
        res.send "404 Error"

  app.get '/:folder/:filename', (req,res,next) ->
    fs_util.getNav root,"nav",(nav) ->
      if fs.existsSync root+"/"+req.params.folder+"/"+req.params.filename+".md"
        if fs.statSync(root+"/"+req.params.folder+"/"+req.params.filename+".md").isFile()
          fs.readFile root+"/"+req.params.folder+"/"+req.params.filename+".md","utf-8",(err,data) ->
            res.render "index",
              content:md.toHTML(data)
              nav:nav
              type: "file"
              articles : null
              title:"#{root}:#{req.params.filename}"
              logo: "#{req.params.filename}"
      else
        res.send "404 Error"
