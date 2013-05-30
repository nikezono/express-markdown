# Express-Markdown
### 概要
* Markdown記法でWebサイトを作れる
* 指定されたディレクトリをWebサイトのリポジトリとする
* フォルダ構造をナビゲーションにする
* 記事と同じフォルダに同じファイル名の画像ファイルを置くと、サムネイルになる

###example
    /root/ index.md # get "/"
           Works/    # get "/Works"
           			 hoge.md # get "/Works/hoge"

##@TODO
* リファクタリング
* routesをリファクタリングして404追加
* RSS
* pjax