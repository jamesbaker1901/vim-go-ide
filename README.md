# Vim as a Go IDE
This repo serves as a guide on how to set up and use [Neovim](https://neovim.io/) as a golang IDE on OSX (10.15.6), though most of this will also apply to Linux. Included are copies of my personal dotfiles and settings for neovim, coc, etc. that make Go development in vim a joy.

## Why Vim?
Vim is more than simply a text editor, it's a [language](https://www.youtube.com/watch?v=wlR5gYd6um0) unto itself in a sense. As a developer, or in my case Site Reliability Engineer, the vast majority of our work consists of editing text files. Often that means writing code in our language of choice, but it also includes editing countless yaml and json files, composing emails, editing various configuration files, etc. The classic vim keybindings, modes, and concepts provide a common framework for editing _any_ text extremely quickly and easily. Using the timesaving vim keybindings makes even more sense when we consider that developers and SREs are editing _existing_ files the majority of time, i.e., we're not writing code from scratch, we're simply making changes or additions to existing code bases. Vim's ability to quickly move around a project or file, replace and duplicate text, etc. makes it even more powerful here ... and with the addition of some useful plugins and config changes, we can take that speed to a whole new level.

IDEs are custom built to be extremely useful for a particular language: code completion, syntax checking, built in debugging, git support, integration with Docker and other fancy bells and whistles make using an IDE very attractive. All of that comes with a price though: performance. IDEs tend to be rather resource hungry. Throw in Chrome's constant hunger for ram, the recent proliferation Electron desktop apps, and the many stackoverflow tabs kept open to effectively write code and a lesser system can slow to a crawl while compiling or running demanding code. And while most IDEs support a "vim mode," I've personally never found these settings and plugins as effective as the real thing.

So devs were left with the choice of a minimal dev experience in Vim (excellent text editing ability, and performant application) and the warm, but heavy embrace of an IDE (amazing features but at a price). But with the recent advent of mature [language servers](https://langserver.org/) and plugins to support them, with a bit of work those of us who love Vim and the terminal life no longer need to sacrifice the features that an IDE brings to the table.

## Prereqs
We'll need several additional tools before getting started with our vim set up.

#### xcode & brew
```
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

#### neovim python3 yarn
This will install neovim, python 3, and yarn. Python 3 and yarn are required for the coc plugin and some of its plugins.
```
brew install neovim python yarn
```

#### install nodejs
nodejs is required by coc.
```
curl -sL install-node.now.sh/lts | bash
```

#### Optionally alias nvim to vim
The rest of this guide assumes you've alias'd `nvim` to `vim` in your `~/.zshrc` or `~/.bashrc`. The NeoVim binary is called `nvim` and if you wish to use it as a complete replacement for vim as I do, you'll need to set up this alias or remember to call `nvim` whenever this guide specifices `vim`.
```
# add this line to your shell's rc file
alias vim='/usr/local/bin/nvim'
```

#### python nvim packages
We'll need these for additional coc plugins later. If you use [pyenv](https://github.com/pyenv/pyenv) or something similar then you may not want to use the system python for this. I personally don't write much python code (and when I do, I used a container to avoid path and env issues) so I went this route. In any case, neovim and coc need to be able to find a python executable that can import pynvim.
```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python2 get-pip.py
python2 -m pip install --user --upgrade pynvim
python -m pip install --user --upgrade pynvim
```

#### golang
If you're reading this you probably already have Go installed, but if not you can grab it here: [https://golang.org/doc/install](https://golang.org/doc/install).

## Neovim & Vim-Plug
On OSX, there are several vim options. There's the system default vim at `/usr/bin/vim`, [MacVim](https://github.com/macvim-dev/macvim), GUI options for each of those, etc. Those are fine choices, but NeoVim has several advantages over vim (namely async). We installed neovim in the [prereqs](#Prereqs) adding plugin manager. Let's setup [Vim-Plug](https://github.com/junegunn/vim-plug) next. The rest of this guide should work just fine with other vim plugin managers, but I've found vim-plug to be the best.

#### Install Vim-Plug
```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

Now create and edit this file: `~/.config/nvim/init.vim`. `init.vim` is neovim's equivalent to `~/.vimrc`. Pro-tip: create an alias to quickly access it, like so `alias vimrc='vim ~/.config/nvim/init.vim`.

```
# add these lines to ~/.config/nvim/init.vim
" vim-plug 
" add plugins below this line, but before call plug#end
-call plug#begin('~/.vim/plugged')

call plug#end()

```

#### Optionally install fzf & ripgrep
These tools will make using vim as an IDE _even better_, but they aren't specific to supporting Go development.
[ripgrep](https://github.com/BurntSushi/ripgrep) is a line-oriented search tool that recursively searches your current directory for a regex pattern. [fzf](https://github.com/junegunn/fzf) is a general-purpose command-line fuzzy finder. Integrating these two into vim will make it extremely easy and fast to move to any part of even the largest project. They're also very useful on the command line. I highly recommend you checkout their git README's to see just how useful they can be.
```
brew install fzf ripgrep
```

## vim-go and coc
For years, Go support in vim was handled mostly by the amazing [vim-go](https://github.com/fatih/vim-go) project. We'll still install and use some of its features here, but many of its functions will now be supplanted by the amazing [Conquer of Completion](https://github.com/neoclide/coc.nvim) aka coc. These two plugins will provide the bulk of the IDE features we're used to in other editors.

#### Installing vim-go and coc
Add these two lines to your `~/.config/nvim/init.vim` file after the call `plug#begin('~/.vim/plugged')` line.
```
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
```
Save your `init.vim` and then enter `:PlugInstall` in vim. This is how plugins are installed with vim-plug, and will need to be run every time you add a new plugin.

The `:GoUpdateBinaries` and `yarn install --frozen-lockfile` bits will install some additional dependencies for vim-go and coc, just wait on them to finish.

Once those additional dependencies are finished installing, We have a few more steps before we're ready to start coding. If you're only interested in configuring vim for LSP support then I'd recommend checking out these helpful blog posts:
* [https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/](https://octetz.com/docs/2019/2019-04-24-vim-as-a-go-ide/)
* [https://medium.com/@furkanbegen/go-development-with-vim-79cfa0a928b0](https://medium.com/@furkanbegen/go-development-with-vim-79cfa0a928b0)

They'll give you the context and configuration to get going with vim-go and coc, without all of the extra steps of this guide, if you already have your own plugins and shortcuts or simply don't want such things.

#### Configuring vim-go and coc
These settings are pretty basic for vim-go, add them to your `~/.config/nvim/init.vim`:
```
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
```

Now to configure coc:
```
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
```
Alternatively if you don't already have an `init.vim` file, you can use the one from this repo as the basis for your own. It has many additional tweaks and changes that I find useful for Go development and general vim use.

```
mkdir -p ~/.config/nvim
cp init.vim ~/.config/nvim/
```

#### Installing additional Plugins
Let's install some *more* helpful plugins :) Our goal is to make vim into a super charged Go IDE. The core functionality required is handled by vim-go and coc, but we want more than just completion. Add these plugins to your `~/.config/nvim/init.vim` and install them with `:PlugInstall`.

```
" Coding Help
Plug 'Raimondi/delimitMate'                   " auto-close delimiters
Plug 'tpope/vim-fugitive'                     " git helper
Plug 'scrooloose/nerdtree'                    " file browswer
Plug 'preservim/nerdcommenter'                " comment lines easily
Plug 'junegunn/fzf' 			      " fuzzy finder
Plug 'junegunn/fzf.vim' 		      " fuzzy finder
Plug 'jeffkreeftmeijer/vim-numbertoggle'      " toggles relative or static line nums
Plug 'Xuyuanp/nerdtree-git-plugin' 	      " NERDTree git status
```
If you find that one or more of these plugins isn't for you, you can easily remove them by just deleting or commenting out the line in you `init.vim`, reloading vim, and then doing `:PlugClean`. `vim-plug` will remove the plugin locally.

## CoC and Vim-Go Use
### Completion
With coc and vim-go installed and configured, code completion should be working out of the box. Open up a go project and try it!

_Insert fancy gif here!_

As you type, suggested completions will appear beneath your cursor automatically in a little pop up menu. Navigate this menu with `<ctrl>+n` and `<ctrl>+p` to move up and down and hit `<tab>` to use a selection. As you continue to type, the pop up menu will automatically restrict the possible suggestions. Not only will you get the nice pop up window with suggested completions, function definitions will be displayed next to their signatures in a separate pop up window!

Coc will use the current project and any packages you have imported to populate its suggestions. So if you type `fmt.` and don't see any suggestions, it's because you haven't imported the `fmt` package yet.

### Goto's and Shortcuts
These are all entered in normal mode, by placing the cursor over the object you wish to define/see docs to/etc.

| keystroke | Description |
| --- | ----------- |
| `gd` | *Go to func definition* `gd` will open a new buffer with the source code definition of the function or method. |
| `gy` | *Go to type definition* `gy` will take you to the definition of a type or interface. |
| `gi` | *Show Implements* `gy` will open a new window, showing all the interfaces the selected type implements. |
| `gr` | *Show References* `gr` will open a new window, showing all references of the selected function or method.|
| `U` | *Show GoDoc* `U` (`<shift>+u`) will display the GoDoc for a selected function in a pop up window. |
| `,rn` | *Rename* `,rv` (`<leader>rn`) will rename the selected variable/func/etc. and all referenced instances of it. |

## File/Project Navigation with NERDTree
The excellent [NERDTree](https://github.com/preservim/nerdtree) plugin gives us a nice little file browser in a right aligned window by pressing `<ctrl>+n`

_insert fancy gif here!_

We can get move back to the main editing window without closing NERDTree with the shortcut `<ctrl>+ww`, otherwise, `<ctrl>+n` will close the NERDTree window and return focus to our previous editing window.

If you enjoy having the NERDTree file browser displayed automatically when starting vim, add the following to your `init.vim`: 
```
autocmd vimenter * NERDTree
```

Because we also installed the [nerdtree-git-plugin](https://github.com/Xuyuanp/nerdtree-git-plugin) we'll have git status displayed in the NERDTree menu when we're in a git project.

#### fzf and ripgrep
[fzf]https://github.com/junegunn/fzf and it's correspoding vim plugin [fzf.vim](https://github.com/junegunn/fzf.vim) with its [ripgrep](https://github.com/BurntSushi/ripgrep) integration _really_ make vim extremely powerful. I've included the most useful fzf.vim commands, but there are more documented on the project's github. 

Commands
--------

| Command           | List                                                                    |
| ---               | ---                                                                     |
| `:Files [PATH]`   | Files (runs `$FZF_DEFAULT_COMMAND` if defined)                          |
| `:GFiles [OPTS]`  | Git files (`git ls-files`)                                              |
| `:GFiles?`        | Git files (`git status`)                                                |
| `:Buffers`        | Open buffers                                                            |
| `:Colors`         | Color schemes                                                           |
| `:Rg [PATTERN]`   | [rg][rg] search result (`ALT-A` to select all, `ALT-D` to deselect all) |
| `:Lines [QUERY]`  | Lines in loaded buffers                                                 |
| `:BLines [QUERY]` | Lines in the current buffer                                             |
| `:Locate PATTERN` | `locate` command output                                                 |
| `:History`        | `v:oldfiles` and open buffers                                           |
| `:History:`       | Command history                                                         |
| `:History/`       | Search history                                                          |
| `:Snippets`       | Snippets ([UltiSnips][us])                                              |
| `:Commits`        | Git commits (requires [fugitive.vim][f])                                |
| `:BCommits`       | Git commits for the current buffer                                      |

In my view the most useful is the ripgrep integration: `:Rg [PATTERN]`, where `[PATTERN]` is a string on a line somewhere in a project's files. This will use ripgrep to quickly search your project (ignoring things in .gitignore) and pipe the results, any lines where your pattern matched, to fzf where you can now use fuzzy finding to quickly narrow the results to the exact line you need. Hit enter and be taken immediately to the line, in a new buffer if vim has to open a new file, or in an existing buffer if you already have that file open.

`:Commits` can simplify orking on large git projects with many commits finding the right one. `:Colors` is quite useful as well for quickly changing between your many vim color schemes. Definitely dive in with fzf.vim (as well as its cli version) ... it's quite an amazing tool!


## Debugging
This guide is getting quite long, so I won't cover debugging at this time, but this post [Debugging With Vim Go](https://l-lin.github.io/post/2020/2020-02-10-debug-with-vim-go/) can get you started with the basics.

## Snippets
TODO expand this
https://github.com/neoclide/coc-snippets
https://github.com/SirVer/ultisnips/blob/master/doc/UltiSnips.txt
https://github.com/fatih/vim-go/blob/master/gosnippets/UltiSnips/go.snippets

## Commenting
TODO expand this
https://github.com/preservim/nerdcommenter

## Git
#### vim-fugitive
TODO expand this
https://github.com/tpope/vim-fugitive

## vim-colors
TODO expand this
https://vimcolors.com/

## General Vim Tricks
These suggestions are not specific to writing go in vim, and are more personal preference than anything, but in my experience they are extremely useful.

#### Remap leader
By default the `<leader>` key in vim is `\`. Feel free to keep it, but comma `,` is far easier to reach and use. Since many subsequent shortcuts involve the `<leader>` key it makes sense to set it to something easily accessible. The timeout setting is optional, it simply gives you a bit more grace between pressing the leader key and whatever keys follow. It will definitely be helpful as you're learning new shortcuts.
```
let mapleader = ","
set timeout timeoutlen=1500
```

#### Time Saving Remaps
Exiting insert mode to return to normal mode in vim is one of the most common operations you'll do using vim, yet to do so by default requires moving your finger up to the wasteland of the Function keys at the top of the keyboard to hit the escape key ... so far to travel for such a common operation! `imap ;; <esc>` remaps `;;` to escape, just type it in quick succession to exit insert mode. If you _do_ actually need to type two semi-colons, just type them slowly.

Another common operation is exiting insert mode to save the file. `nmap ; :w<CR>` sets `;` to `:w` when in normal mode. Now, `;;;` while in insert mode will return you to normal mode and save your progress, all without your fingers leaving the home keys! And when it's time to close vim just hit `,q` in normal mode. Finally, `,qq` will force quit, for those times when you don't want to save and just need to exit vim
```
"general remaps
imap ;; <esc>
nmap ; :w<CR>
nmap <leader>q :q<CR>
nmap <leader>qq :q!<CR>
```

#### Navigating Buffers Remaps
As we're using [NERDTree](https://github.com/preservim/nerdtree) as a way to open some files, we'll be using buffers. Vim buffers are text held in memory that can be easily switched between. They will usually correspond to a file we've opened, but you can also create an empty buffer with `:new` as a quick place to stash some text. There are also tabs and windows, but we'll leave those for another guide. With our setup, it will be easy enough to move between or search through our buffers to find the text/code that we want.

With these remaps below, `<ctrl>+j` and `<cntrl>+k` will cycle through the open buffers: maintaining the `jk` navigation convention from normal mode and keeping our fingers on the home keys. `<ctrl>+d` will close a buffer, hopefully taking advantage of muscle memory from the same shortcut in bash to exit the current shell.

The mouse remaps may seem unnecessary (isn't the whole point of this guide _not_ to use the mouse?!), but if you happen to have your hand your mouse from interacting with the OS, entering or exiting insert mode with right click makes sense as that is an extremely common operation.
```
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
```

