###

Router

###

path = require 'path'

module.exports = (app) ->
  root = app.get 'watch_dir'
  typer = app.get("helper").typer
  folderEvent = app.get("events").folderEvent(app)
  markdownEvent = app.get("events").markdownEvent(app)

  #app.get  '/feed/rss'   #@TODO
  app.get  '/',                    markdownEvent.index
  app.get  '/:folder', (req,res,next)->
    if typer.isFolder(path.resolve(root,req.params.folder))
      folderEvent.showList(req,res)
    else if typer.isMarkdown(path.resolve(root,req.params.folder+'.md'))
      markdownEvent.showRoute(req,res)
    else
      res.send '404 Not Found.'

  app.get  '/:folder/:filename', markdownEvent.show