" don't be vi-co;patible
set nocompatible

" clear any existing autocmd
autocmd!

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" git-driven install of plugins and auto integration

execute pathogen#infect()


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" color scheme

if ! has("gui_running")
   set t_Co=256
endif

set background=light
colors peaksea


"""""""""""""""""""""""""""""""""""""""
" terminal settings
"
" syntax highlighting
if has('syntax') && (&t_Co > 1)
   syntax enable
endif

" history buffer
set history=50

" rehighlight off
"set viminfo='10,f1,<500,h

" displays in status line
set showmode
set showcmd

" don't have files override this .vimrc
set nomodeline

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" filetype detection
filetype plugin indent on


""""""""""""""""""""""""""""""""""""""""""""""""""""""
" text formatting
"
" syntax highlighting

syntax on

" wrapping
set nowrap
set formatoptions-=t " no auto-wrap, except for comments
set textwidth=128

" line numbers
set number
set nuw=6

" indents
set shiftwidth=3
set expandtab
set autoindent

" auto insertion of comment leaders
autocmd FileType c,cpp set formatoptions+=ro

" left aligned c,cpp comment starting with /**, middle **, ending with **/
autocmd FileType c,cpp set comments-=s1:/*,mb:*,ex:*/
autocmd FileType c,cpp set comments+=s1:/*!,mb:**,ex:*/,sr:/**,mb:**,ex:*/ 

" autocompletion
autocmd FileType c,cpp iab /*** /******************************************************************************

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" help

" goto next help bookmark in the current buffer
nmap <s-b> /<bar>:\?\(\S\+-\?\)\+<bar><cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" moveing
nmap <s-h> <c-w><
nmap <s-j> <c-w>-
nmap <s-k> <c-w>+
nmap <s-l> <c-w>>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
let NERDTreeDirArrows=0
nmap <s-q> :NERDTreeFind<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" taglist
nmap <s-w> :TlistToggle<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""
" conque term
let g:ConqueTerm_ReadUnfocused = 1
nmap <s-a> :ConqueTermSplit bash<cr>
