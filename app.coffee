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
  app.set "port", process.env.PORT or 3001
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.set "blog directory","blog_sample" #Config Directory (ex:Dropbox/blog)
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use connect.assets buildDir: 'public'
  app.use app.router
  app.use require("stylus").middleware(__dirname + "/public")
  app.use express.static(path.join(__dirname, "public"))

routes = require './routes'
routes app,app.get "blog directory"

app.configure "development", ->
  app.use express.errorHandler()

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")