syntax on
set nowrap
set nocompatible
set number
set expandtab "insert spaces instead of tab
set softtabstop=4
set shiftwidth=4
set rulerformat=%40(%t%=[0x%B\ \ %l,%c\ %p%%]%)
set ruler
set ignorecase
set backspace=2
set background=dark
set smartindent
set autoindent
set fileencodings=ucs-bom,utf-8,default,cp1251,latin1
set tags+=tags;/
set viminfo='10,\"100,:20,%,n~/.viminfo

autocmd FileType python set omnifunc=pythoncomplete#Complete commentstring=#%s# foldmethod=indent | %foldopen! | set softtabstop=4 | set shiftwidth=4
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags commentstring=<!--%s-->
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags   commentstring=<!--%s-->
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType c set omnifunc=ccomplete#Complete

" when we reload, tell vim to restore the cursor to the saved position
augroup JumpCursorOnEdit
 au!
 autocmd BufReadPost *
 \ if expand("<afile>:p:h") !=? $TEMP |
 \ if line("'\"") > 1 && line("'\"") <= line("$") |
 \ let JumpCursorOnEdit_foo = line("'\"") |
 \ let b:doopenfold = 1 |
 \ if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
 \ let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
 \ let b:doopenfold = 2 |
 \ endif |
 \ exe JumpCursorOnEdit_foo |
 \ endif |
 \ endif
 " Need to postpone using "zv" until after reading the modelines.
 autocmd BufWinEnter *
 \ if exists("b:doopenfold") |
 \ exe "normal zv" |
 \ if(b:doopenfold > 1) |
 \ exe "+".1 |
 \ endif |
 \ unlet b:doopenfold |
 \ endif
augroup END

function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction

" Encodings
"<F7> EOL format (dos <CR><NL>,unix <NL>,mac <CR>)
    set  wildmenu
    set  wcm=<Tab>
    menu EOL.unix :set fileformat=unix<CR>
    menu EOL.dos  :set fileformat=dos<CR>
    menu EOL.mac  :set fileformat=mac<CR>
    menu EOL.my_win2unix :%s /\r\n/\r/g<CR>
    map  <F7> :emenu EOL.<Tab>
"<F8> Change encoding
    set  wildmenu
    set  wcm=<Tab>
    menu Enc.cp1251  :e ++enc=cp1251<CR>
    menu Enc.koi8-r  :e ++enc=koi8-r<CR>
    menu Enc.cp866   :e ++enc=ibm866<CR>
    menu Enc.utf-8   :set encoding=utf8<CR>
    menu Enc.ucs-2le :e ++enc=ucs-2le<CR>
    map  <F8> :emenu Enc.<Tab>
"<F9> Compilation
    set  wildmenu
    set  wcm=<Tab>
    menu Compile.g++ :!g++ % -Wall -pedantic -std=c++1z -o %< <CR>
    menu Compile.gcc :!gcc % -Wall -pedantic -std=c99 -o %< <CR>
    map  <F9> :emenu Compile.<Tab>

map <F2> :make!<CR>

"delete all whitespaces between words
map <F3> :%s/\(\S\)\(\s\{2,}\)\(\S\)/\1\ \3/g<CR>

map <F4> [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
map <F5> :FSHere<CR>

map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

map <F10> :!./%<<CR>
map <C-F10> :!pdflatex %<<CR>
map <C-F11> :!clear<CR>

nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP

nnoremap <silent> <PageUp> <C-U><C-U>
vnoremap <silent> <PageUp> <C-U><C-U>
inoremap <silent> <PageUp> <C-\><C-O><C-U><C-\><C-O><C-U>

nnoremap <silent> <PageDown> <C-D><C-D>
vnoremap <silent> <PageDown> <C-D><C-D>
inoremap <silent> <PageDown> <C-\><C-O><C-D><C-\><C-O><C-D>

vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv
