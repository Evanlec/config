"Vimrc -- Author Evan LeCompte
" Set nocompatible first
set nocompatible

set nowrap
set linebreak
set showbreak=>\

set history=1000

set mouse=a
set ttymouse=xterm2

set ttimeoutlen=100

set fileencodings=ucs-bom,utf-8,windows-1252,default

set iskeyword+=_,$,@,%,# " none of these should be word dividers, so make them not be
set iskeyword-=/
"set lazyredraw
set listchars=tab:>-,trail:-
"hide buffers when not displayed
set hidden

"maybe these speed things up?
set ttyfast 
set ttyscroll=1
let loaded_matchparen = 1

set viminfo='20,<50,s10,h,%
"new persistent undo feature (vim 7.3)
set undofile
set undodir=~/.vim/undo

" extended % matching
runtime macros/matchit.vim

" search
set nohls
set incsearch
set showmatch
set ignorecase
set smartcase

"store .swp files in central location
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" intuitive backspacing in insert mode
set backspace=indent,eol,start
" identing
filetype on
filetype plugin on
filetype indent on
set tabstop=8
set shiftwidth=2
set softtabstop=2
set copyindent
set shiftround " when at 3 spaces, and I hit > ... go to 4, not 5
set expandtab
set smarttab

" command mode
set wildmenu
set wildmode=list:longest,full

" copy / pasting
set clipboard=unnamed
set clipboard+=unnamed
" make Ctrl-C behave like in windows
vnoremap <C-c> "+y

" {{{ -[ Look ]-
" general
syntax on
set showcmd
set showmode
set number
set foldmethod=marker
set nocursorline
set foldcolumn=2
" colours
set t_Co=256
if &diff
  color candycode
else
  color candycode
endif
" }}}

"scroll off settings
set scrolloff=5
set sidescrolloff=7
set sidescroll=1

set shortmess=atI " shorten message prompts a bit
set mousehide "hide mouse when typing

"{{{ statusline setup
set statusline=%{getcwd()}\ %-10F
 
"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*
 
"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*
 
set statusline+=%h "help file flag
set statusline+=%y "filetype
set statusline+=%r "read only flag
set statusline+=%m "modified flag
 
set statusline+=%*
 
 
set statusline+=%#warningmsg#
set statusline+=%*
 
"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

set statusline+=%(\ %{fugitive#statusline()}%)
 
set statusline+=%= "left/right separator
set statusline+=%c, "cursor column
set statusline+=%l/%L "cursor line/total lines
set statusline+=\ %P "percent through file
set laststatus=2
"}}}

" Stop auto-commenting
au FileType * set comments=


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

" When vimrc is edited, reload it (have yet to see this actually work)
autocmd! bufwritepost vimrc source $MYVIMRC

"{{{ -[ FileTypes ]-
" Jump to last known cursor position

"json
autocmd BufRead,BufNewFile *.json setfiletype json

" text
autocmd FileType text setlocal textwidth=80

" mail
autocmd FileType mail,human set formatoptions+=t textwidth=72

" PHP
let php_baselib = 1
let php_folding = 0
let php_sql_query = 1
let php_html_in_strings = 1
let php_no_shorttags = 0
let php_sync_method = 1
autocmd FileType php set shiftwidth=2 softtabstop=2 tabstop=2
autocmd FileType php set noet

" C
autocmd FileType c set expandtab ai shiftwidth=4 softtabstop=4 tabstop=4

" Python
autocmd FileType python let python_highlight_all = 1
autocmd FileType python let python_slow_sync = 1
autocmd FileType python set expandtab ai shiftwidth=4 softtabstop=4 tabstop=4
"autocmd FileType python setlocal omnifunc=pysmell#Complete

" LaTeX
autocmd Filetype tex,latex set grepprg=grep\ -nH\ $
autocmd Filetype tex,latex let g:tex_flavor = "latex"

"}}}

"{{{ -[ Mappings ]-"

"make Y consistent with C and D
nnoremap Y y$

" Wincmd shortcuts
nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-j> :wincmd j<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-l> :wincmd l<CR>
nnoremap <silent> <F1> :wincmd h<CR>
inoremap <silent> <F1> <esc>:wincmd h<CR>
nnoremap <silent> <F2> :wincmd l<CR>
inoremap <silent> <F2> <esc>:wincmd l<CR>

" taglist
nnoremap <silent> <F8> :TlistToggle<CR>
inoremap <silent> <F8> <esc>:TlistToggle<CR>
nnoremap <silent> <F9> :TlistUpdate<CR>
nnoremap <silent> <F9> :TlistUpdate<CR>

" Nerdtree
nnoremap <silent> <F4> :NERDTreeToggle<CR>
inoremap <silent> <F4> <esc>:NERDTreeToggle<CR>

" Fuzzyfinder
nnoremap <silent> <F3> :FuzzyFinderFile<CR>
inoremap <silent> <F3> <esc>:FuzzyFinderFile<CR>

" :wq shortcuts
nnoremap <silent> <F5> :w<CR>
inoremap <silent> <F5> <esc>:w<CR>
nnoremap <silent> <F6> :wq<CR>
inoremap <silent> <F6> <esc>:wq<CR>
nnoremap <silent> <F7> :wqa<CR>
inoremap <silent> <F7> <esc>:wqa<CR>

" Most Recently Used Files (MRU)
nnoremap <silent> <F12> :MRU<CR>
inoremap <silent> <F12> <esc>:MRU<CR>

" Scroll a bit faster with <C-e> and <C-y>
nnoremap <C-e> 6<C-e>
nnoremap <C-y> 6<C-y>

map <Right> :bnext<CR>
map <Left> :bprev<CR>

"map to bufexplorer
nnoremap <C-B> :BufExplorer<cr>

"Django surround plugin mappings
let g:surround_{char2nr("b")} = "{% block\1 \r..*\r &\1%}\r{% endblock %}"
let g:surround_{char2nr("i")} = "{% if\1 \r..*\r &\1%}\r{% endif %}"
let g:surround_{char2nr("w")} = "{% with\1 \r..*\r &\1%}\r{% endwith %}"
let g:surround_{char2nr("c")} = "{% comment\1 \r..*\r &\1%}\r{% endcomment %}"
let g:surround_{char2nr("f")} = "{% for\1 \r..*\r &\1%}\r{% endfor %}"

" }}}

"{{{ -[ Plugins and Scripts ]-
" taglist
let Tlist_Use_Right_Window = 1
let Tlist_Compart_Format = 1
let Tlist_Show_Menu = 1
let Tlist_Exit_OnlyWindow = 1
let tlist_php_settings = 'php;c:class;f:Functions'

"fuzzy finder
let g:fuzzy_roots = ['/home/el']

"NerdTree settings
"let NERDTreeHighlightCursorline = 1
let NERDTreeChDirMode = 2
let NERDTreeIgnore=['\.db$', '\~$', '\.pyc$', '^__init__\.py$', '\.jpg$', '\.gif$', '\.png$', '\.pdf$']
let NerdTreeMouseMode = 2

"Load templates
autocmd BufNewFile *.html  0r ~/.vim/skeleton.html
" }}}
"{{{ User Commands
command! Snip :new /home/el/.vim/snippets/php.snippets

command! -nargs=+ Grep :grep -r --include=*.php --exclude-dir=blog --exclude-dir=wp --exclude-dir=phpMyAdmin '<args>' /home/el/daddys

"}}}

" Django file jumping
let g:last_relative_dir = ''
nnoremap \1 :call RelatedFile ("models.py")<cr>
nnoremap \2 :call RelatedFile ("views.py")<cr>
nnoremap \3 :call RelatedFile ("urls.py")<cr>
nnoremap \4 :call RelatedFile ("admin.py")<cr>
nnoremap \5 :call RelatedFile ("tests.py")<cr>
nnoremap \6 :call RelatedFile ( "templates/" )<cr>
nnoremap \7 :call RelatedFile ( "templatetags/" )<cr>
nnoremap \8 :call RelatedFile ( "management/" )<cr>
nnoremap \0 :e settings.py<cr>
nnoremap \9 :e urls.py<cr>

fun! RelatedFile(file)
    "This is to check that the directory looks djangoish
    if filereadable(expand("%:h"). '/models.py') || isdirectory(expand("%:h") . "/templatetags/")
        exec "edit %:h/" . a:file
        let g:last_relative_dir = expand("%:h") . '/'
        return ''
    endif
    if g:last_relative_dir != ''
        exec "edit " . g:last_relative_dir . a:file
        return ''
    endif
    echo "Cant determine where relative file is : " . a:file
    return ''
endfun

fun SetAppDir()
    if filereadable(expand("%:h"). '/models.py') || isdirectory(expand("%:h") . "/templatetags/")
        let g:last_relative_dir = expand("%:h") . '/'
        return ''
    endif
endfun
autocmd BufEnter *.py call SetAppDir()
