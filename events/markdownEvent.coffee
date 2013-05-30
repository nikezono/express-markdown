exports.markdownEvent = (app)->
  path = require 'path'
  dbhelper = app.get("helper").dbhelper app
  app_name = app.get "app_name"

  index: (req,res)->
    dbhelper.getArticle 'root',null, (markdown,nav)->
      res.send '500 No Contents' unless markdown
      markdown.meta.views += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'


  show: (req,res)->
    dbhelper.getArticle req.params.folder,req.params.filename,(markdown,nav)->
      res.send '500 No Contents' unless markdown
      markdown.meta.views += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'

  showRoute: (req,res)->
    dbhelper.getArticle 'root',req.params.folder,(markdown,nav)->
      res.send '500 No Contents' unless markdown
      markdown.meta.views += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'

