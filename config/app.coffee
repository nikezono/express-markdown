require.all = require 'direquire'
express = require "express"
path = require "path"
fs = require "fs"

connect =
  assets : (require "connect-assets")
    buildDir: 'public'
  static: (require 'st')
    url: '/'
    path: path.resolve 'public'
    index: no
    passthrough: yes

mongoose = require "mongoose"
app = express()

#Express Configration
app.configure ->
  app.set 'env', process.env.NODE_ENV || 'development'
  app.set "port", process.env.PORT or 3000
  app.set "views", path.resolve "views"
  app.set "view engine", "jade"
  app.set 'events', require.all path.resolve 'events'
  app.set 'models', require.all path.resolve 'models'
  app.set 'helper', require.all path.resolve 'helper'
  app.set "app_name", process.env.APP_NAME || 'express-markdown'
  app.set "db_name", app.get("app_name").replace(/\./g,'_')
  app.set "watch_dir", process.env.WATCH_DIR || 'blog_sample' #Config Directory (ex:Dropbox/blog)
  app.use express.favicon path.resolve 'public', 'favicon.ico'
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use connect.assets
  app.use connect.static
  app.use app.router

routes = require path.resolve 'config','routes'
routes app

if process.env.NODE_ENV is 'production'
  console.info "mongoose connect:#{app.get('db_name')}"
  mongoose.connect "mongodb://localhost/#{app.get('db_name')}"
else
  console.info "mongoose connect:#{app.get('db_name')}-dev"
  mongoose.connect "mongodb://localhost/#{app.get('db_name')}-dev"


app.configure "development", ->
  app.use express.errorHandler()

exports = module.exports = app