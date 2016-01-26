# unite-pocket.vim

## はじめに

unite-pocket.vim は Pocket に保存したコンテンツを Vim で操作するための Unite source です。

## 必要なプラグイン

    NeoBundle 'mattn/webapi-vim.git'
    NeoBundle 'tyru/open-browser.vim'

## プラグインの読み込み

    NeoBundle 'syurazo/unite-pocket.vim'

### 遅延読み込みを行う場合

    NeoBundleLazy 'syurazo/unite-pocket.vim', {
    \   'commands': [ 'PocketList', 'PocketAdd' ],
    \   'unite_sources': 'pocket'
    \ }

## 使い方

### Access token の取得

 Unite source を呼び出したとき、Access token の取得が完了していないと、OAuth による認証のステップが実行されます。

 1. Vim の画面下に 'Consumer Key:' と表示されるので、Pocket API の Consumer Key を入力する。
 1. ブラウザが起動し、Pocket API の承認画面が表示される。
 1. Vim の画面下に 'OK?' と表示され入力待ちになるので、ブラウザで承認してから Vim でリターンキーを入力する。
 1. ~/.unite-pocket に Access token が保存される。

### 保存したコンテンツの一覧を表示する

 * すべてのコンテンツを表示する

    :Unite pocket

 * 未読コンテンツを表示する

    :Unite pocket:unread

 * 未読コンテンツを表示する

    :Unite pocket:archive

 * スターを付けたコンテンツを表示する

    :Unite pocket:all:favorited

 * スターを付けていないコンテンツを表示する

    :Unite pocket:all:unfavorited

### 新たにコンテンツを登録する

 * パラメタで URL を指定する

  :PocketAdd http://example.com/hoge/fuga

 * プロンプトから URL を入力する

  :PocketAdd
  site? http://example.com/hoge/fuga

### source から使える action

|action|動作|
|------|----|
|open|コンテンツをブラウザで表示する|
|delete|コンテンツをPokcetから削除する|
|archive|コンテンツをアーカイブに移動する|
|readd|アーカイブからコンテンツを未読として再登録する|
|favorite|コンテンツにスターを付ける|
|unfavorite|コンテンツのスターを外す|

## オプション変数

### g:unite_pocket_open_command

 コンテンツを開くコマンドを変更する。

    let g:unite_pocket_open_command = 'OpenBrowser'

### g:unite_pocket_retrieve_options

 一覧を取得する際の件数、順序、フィルタするステータスなどを指定する。

    let g:unite_pocket_retrieve_options = {
    \  'count':  100,
    \  'sort':   'newest',
    \  'state':  'all'
    \ }

### g:unite_pocket_status_marks

 Unite source でコンテンツのステータスとして表示するマーカーを指定する。


    let g:unite_pocket_status_marks = ['*', ' ', '!']


|index|意味|
|-----|----|
|0|未読|
|1|アーカイブ|
|2|要削除|

### g:unite_pocket_config_file

 Pocket API の Access token 等を保存するファイルを指定する。

    let g:unite_pocket_config_file = '~/.unite-pocket'


## カスタマイズ

### カーソル下の URL を Pocket に登録する

    nnoremap <silent> <Leader>zpA 
    \ :<C-u>execute 'PocketAdd ' . openbrowser#get_url_on_cursor()<CR>

### W3m.vim でカレントバッファに表示している URL を Pocket に登録する

    autocmd FileType w3m nnoremap <silent> <Leader>zpw
    \ :<C-u>execute 'PocketAdd ' . b:last_url<CR>

