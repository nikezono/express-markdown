###

  marked_extend
  markdown記法の拡張コンパイラ
  # 記法
  [thumbnail](path) : pathの画像をサムネイルとしてimgタグで囲む
  [youtube](id)     : idのyoutube動画の埋め込みタグを生成
  [[Article.title]] : 該当するArticleへのリンクを貼る
  [[http(s):://*|]] : 外部リンクを貼る
  [[http(s)://*.(png|jpg|gif)]] : 画像タグを貼る
  [video](path)     : pathの映像をvideoタグとして囲む

###

md = (require 'markdown').markdown

exports.tohtml = (text,done) ->
  html = md.toHTML text
  done html
