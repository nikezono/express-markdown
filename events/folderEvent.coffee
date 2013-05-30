exports.folderEvent = (app)->
  path = require 'path'
  fs = require 'fs'
  typer = app.get("helper").typer
  dbhelper = app.get("helper").dbhelper app
  app_name = app.get "app_name"
  root = app.get("watch_dir")

  showList: (req,res)->
    res.send '404 not found.' unless fs.existsSync(path.resolve(root,req.params.folder))
    dbhelper.getList req.params.folder, (folder,markdowns,nav)->
      res.send 'No Contents.' if markdowns is []
      res.render 'list',
        title: app_name
        folder:folder
        markdowns:markdowns
        nav:nav
        moment: require 'moment'
