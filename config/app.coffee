require.all = require 'direquire'
express = require "express"
http = require "http"
path = require "path"
fs = require "fs"

connect =
  assets : require "connect-assets"
mongoose = require "mongoose"
app = express()

#Express Configration
app.configure ->
  app.set 'env', process.env.NODE_ENV || 'development'
  app.set "port", process.env.PORT or 3001
  app.set "models", require.all path.resolve 'models'
  app.set "views", path.resolve "views"
  app.set "view engine", "jade"
  app.set "app_name", process.env.APP_NAME || 'express-markdown'
  app.set "watch_dir", process.env.WATCH_DIR #Config Directory (ex:Dropbox/blog)
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use connect.assets buildDir: 'public'
  app.use app.router
  app.use require("stylus").middleware(__dirname + "/public")
  app.use express.static(path.join(__dirname, "public"))

routes = require path.resolve 'config','routes'
routes app , app.get "watch_dir"

if process.env.NODE_ENV is 'production'
  mongoose.connect 'mongodb://localhost/express-markdown'
else
  mongoose.connect 'mongodb://localhost/express-markdown-dev'

app.configure "development", ->
  app.use express.errorHandler()

exports = module.exports = app