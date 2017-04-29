set encoding=utf-8
syntax enable
set background=dark
colorscheme solarized-patched
"colorscheme base16-default
set spell spelllang=en_us

set mouse=a

"Enable filetype detection, etc.
filetype on
filetype plugin on
filetype indent on

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
"Disable auto-commenting for all filetypes
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
"Allow backspacing over autoindent, line breaks, and start of insert
set backspace=indent,eol,start

set number    "Show line numbers in gutter
set showcmd
set cursorline
set showmatch "Show matching brackets
set ruler     "Show cursor position in status bar 
set colorcolumn=80

set incsearch  "Do interactive searching
set hlsearch   "Highlight search results
set ignorecase "Ignore case for search (use "\C" anywhere in search pattern to
               "override, e.g. "/Example\C"
"set smartcase "For now, rather be intentional

"Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

"Always open explorer mode in tree-view
let g:netrw_liststyle=3


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUG-INS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
execute pathogen#infect()

" indentLines
let g:indentLine_enabled = 1
"let g:indentLine_color_term = 0   "For base16-default
let g:indentLine_color_term  = 235 "For solarized-patched
