" Compatibility
set nocompatible " disable compatibility to old-time vi


set showmatch " show matching 
set ignorecase " case insensitive


" Mouse
set mouse=v " middle-click paste with 
set mouse=a " enable mouse click


" Search
set hlsearch " highlight search 
set incsearch " incremental search


" Indenting
set tabstop=4 " number of columns occupied by a tab 
set softtabstop=4 " see multiple spaces as tabstops so <BS> does the right thing
set expandtab " converts tabs to white space
set shiftwidth=4 " width for autoindents
set autoindent " indent a new line the same amount as the line just typed
filetype plugin indent on "allow auto-indenting depending on file type


" Appearance
" Editor
set number " add line numbers
set relativenumber "set relative line numbers
set cursorline

set cc=80 " set an 80 column border for good coding style
syntax on " syntax highlighting
filetype plugin on


" Completion, suggestions
set wildmode=longest,list " get bash-like tab completions


" Unused
"set clipboard=unnamedplus " using system clipboard
