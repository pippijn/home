set encoding=utf-8            " required for YCM
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Plugins go here
Plugin 'cappyzawa/starlark.vim'
Plugin 'nanotech/jellybeans.vim'
Plugin 'ycm-core/YouCompleteMe'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" User settings here.
let g:ycm_confirm_extra_conf = 0

set ttimeoutlen=10
set expandtab

au BufEnter *.[ch],*.hs						:set sw=4
au BufEnter *.yaml,*.yml,*.sh					:set sw=2

set nowrap
set viminfo='500,\"800

nnoremap <C-l> :noh<CR><C-l>
