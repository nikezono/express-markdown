# Express-Markdown
### 概要
* Markdown記法でWebサイトを作れる
* 指定されたディレクトリをWebサイトのリポジトリとする
* フォルダ構造をナビゲーションにする
* 記事名が与えられないときはindex.mdをレンダリングする

###example
    /root/ index.md # get "/"
           Works/    # get "/Works" and render "Works/index.md"
           			 hoge.md # get "/Works/hoge"

##@TODO
* キャッシュする
* 再帰的にディレクトリ構造を辿れるようにする
* mongoDBに格納してタイムスタンプやアクセス数を保存する
* コントローラがfatすぎるのでリファクタリング