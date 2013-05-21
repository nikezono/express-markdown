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
* preでhookしてmarkdownizeできてない
* gyazz記法
* css,js
* /:folder のコントローラ,view