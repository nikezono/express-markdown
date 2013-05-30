exports.dbcleaner = (app)->
  path = require 'path'
  async = require 'async'
  fs = require 'fs'
  typer = app.get('helper').typer
  Folder = app.get("models").Folder
  Markdown = app.get("models").Markdown

  remove: (root_dir)->
    checked = Date.now()
    console.log "DB cleaning start"
    async.series [(cb)->
      Folder.findOne {title:'root'},(err,root)->
        cb() unless root
        root.checked = checked
        root.save()
        console.log "Root is checked : #{root.checked}"
        Markdown.findOne {title:'index',folder:root.id},(err,index)->
          cb() unless index
          index.checked = checked
          index.save()
          console.log "index is checked : #{index.checked}"
          cb()
    ,(cb)->
      removeUnlinked root_dir, null, checked,true,(folders)->
        async.forEach folders, (folder,_cb)->
          console.log "root:#{root_dir},folder:#{folder}"
          removeUnlinked root_dir,folder,checked,false,->
            console.log "subdirectory #{folder} is checked."
            _cb()
        ,->
          cb()
    ,(cb)->
      Folder.find {checked:{$ne:checked}},(err,folders)->
        console.error if err
        async.forEach folders,(fd,_cb)->
          console.log "folder #{fd.title} is removed"
          fd.remove()
          _cb()
        ,->
          cb()
    ,(cb)->
      Markdown.find {checked:{$ne:checked}},(err,mds)->
        console.error if err
        async.forEach mds,(md,_cb)->
          console.log "markdown #{md.title} is removed"
          md.remove()
          _cb()
        ,->
          console.log "DB checked end"
          cb()
    ]

    #private
    removeUnlinked = (root,foldername='',checked,recursive,callback)->
      console.log "#{root}/#{foldername} is checking now."
      files = fs.readdirSync path.resolve(root,foldername)
      folders = []
      search_dir = path.resolve root,foldername
      typer.sliceMarkdownAndFolder search_dir,files, (sliced)->
        async.forEach sliced, (file,cb)->
          pth = path.resolve root,foldername,file
          console.log "#{pth} is checking now..."
          if typer.isMarkdown(pth+".md")
            fname = (if (foldername is '') then "root" else foldername)
            Folder.findOne {title:fname},(err,folder)->
              Markdown.findOne {title:file,folder:folder.id}, (err,md)->
                md.checked = checked
                md.save()
                console.log "checked:#{checked}, #{md.title} is exists file"
                cb()
          else if typer.isFolder(pth)
            Folder.findOne {title:file},(err,folder)->
              folder.checked = checked
              folder.save()
              console.log "checked:#{checked}, #{folder.title} is exists folder"
              folders.push file
              cb()
          else
            cb()
        ,->
          console.log "checked.inluding folders: #{folders}"
          callback folders

