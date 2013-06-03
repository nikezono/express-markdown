# Express-Markdown
### 概要
* node.jsによるWebサイトテンプレート
* 指定したディレクトリをWatchし、フォルダ構造と記事テキストを対応させて自動でWebサイトにする
* 記事はMarkdown形式で記述する
* Dropboxなどの同期にも対応している

### usage
    git clone git://github.com/nikezono/express-markdown.git
    cd express-markdown
    node express-markdown -a sitename -e production -w /Your/Watch/Directory

### Options
      -p "port"       set listening port (3000 default)
      -f "fork"       process concurrency nums ('+cpus+' default)
      -e "env"        set application environment (development default)
      -m "interval"   report memory usage info (5 default)
      -w "watch"      set watch dirrectory. External Path is required. (./blog_sample default)
      -a "appname"    set application&database name("express-markdown" default
      -h              show this message

###example
    /root/ index.md # get "/"
           Works/    # get "/Works" list
           			 hoge.md # get "/Works/hoge"