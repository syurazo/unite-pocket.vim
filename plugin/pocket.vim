"=============================================================================
" File    : pocket.vim
" Author  : syurazo <syurazo@gmail.com>
" License : MIT license
"=============================================================================
if exists('g:loaded_unite_source_pocket')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:unite_pocket_config_file')
  let g:unite_pocket_config_file = '~/.unite-pocket'
endif

if !exists('g:unite_pocket_open_command')
  let g:unite_pocket_open_command = 'OpenBrowser'
endif

if !exists('g:unite_pocket_default_tags')
  let g:unite_pocket_default_tags = ''
endif

if !exists('g:unite_pocket_retrieve_options')
  let g:unite_pocket_retrieve_options = {
  \  'count':  100,
  \  'sort':   'newest',
  \  'state':  'all'
  \ }
endif

if !exists('g:unite_pocket_status_marks')
  let g:unite_pocket_status_marks = ['*', ' ', '!']
endif

if !exists('g:unite_pocket_formatter')
  let g:unite_pocket_formatter = 's:unite_pocket_default_formatter'
endif

command! -nargs=0 PocketList call s:call_pocket_list()
function! s:call_pocket_list()
  :Unite pocket
endfunction

command! -nargs=? PocketAdd call s:add_article(<f-args>)
function! s:add_article(...)
  let url  = (a:0 >= 1 ? a:1 : input('site:'))
  let tags = (a:0 >= 1 ? ''  : input('tags:', g:unite_pocket_default_tags))
  if strlen(url) > 0
    call unite#sources#pocket#api_add_article(url, tags)
  endif
endfunction

let g:loaded_unite_source_pocket = 1

let &cpo = s:save_cpo
unlet s:save_cpo

