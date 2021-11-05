"set hlsearch
set incsearch

set tabstop=2
set shiftwidth=2
set autoindent
set expandtab

set number relativenumber
set backspace=indent,eol,start
set nocompatible
filetype plugin on
syntax enable
" packadd! dracula
" colorscheme dracula

set foldlevel=99
"set foldminlines=3
" Save folds between sessions
":set sessionoptions-=options
:set sessionoptions=folds

"call plug#begin('~/.vim/plugged')
"Plug 'vimwiki/vimwiki'
", { 'commit': '48baa1f4cd1bb4963e28c9bef2135feac5a81b4f' }
"Plug 'tools-life/taskwiki'
"Plug 'majutsushi/tagbar'
"call plug#end()

let g:vimwiki_global_ext = 0
let g:vimwiki_list = [{'path': '~/.task/wiki/', 'syntax': 'markdown', 'ext': '.md'}]
" https://mkaz.blog/working-with-vim/vimwiki/
let g:vimwiki_listsyms = ' W+s*X' " waiting, pending, +next, scheduled, active, completed
let g:vimwiki_listsym_rejected = 'D'
let g:vimwiki_folding = 'expr:quick'
"https://github.com/vimwiki/vimwiki/commit/2a31984369300120bf11e8dcc62e358ab268477f#diff-1ef903c6e8988556c346ab49420ddfb12545c6bb36e14264630578a946ab9256
let g:listsyms_propagate = 0

"nmap q <leader>ww
"nmap s <leader>t+

autocmd VimEnter ~/.task/wiki/*.md silent! :source %.vim
autocmd VimLeave ~/.task/wiki/*.md :mksession! %.vim
" TODO make filetype specific: https://stackoverflow.com/questions/53538592/in-vimrc-apply-certain-highlighting-rules-only-for-certain-filetype
" https://vi.stackexchange.com/a/10666
autocmd FileType vimwiki nmap <buffer> <Space> :VimwikiToggleListItem<CR>
autocmd FileType vimwiki nmap <buffer> <S-d> :VimwikiToggleRejectedListItem<CR>
" https://stackoverflow.com/questions/9464844/how-to-get-group-name-of-highlighting-under-cursor-in-vim
function! SkipUpOrIncrement()
  if synIDattr(synID(line("."), col("."), 1), "name") == 'VimwikiListTodo'
    :execute ":VimwikiIncrementListItem"
  else
    :normal zk
  endif
endfun

function! SkipDownOrDecrement()
  if synIDattr(synID(line("."), col("."), 1), "name") == 'VimwikiListTodo'
    :execute ":VimwikiDecrementListItem"
  else
    :normal zj
  endif
endfun

function! OpenFoldOrIncreaseIndent()
  if synIDattr(synID(line("."), col("."), 1), "name") == 'VimwikiListTodo'
    " increase list item level
    :normal gll
  else
    " open fold
    :normal zo
  endif
endfun

function! CloseFoldOrDecreaseIndent()
  if synIDattr(synID(line("."), col("."), 1), "name") == 'VimwikiListTodo'
    " decrease list item level
    :normal glh
  else
    " close fold
    :normal zc
  endif
endfun

autocmd FileType vimwiki nmap <buffer> <S-Up> :call SkipUpOrIncrement()<CR>
autocmd FileType vimwiki inoremap <buffer> <S-Up> <Esc>:call SkipUpOrIncrement()<CR>i
autocmd FileType vimwiki nmap <buffer> <S-Down> :call SkipDownOrDecrement()<CR>
autocmd FileType vimwiki inoremap <buffer> <S-Down> <Esc>:call SkipDownOrDecrement()<CR>i
" autocmd FileType vimwiki nmap <buffer> <S-n> :VimwikiNextTask<CR>
autocmd FileType vimwiki nmap <buffer> >> :call OpenFoldOrIncreaseIndent()<CR>
autocmd FileType vimwiki nmap <buffer> << :call CloseFoldOrDecreaseIndent()<CR>
noremap > >>
noremap < <<

" add a conceal for UUIDs
" https://alok.github.io/2018/05/09/more-about-vim-conceal/
autocmd FileType vimwiki syn match TWUUID "\s#[0-9a-f\-]\{36}$" containedin=VimwikiTodo conceal
autocmd FileType vimwiki syn match TWUUID "\s#new$" containedin=VimwikiTodo conceal "VimwikiListTodo
autocmd FileType vimwiki highlight link TWUUID Keyword
" add more @context and +project syntax:  https://github.com/vimwiki/vimwiki/issues/309
setlocal concealcursor=n
set conceallevel=3
" FIXME https://stackoverflow.com/questions/12397103/the-conceal-feature-in-vim-still-makes-me-move-over-all-the-characters

" executed on argument-less startup:
"if argc() == 0
"  au VimEnter * execute "normal \\ww"
"endif
