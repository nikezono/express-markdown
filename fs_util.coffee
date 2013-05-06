fs = require "fs"
async = require "async"
util = new Object

util.getNav = (root,option,callback) ->
  fs.readdir root, (err,paths) ->
    console.log paths
    exists = []
    async.forEach paths, (val,cb) ->
      if option is "nav"
        exists.push val.slice(0,-3) if (fs.statSync(root+"/"+val).isFile() && val.slice(-2) is "md") && !(val is "index.md")
        exists.push val if fs.statSync(root+"/"+val).isDirectory()
      if option is "sub"
        exists.push val.slice(0,-3) if (fs.statSync(root+"/"+val).isFile() && val.slice(-2) is "md") && !(val is "index.md")
      cb()
    , ->
      callback(exists)


module.exports = util