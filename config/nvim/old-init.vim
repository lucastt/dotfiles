"" Generics --------------------------------------------------------------

set nocompatible                " no vi around here
set belloff=all                 " I hate bell sounds...
set nobackup                    " I like to live life dangerously


"" Editing --------------------------------------------------------------

filetype on                     " Enable file detection
filetype plugin on              " Enable plugin based on filetype
filetype indent on              " Load an identfile based on filetype

syntax on                       " Syntax highlight
set ruler                       " Separate line number from text
set number                      " Show line numbers
"set cursorline                  " highligh cursor line
set showmatch	                " Highlight matching brace

set autoindent	                " Auto-indent new lines
set shiftwidth=4                " Shift width to 4 spaces
set tabstop=4                   " Tab width to 4 spaces
set smarttab	                " Enable smart-tabs
set expandtab                   " Use spaces instead of tab

set scrolloff=10                " Max lines per scroll 10
set mouse=a
set clipboard=unnamed           " y will use regular clipboard, no need to "+y
                                " to copy it to the clipboard buffer

set backspace=indent,eol,start	" Backspace behaviour


"" Searching --------------------------------------------------------------

set hlsearch	                " Highlight all search results
set smartcase	                " Enable smart-case search
set ignorecase	                " Always case-insensitive
set incsearch	                " Searches for strings incrementally


"" History and memory ----------------------------------------------------

set history=1000
set undolevels=1000


"" Auto completion --------------------------------------------------------

set wildmenu                    " Enable autocomplete on TAB for cmd line
set wildmode=list:longest       " Wildmenu behavior (should be bash completion like)
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx


"" Code folding -----------------------------------------------------------

" ... ?

"" Dinamic identation -----------------------------------------------------

" if html or js indent with 2 spaces
autocmd Filetype html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd Filetype js setlocal tabstop=2 shiftwidth=2 expandtab
autocmd Filetype vue setlocal tabstop=2 shiftwidth=2 expandtab
autocmd Filetype css setlocal tabstop=2 shiftwidth=2 expandtab


"" Keyboar mappings ------------------------------------------------------

" no one is really happy until you have this mappings
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev QA qa
cnoreabbrev Qall qall


" split remaps:

" Navigate the split view with CTRL+j, CTRL+k, CTRL+h, or CTRL+l
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" ALT instead of CTRL because mac is so stupid.
" Resize split views with  ALT+UP, ALT+DOWN, ALT+LEFT, or ALT+RIGHT
noremap <a-up> <c-w>+
noremap <a-down> <c-w>-
noremap <a-left> <c-w>>
noremap <a-right> <c-w><

"" Usefull tricks -----------------------------------------------------

" Executed command selected in visual mode
vnoremap <c-e> Y:'<,'>w !sh -x<CR>
