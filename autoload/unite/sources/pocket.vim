"=============================================================================
" File    : autoload/unite/sources/pocket.vim
" Author  : syurazo <syurazo@gmail.com>
" License : MIT license
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

""----------------------------------------------------------------------
"" Unite source
let s:source = {
\   'name': 'pocket',
\   'default_action': 'open'
\ }

function! unite#sources#pocket#define()
  return s:source
endfunction

""----------------------------------------------------------------------
"" Unite source : actions
let s:source.action_table = {}

let s:source.action_table.open = {
\ 'description':   'open selected website',
\ 'is_selectable': 1
\}
function! s:source.action_table.open.func(candidate)
  for item in a:candidate
    execute g:unite_pocket_open_command . ' ' . item.action__item.resolved_url
  endfor
endfunction

let s:source.action_table.delete = {
\  'description':   'delete selected website',
\  'is_selectable': 1
\ }
function! s:source.action_table.delete.func(candidate)
  let list = []
  for item in a:candidate
    let list = add(list, item.action__item.item_id)
  endfor

  call unite#sources#pocket#api_delete_articles(list)
endfunction

let s:source.action_table.archive = {
\  'description':   "Move an item to the user's archive",
\  'is_selectable': 1
\ }
function! s:source.action_table.archive.func(candidate)
  let list = []
  for item in a:candidate
    let list = add(list, item.action__item.item_id)
  endfor

  call unite#sources#pocket#api_archive_articles(list)
endfunction

let s:source.action_table.readd = {
\  'description':
\     "Move an item from the user's archive back into their unread list.",
\  'is_selectable': 1
\ }
function! s:source.action_table.readd.func(candidate)
  let list = []
  for item in a:candidate
    let list = add(list, item.action__item.item_id)
  endfor

  call unite#sources#pocket#api_readd_articles(list)
endfunction

let s:source.action_table.favorite = {
\  'description':   "Mark an item as a favorite",
\  'is_selectable': 1
\ }
function! s:source.action_table.favorite.func(candidate)
  let list = []
  for item in a:candidate
    let list = add(list, item.action__item.item_id)
  endfor

  call unite#sources#pocket#api_favorite_articles(list)
endfunction

let s:source.action_table.unfavorite = {
\  'description':   "Remove an item from the user's favorites",
\  'is_selectable': 1
\ }
function! s:source.action_table.unfavorite.func(candidate)
  let list = []
  for item in a:candidate
    let list = add(list, item.action__item.item_id)
  endfor

  call unite#sources#pocket#api_unfavorite_articles(list)
endfunction

""----------------------------------------------------------------------
"" Unite source : gather candidate 
function! s:source.gather_candidates(args,context)
  let favval = {'favorited': 1, 'unfavorited': 0}
  let favorite = get(g:unite_pocket_retrieve_options, 'favorite', '')
  let state =    get(g:unite_pocket_retrieve_options, 'state', 'all')
  let items = unite#sources#pocket#get_item_list({
  \  'state':    get(a:args, 0, state),
  \  'favorite': get(favval, get(a:args, 1, favorite), '')
  \ })

  let candidates = []
  for val in items
    let title = s:search(val,
    \  ['given_title','resolved_title','given_url','resolved_url'],
    \  'strlen','')

    let mark = g:unite_pocket_status_marks[val.status]
    call add(candidates, {
    \ 'word':           mark . title,
    \ 'source':         'pocket',
    \ 'action__item':   val
    \ })
  endfor
  return candidates
endfunction

function! unite#sources#pocket#get_item_list(filter)
  let cond = {
  \   'count': g:unite_pocket_retrieve_options['count'],
  \   'sort':  g:unite_pocket_retrieve_options['sort'],
  \   'state': a:filter['state']
  \ }
  if has_key(a:filter, 'favorite')
    let cond['favorite'] = a:filter['favorite']
  endif

  let res = s:request_pocket_get(cond)
  if res.status != '200'
    call s:print_error_responce(res)
    return []
  endif

  let json = webapi#json#decode(res.content)

  let list = []
  for key in keys(json.list)
     let list = add(list, json.list[key])
  endfor
  let list = sort(list, 's:sort_articles')

  return list
endfunction

function! s:sort_articles(lhs, rhs)
  let cond = {
  \  'newest': {'key': 'time_added', 'order': 'desc'},
  \  'oldest': {'key': 'time_added', 'order': 'asc' }
  \ }
  let key   = cond[g:unite_pocket_retrieve_options['sort']].key
  let order = cond[g:unite_pocket_retrieve_options['sort']].order

  if order == 'asc'
    return a:lhs[key] - a:rhs[key]
  else
    return a:rhs[key] - a:lhs[key]
  endif
endfunction

""----------------------------------------------------------------------
"" config
function! s:get_auth_config()
  let filename = expand(g:unite_pocket_config_file)

  if exists('g:unite_pocket_auth_config')
    return g:unite_pocket_auth_config
  elseif filereadable(filename)
    let g:unite_pocket_auth_config = eval(join(readfile(filename), ""))
  else
    let consumer_key = input('Consumer Key:')
    let request_token = s:get_request_token(consumer_key)

    execute "OpenBrowser " . 'https://getpocket.com/auth/authorize'
    \ . '?request_token=' . request_token
    \ . '&redirect_uri=https://getpocket.com/options'
    call input('OK?:')

    let access_token = s:get_access_token(consumer_key, request_token)

    let g:unite_pocket_auth_config = {
    \  'consumer_key':  consumer_key,
    \  'request_token': request_token,
    \  'access_token':  access_token
    \ }

    call writefile([string(g:unite_pocket_auth_config)], filename)
  endif

  return g:unite_pocket_auth_config
endfunction

""----------------------------------------------------------------------
"" OAuth
function! s:get_request_token(consumer_key)
  let res = webapi#http#post('https://getpocket.com/v3/oauth/request',
  \ { 'consumer_key': a:consumer_key,
  \   'redirect_uri': 'http://getpocket.com/developer/apps/'
  \ },
  \ { 'X-Accept': 'application/json'
  \ })

  if res.status != '200'
    call s:print_error_responce(res)
    return 0
  else
    let json = webapi#json#decode(res.content)
    return json.code
  endif
endfunction

function! s:get_access_token(consumer_key, request_token)
  let res = webapi#http#post('https://getpocket.com/v3/oauth/authorize',
  \ { 'consumer_key': a:consumer_key,
  \   'code':         a:request_token
  \ },
  \ { 'X-Accept': 'application/json'
  \ })

  if res.status != '200'
    call s:print_error_responce(res)
    return 0
  else
    let json  = webapi#json#decode(res.content)
    return json.access_token
  endif
endfunction

""----------------------------------------------------------------------
"" Pocket API
function! s:request_pocket_api(api, options)
  let ctx = s:get_auth_config()
  let header = {
  \   'X-Accept': 'application/json'
  \ }
  let request = {
  \   'consumer_key': ctx['consumer_key'],
  \   'access_token': ctx['access_token']
  \ }

  for key in keys(a:options)
    let request[key] = a:options[key]
  endfor

  return webapi#http#post(a:api, request, header)
endfunction

function! s:request_pocket_get(options)
  return s:request_pocket_api('https://getpocket.com/v3/get', a:options)
endfunction

function! s:request_pocket_add(options)
  return s:request_pocket_api('https://getpocket.com/v3/add', a:options)
endfunction

function! s:request_pocket_send(options)
  return s:request_pocket_api('https://getpocket.com/v3/send', a:options)
endfunction

""----------------------------------------------------------------------
"" Pocket API wrapper
function! unite#sources#pocket#api_add_article(url)
  let res = s:request_pocket_add({'url': a:url})
  if res.status != '200'
    call s:print_error_responce(res)
  else
    call s:print_message('succeeded!')
  endif
endfunction

function! unite#sources#pocket#api_delete_articles(item_id_list)
  let actions =
  \  map(copy(a:item_id_list), "{'action': 'delete', 'item_id': v:val}")
  let res = s:request_pocket_send({
  \   'actions': webapi#json#encode(actions)
  \ })

  if res.status != '200'
    call s:print_error_responce(res)
  else
    call s:print_message('succeeded!')
  endif
endfunction

function! unite#sources#pocket#api_archive_articles(item_id_list)
  let actions =
  \  map(copy(a:item_id_list), "{'action': 'archive', 'item_id': v:val}")
  let res = s:request_pocket_send({
  \   'actions': webapi#json#encode(actions)
  \ })

  if res.status != '200'
    call s:print_error_responce(res)
  else
    call s:print_message('succeeded!')
  endif
endfunction

function! unite#sources#pocket#api_readd_articles(item_id_list)
  let actions =
  \  map(copy(a:item_id_list), "{'action': 'readd', 'item_id': v:val}")
  let res = s:request_pocket_send({
  \   'actions': webapi#json#encode(actions)
  \ })

  if res.status != '200'
    call s:print_error_responce(res)
  else
    call s:print_message('succeeded!')
  endif
endfunction

function! unite#sources#pocket#api_favorite_articles(item_id_list)
  let actions =
  \  map(copy(a:item_id_list), "{'action': 'favorite', 'item_id': v:val}")
  let res = s:request_pocket_send({
  \   'actions': webapi#json#encode(actions)
  \ })

  if res.status != '200'
    call s:print_error_responce(res)
  else
    call s:print_message('succeeded!')
  endif
endfunction

function! unite#sources#pocket#api_unfavorite_articles(item_id_list)
  let actions =
  \  map(copy(a:item_id_list), "{'action': 'unfavorite', 'item_id': v:val}")
  let res = s:request_pocket_send({
  \   'actions': webapi#json#encode(actions)
  \ })

  if res.status != '200'
    call s:print_error_responce(res)
  else
    call s:print_message('succeeded!')
  endif
endfunction

""----------------------------------------------------------------------
" misc
function! s:search(dict,keys,func,default)
  let Func=function(a:func)
  for key in a:keys
    if has_key(a:dict, key) && Func(a:dict[key])
      return a:dict[key]
    endif
  endfor
  return a:default
endfunction

function! s:print_message(msg)
  call unite#print_source_message(a:msg, s:source.name)
endfunction

function! s:print_error(err)
  call unite#print_source_error(a:err, s:source.name)
endfunction

function! s:print_error_responce(res)
  call s:print_error(a:res.status . " " . a:res.message)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

