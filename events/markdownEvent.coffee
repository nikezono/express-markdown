exports.markdownEvent = (app)->
  path = require 'path'
  dbhelper = app.get("helper").dbhelper app
  app_name = app.get "app_name"

  index: (req,res)->
    dbhelper.getArticle 'root',null, (markdown,nav)->
      markdown.meta.views += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'


  show: (req,res)->
    dbhelper.getArticle req.params.folder,req.params.filename,(markdown,nav)->
      markdown.meta.vies += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'

  showRoute: (req,res)->
    dbhelper.getArticle 'root',req.params.folder,(markdown,nav)->
      markdown.meta.vies += 1
      markdown.save()
      res.render 'index',
        title: app_name
        markdown:markdown
        nav:nav
        moment: require 'moment'

