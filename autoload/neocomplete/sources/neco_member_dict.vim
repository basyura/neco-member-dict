let s:save_cpo = &cpo
set cpo&vim
"
" source
"
let s:source = {
\   'name'      : 'neco_member_dict',
\   'kind'      : 'manual',
\ }
"
"
let s:cache = {
      \ 'sample' : { 'hoge' : [], 'fuga' : []},
      \ }
"
" ref : neocomplete.vim/autoload/neocomplete/sources/member.vim
function! s:source.get_complete_position(context)
  " Check member prefix pattern.
  let filetype = neocomplete#get_context_filetype()
  if !has_key(g:neocomplete#sources#member#prefix_patterns, filetype)
        \ || g:neocomplete#sources#member#prefix_patterns[filetype] == ''
    return -1
  endif

  let member = get(g:neocomplete#sources#member#input_patterns, filetype,
                    \ get(g:neocomplete#sources#member#input_patterns, '_', ''))
  let prefix = g:neocomplete#sources#member#prefix_patterns[filetype]
  let complete_pos = matchend(a:context.input, '\%(' . member . '\%(' . prefix . '\m\)\)\+\ze\w*$')
  return complete_pos
endfunction
"
"
function! s:source.gather_candidates(context)
  "let &titlestring = a:context.input . ' - ' . a:context.complete_str . ' - ' . a:context.complete_pos
  let pos = a:context.complete_pos - 1
  if pos <= 0
    return []
  endif

  let trigger = ''
  if a:context.input[pos] == '.'
    let trigger = '.'
  elseif a:context.input[pos] == ':'
    "let trigger = ':'
  endif

  if trigger == ''
    return []
  endif

  let short_head = ''
  let long_head  = ''
  while 1
    let pos = pos -1  
    let chr = a:context.input[pos]
    if short_head == '' && chr == '.' 
      let short_head = long_head
    endif
    if index(['', ' ', '(', '['], chr) >= 0
      break
    endif
    let long_head = chr . long_head
  endwhile

  "let &titlestring = a:context.input . ' - ' . a:context.complete_str . ' - ' . a:context.complete_pos . ' : ' . head
  let cache      = s:get_cache(&filetype)

  let candidates = get(cache, long_head, [])
  if len(candidates) == 0
    let candidates = get(cache, short_head, [])
  endif

  return map(copy(candidates), '{"word" : v:val, "menu" : "[MD]" }')
endfunction
"
" source#define
"
function! neocomplete#sources#neco_member_dict#define()
  return s:source
endfunction
"
"
"
function! s:get_cache(filetype)
  if has_key(s:cache, a:filetype)
    return s:cache[a:filetype]
  endif

  let path = get(g:neocomplete#sources#dictionary#dictionaries, a:filetype, '')
  if path == ''
    let s:cache[a:filetype] = {}
    return {}
  endif
  "
  " UIWindow.alloc.initWithFrame
  "
  " UIWindow.alloc
  "          hoge
  "          fuga
  "
  " dict['ruby'] = {'UIWindow' : ['alloc', 'hoge', 'fuga']}
  " dict['ruby'] = {'UIWindow.alloc' : ['initWithFrame', 'initWithNibName']}
  "
  let dict = {}
  for line in readfile(path)
    let pair = split(line, '\.')
    if len(pair) < 2
      continue
    endif

    let key = pair[0]
    for value in pair[1:]
      if has_key(dict, key)
        call add(dict[key], value)
      else
        let dict[key] = [value]
      endif
      let key = key . '.' . value
    endfor

    "if has_key(dict, pair[0])
      "call add(dict[pair[0]], pair[1])
    "else
      "let dict[pair[0]] = [pair[1]]
    "endif
  endfor
  let s:cache[a:filetype] = dict

  return dict
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
