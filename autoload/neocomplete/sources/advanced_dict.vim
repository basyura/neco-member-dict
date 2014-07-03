let s:save_cpo = &cpo
set cpo&vim
"
" source
"
let s:source = {
\   'name'      : 'advanced_dict',
\   'kind'      : 'manual',
\   'hooks'     : {},
\ }

let s:cache = {
      \ 'sample' : { 'hoge' : [], 'fuga' : []},
      \ }

function! s:source.hooks.on_init(context)
  if has_key(s:cache, &filetype)
    return
  endif

  let path = get(g:neocomplete#sources#dictionary#dictionaries, &filetype, '')
  if path == ''
    let s:cache[&filetype] = {}
    return
  endif
  let dict = {}
  for line in readfile(path)
    let pair = split(line, '\.')
    if len(pair) < 2
      continue
    endif
    if has_key(dict, pair[0])
      call add(dict[pair[0]], pair[1])
    else
      let dict[pair[0]] = [pair[1]]
    endif
  endfor
  let s:cache[&filetype] = dict
endfunction
"
function! s:source.gather_candidates(context)

  let &titlestring = a:context.input . ' - ' . a:context.complete_str . ' - ' . a:context.complete_pos
  let pos = a:context.complete_pos - 1
  if pos <= 0
    return []
  endif

  let head = ""

  let trigger = ''

  if a:context.input[pos] == '.'
    let trigger = '.'
  elseif a:context.input[pos] == ':'
    "let trigger = ':'
  endif

  if trigger == ''
    return []
  endif

  while 1
    let pos = pos -1  
    let chr = a:context.input[pos]
    if chr == '' || chr == ' ' || chr == '(' || chr == '.'
      break
    endif
    let head = chr . head
  endwhile

  let &titlestring = a:context.input . ' - ' . a:context.complete_str . ' - ' . a:context.complete_pos . ' : ' . head


  let candidates = get(s:cache[&filetype], head, [])

  return map(copy(candidates), '{"word" : v:val, "menu" : "[AD]" }')
endfunction
"
" source#define
"
function! neocomplete#sources#advanced_dict#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
