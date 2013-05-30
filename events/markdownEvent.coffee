exports.markdownEvent = (app)->
  path = require 'path'
  fs = require 'fs'
  dbhelper = app.get("helper").dbhelper app
  app_name = app.get "app_name"
  root = app.get "watch_dir"

  index: (req,res)->
    res.send '404 Not Found.' unless fs.existsSync(path.resolve(root,'index.md'))
    dbhelper.getArticle 'root',null, (markdown,nav)->
      markdown.meta.views += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'


  show: (req,res)->
    res.send '404 Not Found.' unless fs.existsSync(path.resolve(root,req.params.folder,req.params.filename+'.md'))
    dbhelper.getArticle req.params.folder,req.params.filename,(markdown,nav)->
      markdown.meta.views += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'

  showRoute: (req,res)->
    res.send '404 not found.' unless fs.existsSync(path.resolve(root,req.params.folder+'.md'))
    dbhelper.getArticle 'root',req.params.folder,(markdown,nav)->
      markdown.meta.views += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'

