"set hlsearch
set incsearch

set tabstop=2
set shiftwidth=2
set expandtab " vimwiki doesn't correctly copy indentation of spaces unless expand is on...
set copyindent " copy the previous indentation on autoindenting
set autoindent " always set autoindenting on

set number relativenumber
set backspace=indent,eol,start
set nocompatible
filetype plugin on
" filetype plugin indent off
syntax enable
" let black be black
let g:dracula_colorterm = 0
packadd! dracula
colorscheme dracula

" gitgutter
highlight clear SignColumn
highlight GitGutterAdd ctermfg=2
highlight GitGutterChange ctermfg=3
highlight GitGutterDelete ctermfg=1
" let g:gitgutter_sign_removed = '-'
highlight GitGutterChangeDelete ctermfg=4
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap ghs <Plug>(GitGutterStageHunk)
nmap ghu <Plug>(GitGutterUndoHunk)


" VIMWIKI
" vim global " FIXME https://stackoverflow.com/questions/12397103/the-conceal-feature-in-vim-still-makes-me-move-over-all-the-characters
setlocal concealcursor=n
" vimwiki-specific
"set conceallevel=3
let g:vimwiki_global_ext = 0
let g:vimwiki_list = [{'path': '~/.task/wiki/', 'syntax': 'markdown', 'ext': '.md'}]
" http://frostyx.cz/posts/vimwiki-diary-template
autocmd BufNewFile ~/.task/wiki/diary/[0-9]*.md :silent 0r ~/.task/wiki/diary/template.md
" executed on argument-less startup:
if argc() == 0
  " autocmd VimEnter does not set the syntax NOR include the template, so do
  " manually:
      autocmd VimEnter *
  \   execute "normal \\w\\w"
  \ | set filetype=vimwiki
  \ | execute ":r ~/.task/wiki/diary/template.md"
endif

" https://mkaz.blog/working-with-vim/vimwiki/
let g:vimwiki_listsyms = ' W+s*X' " waiting, pending, +next, scheduled, active, completed
let g:vimwiki_listsym_rejected = 'D'
let g:vimwiki_listsyms_propagate = 0
let g:vimwiki_folding = 'expr:quick'
"https://github.com/vimwiki/vimwiki/commit/2a31984369300120bf11e8dcc62e358ab268477f#diff-1ef903c6e8988556c346ab49420ddfb12545c6bb36e14264630578a946ab9256
let g:listsyms_propagate = 0

" save folds for wiki files
set foldlevel=99
"set foldminlines=3

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" Save folds between sessions
":set sessionoptions-=options
:set sessionoptions=folds,winpos,winsize
autocmd VimEnter <silent> ~/.task/wiki/*.md :source %.vim " or BufReadPost?
autocmd BufWrite ~/.task/wiki/*.md :mksession! %.vim " or BufLeave,BufWinLeave?
" autocmd VimLeave ~/.task/wiki/*.md :mksession! %.vim

let mapleader=";"
map - <leader>
set showcmd " show incomplete leader commands
"nmap q <leader>ww
"nmap s <leader>t+
" execute on \\
nnoremap <leader><leader> :!"%:p"<Enter>
nnoremap <leader>q :q<Enter>
nnoremap <leader>w :w<Enter>
nnoremap <leader>ww :w<Enter>
nnoremap <leader>wq :wq<Enter>


" TODO make filetype specific: https://stackoverflow.com/questions/53538592/in-vimrc-apply-certain-highlighting-rules-only-for-certain-filetype
" https://vi.stackexchange.com/a/10666
autocmd FileType vimwiki nmap <buffer> <silent> <Space> :VimwikiToggleListItem<CR>
autocmd FileType vimwiki nmap <buffer> <silent> <S-d> :VimwikiToggleRejectedListItem<CR>
"
" https://stackoverflow.com/questions/9464844/how-to-get-group-name-of-highlighting-under-cursor-in-vim
function! SkipUpOrIncrement()
  if synIDattr(synID(line("."), 1, 1), "name") == 'VimwikiListTodo'
    :normal gln
  elseif stridx(expand('%'), "/diary/") >= 0
    :execute ":VimwikiDiaryPrevDay"
  else
    " jump to previous fold
    :normal zk
  endif
endfun

function! SkipDownOrDecrement()
  if synIDattr(synID(line("."), 1, 1), "name") == 'VimwikiListTodo'
    :normal glp
  elseif stridx(expand('%'), "/diary/") >= 0
    :exec ":VimwikiDiaryNextDay"
  else
    " jump to next fold
    :normal zj
  endif
endfun

function! OpenFoldOrIncreaseIndent()
  if synIDattr(synID(line("."), 1, 1), "name") == 'VimwikiListTodo'
    " increase list item level (indent-context-sensitive)
		:execute "normal \<Plug>VimwikiIncreaseLvlSingleItem"
  else
    " open fold
    :normal zo
  endif
endfun

function! CloseFoldOrDecreaseIndent()
  if synIDattr(synID(line("."), 1, 1), "name") == 'VimwikiListTodo'
    " decrease list item level (indent-context-sensitive)
		:execute "normal \<Plug>VimwikiDecreaseLvlSingleItem"
  else
    " close fold
    :normal zc
  endif
endfun

" 'untab' shortcut, now ignored/overridden by supertab...
inoremap <S-Tab> <C-D>
" save file https://vi.stackexchange.com/questions/8895/how-to-map-a-shortcut-for-saving-the-file/8897
inoremap <C-S> <Esc>:update<CR>gi

" disable ex mode (ZZ and ZQ still work for closing)
nnoremap Q <nop>

" tabline and tab navigation
nnoremap t0 :tabfirst<CR>
nnoremap t$ :tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap TT :tabclose<CR>
nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprev<CR>
nnoremap <C-P> :! pdfreport %<CR>
nnoremap <C-O> :! open %
let g:airline#extensions#tabline#enabled = 1
" show tab number instead of number of splits inside tab
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#tab_nr_type = 1


autocmd FileType vimwiki nnoremap <buffer> <silent> <S-Up> :call SkipUpOrIncrement()<CR>
autocmd FileType vimwiki inoremap <buffer> <silent> <S-Up> <Esc>:call SkipUpOrIncrement()<CR>gi
autocmd FileType vimwiki nnoremap <buffer> <silent> <S-Down> :call SkipDownOrDecrement()<CR>
autocmd FileType vimwiki inoremap <buffer> <silent> <S-Down> <Esc>:call SkipDownOrDecrement()<CR>gi
" autocmd BufRead,BufNewFile */diary/* nnoremap <buffer> <silent> <S-Up> :VimwikiDiaryPrevDay<CR>
" autocmd BufRead,BufNewFile */diary/* nnoremap <buffer> <silent> <S-Down> :VimwikiDiaryNextDay<CR>

" autocmd FileType vimwiki nmap <buffer> <S-n> :VimwikiNextTask<CR>
autocmd FileType vimwiki nnoremap <buffer> <silent> <S-Right> :call OpenFoldOrIncreaseIndent()<CR>
autocmd FileType vimwiki inoremap <buffer> <silent> <S-Right> <Esc>:call OpenFoldOrIncreaseIndent()<CR>gi
autocmd FileType vimwiki nnoremap <buffer> <silent> <S-Left> :call CloseFoldOrDecreaseIndent()<CR>
autocmd FileType vimwiki inoremap <buffer> <silent> <S-Left> <Esc>:call CloseFoldOrDecreaseIndent()<CR>gi
" add a conceal for UUIDs
" https://alok.github.io/2018/05/09/more-about-vim-conceal/
autocmd FileType vimwiki syn match TWUUID "\s#[0-9a-f\-]\{36}$" containedin=VimwikiTodo conceal
autocmd FileType vimwiki syn match TWUUID "\s#new$" containedin=VimwikiTodo conceal "VimwikiListTodo
autocmd FileType vimwiki highlight link TWUUID Keyword

" add more @context and +project syntax:  https://github.com/vimwiki/vimwiki/issues/309

