module.exports = (app,root) ->

  # index
  app.get '/', (req,res,next) ->

  # Folder or Article
  app.get '/:folder', (req,res,next) ->

  # Article
  app.get '/:folder/:filename', (req,res,next) ->

