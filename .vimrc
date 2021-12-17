"" auto install plugins not installed
" if dein#check_install(['vimproc'])
"     call dein#install(['vimproc'])
" endif

filetype plugin indent on

" incsearch settigns
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ?
        \ '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFugitive()
    try
        if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
            return fugitive#head()
        endif
    catch
        endtry
        return ''
endfunction

function! MyFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
    return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
    return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

" use flake8 for python lint checker
let g:syntastic_python_checkers = ['flake8']

" syntastic highlight

" 256 color on screen
if $TERM == 'screen'
    set t_Co=256
endif

" set colorscheme
set background=dark
syntax enable

" filetype settings
au BufRead,BufNewFile {*.md,*.txt} set filetype=markdown
au BufRead,BufNewFile {*.coffee} set filetype=coffee
" autocmd filetype coffee,javascript setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

" open with last cursor position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\""


"---org---
" General parameter
" encode
set encoding=utf-8
scriptencoding utf-8

" initialize
augroup vimrc
  autocmd!
augroup END

" basic
set number
set cursorline
hi clear CursorLine
set virtualedit+=block
set laststatus=2
set statusline=%f%m%=%l,%c\ %{'['.(&fenc!=''?&fenc:&enc).']\ ['.&fileformat.']'}
set cmdheight=2
set showmatch
set matchpairs+=<:>
set helpheight=999
set list
set listchars=tab:>-,trail:-,nbsp:%,eol:$

" window
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
set scrolloff=5
set sidescrolloff=5
set sidescroll=1
set wrap
set linebreak
set colorcolumn=80
set laststatus=5
set showcmd
set wildmode=longest:full,full
set synmaxcol=200

" file save 
set confirm
set hidden
set autoread

" search & replace
set hlsearch
set incsearch
set wrapscan
set gdefault
set ignorecase
set smartcase

" Tab & Indent
"set smartindent
"set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
"set smarttab
"set cindent
set textwidth=0


" Clipboard
set clipboard=unnamed,unnamedplus,autoselect

" mouse
set mouse=

" for windows path
set shellslash
" language server set up
call plug#begin('~/.vim/plugged')
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/async.vim'
call plug#end()
" vimrc
" デバッグ用設定
let g:lsp_log_verbose = 1  " デバッグ用ログを出力
let g:lsp_log_file = expand('~/.cache/tmp/vim-lsp.log')  " ログ出力のPATHを設定

" 言語用Serverの設定
augroup MyLsp
  autocmd!
  " pip install python-language-server
  if executable('pyls')
    " Python用の設定を記載
    " workspace_configで以下の設定を記載
    " - jediの定義ジャンプで一部無効になっている設定を有効化
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': { server_info -> ['pyls'] },
        \ 'whitelist': ['python'],
        \ 'workspace_config': {'pyls': {'plugins': {
        \   'pycodestyle': {'enabled': v:true},
        \   'jedi_definition': {'follow_imports': v:true, 'follow_builtin_imports': v:true},}}}
        \})
    autocmd FileType python call s:configure_lsp()
  endif
augroup END
" 言語ごとにServerが実行されたらする設定を関数化
function! s:configure_lsp() abort
  setlocal omnifunc=lsp#complete   " オムニ補完を有効化
  " LSP用にマッピング
  nnoremap <buffer> <C-]> :<C-u>LspDefinition<CR>
  nnoremap <buffer> gd :<C-u>LspDefinition<CR>
  nnoremap <buffer> gD :<C-u>LspReferences<CR>
  nnoremap <buffer> gs :<C-u>LspDocumentSymbol<CR>
  nnoremap <buffer> gS :<C-u>LspWorkspaceSymbol<CR>
  nnoremap <buffer> gQ :<C-u>LspDocumentFormat<CR>
  vnoremap <buffer> gQ :LspDocumentRangeFormat<CR>
  nnoremap <buffer> K :<C-u>LspHover<CR>
  nnoremap <buffer> <F1> :<C-u>LspImplementation<CR>
  nnoremap <buffer> <F2> :<C-u>LspRename<CR>
endfunction
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
