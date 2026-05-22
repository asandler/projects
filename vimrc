set nocompatible

syntax on
filetype plugin indent on

set nowrap
set number
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set ruler
set rulerformat=%40(%t%=[0x%B\ \ %l,%c\ %p%%]%)
set ignorecase
set smartcase
set backspace=indent,eol,start
set background=dark
set smartindent
set autoindent
set fileencodings=ucs-bom,utf-8,default,cp1251,latin1
set tags+=tags;/
set viminfo='10,\"100,:20,%,n~/.viminfo
set hidden
set autoread
set confirm
set wildmenu
set wildmode=longest:full,full
set wcm=<Tab>

augroup filetype_settings
  autocmd!
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete commentstring=#%s foldmethod=indent softtabstop=4 shiftwidth=4
  autocmd FileType html setlocal omnifunc=htmlcomplete#CompleteTags commentstring=<!--%s-->
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags commentstring=<!--%s-->
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType php setlocal omnifunc=phpcomplete#CompletePHP
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType c setlocal omnifunc=ccomplete#Complete
  autocmd FileType go nnoremap <buffer> <silent> <F6> :write<CR>:silent !gofmt -w %:p<CR>:edit!<CR>:redraw!<CR>
augroup END

menu EOL.unix :setlocal fileformat=unix<CR>
menu EOL.dos  :setlocal fileformat=dos<CR>
menu EOL.mac  :setlocal fileformat=mac<CR>
nnoremap <F7> :emenu EOL.<Tab>

menu Enc.cp1251  :edit ++enc=cp1251<CR>
menu Enc.koi8-r  :edit ++enc=koi8-r<CR>
menu Enc.cp866   :edit ++enc=ibm866<CR>
menu Enc.utf-8   :edit ++enc=utf-8<CR>
menu Enc.ucs-2le :edit ++enc=ucs-2le<CR>
nnoremap <F8> :emenu Enc.<Tab>

menu Compile.g++ :execute '!g++ ' . shellescape(expand('%')) . ' -Wall -pedantic -std=c++17 -o ' . shellescape(expand('%:r'))<CR>
menu Compile.gcc :execute '!gcc ' . shellescape(expand('%')) . ' -Wall -pedantic -std=c99 -o ' . shellescape(expand('%:r'))<CR>
nnoremap <F9> :emenu Compile.<Tab>

nnoremap <F2> :make!<CR>
nnoremap <F3> :%s/\(\S\)\(\s\{2,}\)\(\S\)/\1 \3/g<CR>
nnoremap <F4> [I:let nr = input("Which one: ")<Bar>execute "normal " . nr . "[\t"<CR>
nnoremap <F5> :FSHere<CR>

nnoremap <F10> :execute '!' . shellescape('./' . expand('%:r'))<CR>
nnoremap <C-F10> :execute '!pdflatex ' . shellescape(expand('%'))<CR>
nnoremap <C-F11> :!clear<CR>

nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

nnoremap <silent> <PageUp> <C-U><C-U>
vnoremap <silent> <PageUp> <C-U><C-U>
inoremap <silent> <PageUp> <C-\><C-O><C-U><C-\><C-O><C-U>

nnoremap <silent> <PageDown> <C-D><C-D>
vnoremap <silent> <PageDown> <C-D><C-D>
inoremap <silent> <PageDown> <C-\><C-O><C-D><C-\><C-O><C-D>

nnoremap <A-PageDown> gt
nnoremap <A-PageUp> gT
