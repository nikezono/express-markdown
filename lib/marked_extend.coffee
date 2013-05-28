###

  marked_extend
  markdown記法の拡張コンパイラ
  # 記法
  [youtube](id)     : idのyoutube動画の埋め込みタグを生成
  [[Article.title]] : 該当するArticleへのリンクを貼る
  [[http(s):://*|]] : 外部リンクを貼る
  [[http(s)://*.(png|jpg|gif)]] : 画像タグを貼る
  [video](path)     : pathの映像をvideoタグとして囲む

###

marked = require 'marked'

marked.setOptions
  gfm: true
  tables: true
  breaks: true
  pedantic: false
  sanitize: false
  smartLists: true
  langPrefix: "language-"
  highlight: (code, lang) ->
    return highlighter.javascript(code)  if lang is "js"
    code

exports.tohtml = (text,done) ->
  html = marked text
  done html
