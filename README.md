# unite-pocket.vim

## はじめに

unite-pocket.vim は Pocket に保存したコンテンツを Vim で操作するための Unite source です。

## インストール手順

    NeoBundle 'syurazo/unite-pocket.vim'

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
