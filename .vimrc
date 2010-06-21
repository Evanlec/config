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

set iskeyword+=_,$,@,%,# " none of these should be word dividers, so make them not be
set iskeyword-=/
"set lazyredraw
set listchars=tab:>-,trail:-
"hide buffers when not displayed
set hidden

"maybe these speed things up?
set ttyfast 
set ttyscroll=1

set viminfo='20,<50,s10,h,%

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
"set autoindent
"set smartindent
set tabstop=8
set shiftwidth=4
set softtabstop=4
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
vnoremap <C-c> "+y

" -[ Look ]-
" general
"set cursorline
syntax on
set showcmd
set showmode
set number
set foldmethod=marker

"scroll off settings
set scrolloff=5
set sidescrolloff=7
set sidescroll=1

"let loaded_matchparen=1
set shortmess=atI " shorten message prompts a bit
set mousehide "hide mouse when typing
"autocmd winleave * setl nocursorline
"autocmd winenter * setl cursorline

"statusline setup
set statusline=%f "tail of the filename
 
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
 
set statusline+=%{StatuslineTrailingSpaceWarning()}
 
"set statusline+=%{StatuslineLongLineWarning()}
 
set statusline+=%#warningmsg#
set statusline+=%*
 
"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*
 
set statusline+=%= "left/right separator
set statusline+=%c, "cursor column
set statusline+=%l/%L "cursor line/total lines
set statusline+=\ %P "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning
 
"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction
 
 
"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction
 
"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning
 
"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0
 
        if tabs && spaces
            let b:statusline_tab_warning = '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction
 
"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning
 
"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()
 
        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"set cursorline
" Stop auto-commenting
au FileType * set comments=
" colours
set t_Co=256
if &diff
  color inkpot
else
  color candycode
endif

if &term =~ "xterm"
    let &t_SI = "\<Esc>]12;purple\x7"
    let &t_EI = "\<Esc>]12;blue\x7"
endif



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

" -[ FileTypes ]-
" Jump to last known cursor position

"json
autocmd BufRead,BufNewFile *.json setfiletype json

" text
autocmd FileType text setlocal textwidth=80

" mail
autocmd FileType mail,human set formatoptions+=t textwidth=72

" PHP
let php_baselib = 1
let php_folding = 1
let php_sync_method = 3
let php_sql_query = 1
autocmd FileType php set shiftwidth=4 softtabstop=4 tabstop=4
"autocmd FileType php set noet


" Python
autocmd FileType python let python_highlight_all = 1
autocmd FileType python let python_slow_sync = 1
autocmd FileType python set expandtab ai shiftwidth=4 softtabstop=4 tabstop=4
"autocmd FileType python setlocal omnifunc=pysmell#Complete

" LaTeX
autocmd Filetype tex,latex set grepprg=grep\ -nH\ $
autocmd Filetype tex,latex let g:tex_flavor = "latex"


" -[ Mappings ]-"
" Map leader to ,
let mapleader = ","
" remap ` to '
nnoremap ' `
nnoremap ` '

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

"YankRing shortcut
nnoremap <silent> <F11> :YRShow<CR>

" Most Recently Used Files (MRU)
nnoremap <silent> <F12> :MRU<CR>
inoremap <silent> <F12> <esc>:MRU<CR>

" Scroll a bit faster with <C-e> and <C-y>
nnoremap <C-e> 6<C-e>
nnoremap <C-y> 6<C-y>

" I dont really care about top/bottom of the screen
map H 5zh
map L 5zl

"map <Right> :bnext<CR>
"map <Left> :bprev<CR>

"map to bufexplorer
nnoremap <C-B> :BufExplorer<cr>

" Toggle viewing trailing whitespace
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅
nmap <silent> <leader>s :set nolist!<CR>

" -[ Plugins and Scripts ]-
" taglist
let Tlist_Use_Right_Window = 1
let Tlist_Compart_Format = 1
let Tlist_Show_Menu = 1
let Tlist_Exit_OnlyWindow = 1
let tlist_php_settings = 'php;c:class;f:Functions'

"fuzzy finder
let g:fuzzy_roots = ['/home/el']

"NerdTree settings
let NERDTreeHighlightCursorline = 1
let NERDTreeChDirMode = 2
let NERDTreeIgnore=['\.db$', '\~$', '\.pyc$', '^__init__\.py$']
let NerdTreeMouseMode = 2

"html tag jumping
autocmd FileType html let b:match_words = '<\(\w\w*\):</\1'
autocmd FileType xhtml let b:match_words = '<\(\w\w*\):</\1'
autocmd FileType smarty let b:match_words = '<\(\w\w*\):</\1'
autocmd FileType xml let b:match_words = '<\(\w\w*\):</\1'

"Load templates
autocmd BufNewFile *.html  0r ~/.vim/skeleton.html

"debugger plugin
let g:loaded_DBGp_plugin=1
command DBG unlet loaded_DBGp_plugin | runtime plugin/debugger.vim


"define :HighlightLongLines command to highlight the offending parts of
"lines that are longer than the specified length (defaulting to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
    let targetWidth = a:width != '' ? a:width : 79
    if targetWidth > 0
        exec 'match Todo /\%>' . (targetWidth) . 'v/'
    else
        echomsg "Usage: HighlightLongLines [natural number]"
    endif
endfunction
