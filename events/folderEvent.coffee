exports.folderEvent = (app)->
  path = require 'path'

  dbhelper = app.get("helper").dbhelper app
  app_name = app.get "app_name"

  showList: (req,res)->
    dbhelper.getList req.params.folder, (folder,markdowns,nav)->
      res.render 'list',
        title: app_name
        folder:folder
        markdowns:markdowns
        nav:nav
        moment: require 'moment'
