marked = require 'marked'

marked.setOptions
  gfm: true
  tables: true
  breaks: true
  pedantic: true
  sanitize: false
  smartLists: true
  langPrefix: "language-"
  highlight: (code, lang) ->
    return highlighter.javascript(code)  if lang is "js"
    code

console.log marked "<h1>hhh</h1>"