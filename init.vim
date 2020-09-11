call plug#begin('~/.vim/plugged')
" Language Support
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'fatih/vim-go'

" Coding help
Plug 'Raimondi/delimitMate'                   " auto-close delimiters
Plug 'tpope/vim-fugitive'                     " git helper
Plug 'scrooloose/nerdtree'                    " file browswer
Plug 'jpalardy/vim-slime'                     " send commands to tmux
Plug 'preservim/nerdcommenter'                " comment lines easily
Plug 'Xuyuanp/nerdtree-git-plugin' 	      " NERDTree git status

" General
Plug '907th/vim-auto-save'
Plug 'tpope/vim-obsession'                    " save vim session
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Editing
Plug 'jeffkreeftmeijer/vim-numbertoggle'      " toggles relative or static line nums
call plug#end()

let mapleader = "," 		" remap leader key
set timeout timeoutlen=1500 	" increase timeout after leader key press
set t_Co=256 			" set 256 color
set encoding=utf-8 		" set encoding to utf-8
set number 			" display line numbes
set nocompatible                " Enables us Vim specific features
filetype off                    " Reset filetype detection first ...
filetype plugin indent on       " ... and enable filetype detection
filetype plugin on 		" 
set ttyfast                     " Indicate fast terminal conn for faster redraw
set mouse=a 			" enable mouse
set laststatus=2                " Show status line always
set encoding=utf-8              " Set default encoding to UTF-8
set autoread                    " Automatically read changed files
set autoindent                  " Enabile Autoindent
set backspace=indent,eol,start  " Makes backspace key more powerful.
set incsearch                   " Shows the match while typing
set hlsearch                    " Highlight found searches
set noerrorbells                " No beeps
set number                      " Show line numbers
set showcmd                     " Show me what I'm typing
set noswapfile                  " Don't use swapfile
set nobackup                    " Don't create annoying backup files
set splitright                  " Vertical windows should be split to right
set splitbelow                  " Horizontal windows should split to bottom
set autowrite                   " Automatically save before :next, :make etc.
set hidden                      " Buffer should still exist if window is closed
set fileformats=unix,dos,mac    " Prefer Unix over Windows over OS 9 formats
set noshowmatch                 " Do not show matching brackets by flickering
set noshowmode                  " We show the mode with airline or lightline
set ignorecase                  " Search case insensitive...
set smartcase                   " ... but not if begins with upper case
set nocursorcolumn              " Do not highlight column (speeds up highlighting)
set lazyredraw                  " Wait to redraw
set clipboard=unnamed  		" Use system clipboard
syntax on

"general remaps
imap ;; <esc>
nmap ; :w<CR>
nmap <leader>q :q<CR>
nmap <leader>qq :q!<CR>
command! W :w

"next buffer
noremap <C-j> :bn<CR> 
"previous buffer
noremap <C-k> :bp<CR>
"close buffer
noremap <C-d> :bd<CR>
"exit normal mode
imap <RightMouse> <Esc>
"enter insert mode
nmap <RightMouse> i<LeftMouse>

" Enable folding
set foldmethod=indent
set foldlevel=99

" set defaults for various file types
au BufNewFile,BufRead *.go
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix|

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |

au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |

" NERDTree
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let g:NERDTreeGitStatusUseNerdFonts = 1 "

match Todo /\s\+$/

" Nerd Commenter
let g:NERDSpaceDelims = 1 		" Add spaces after comment delimiters by default
let g:NERDCompactSexyComs = 1 		" Use compact syntax for prettified multi-line comments
let g:NERDDefaultAlign = 'left' 	" Align line-wise comment delimiters flush left instead of following code indentation

" vim-go stuff
set autowrite
" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

autocmd FileType go nmap <leader>r <Plug>(go-run)
autocmd FileType go nmap <leader>t <Plug>(go-test)
let g:go_fmt_command = "goimports"

run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

" coc.vim settings
set cmdheight=2 	" Better display for messages
set updatetime=300 	" Smaller updatetime for CursorHold & CursorHoldI
set shortmess+=c 	" don't give |ins-completion-menu| messages.
set signcolumn=yes 	" always show signcolumns

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" 
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>"

" Make <tab> used for trigger completion, completion confirm, snippet expand and jump like VSCode.
 inoremap <silent><expr> <TAB>
       \ pumvisible() ? coc#_select_confirm() :
       \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
       \ <SID>check_back_space() ? "\<TAB>" :
       \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
let g:go_auto_sameids = 0

set statusline^=%{coc#status()}%{get(b:,’coc_current_function’,’’)}

