set history=500
set autoread
" Better completion and command line
set wildmenu
set wildmode=longest:full,full
" Better splitting behavior
set splitbelow
set splitright
set hlsearch
set incsearch
" by default, case insensitive search
set ignorecase
" if you enter sth in uppercase, then this will be case sensitive
set smartcase
set autochdir
" leader key
let mapleader=" "
" set this so netrw will change pwd
let g:netrw_keepdir = 0
augroup netrw_cd
	autocmd!
	autocmd FileType netrw silent! lcd %:p:h
augroup END
" spacing
set tabstop=4
set shiftwidth=4

" line number
set number
set relativenumber
set cursorline
set cursorlineopt=number
" disable query of some information during startup
set t_RB=
set t_RF=
set t_RV=
set t_u7=
set t_Co=256

" used to check color group, eval this when cursor is on a text
function! SynStack()
	if !exists("*synstack")
		return
	endif
	echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" cursor setup
let &t_SI="\e[6 q\e]12;\#FF8C00\x7"
let &t_EI="\e[2 q\e]12;\#FF8C00\x7"
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q\e]12;\#FF8C00\x7"
augroup END
" remove the time lag between mode change
set ttimeout
set ttimeoutlen=1
set ttyfast
" status
set laststatus=2

" for persistent undo
" clean
" usage: :call CleanUndo()
function! CleanUndo()
	let undodir = expand($HOME . '/.vim/undo')
	let counter = 0
	if isdirectory(undodir)
		for f in split(glob(undodir . '/*'), '\n')
		    " remove undo files that are at least 7 days old
		    if  localtime() - getftime(f) > 7 * 24 * 60 * 60
			call delete(f)
			let counter = counter + 1
		    endif
		endfor
	endif
	echo counter . " files deleted"
endfunc
if !isdirectory($HOME."/.vim/undo")
    call mkdir($HOME."/.vim/undo", "", 0700)
endif
set undodir=~/.vim/undo
set undofile

" status bar
function! CurrentMode()
	let l:m = mode()
	if l:m ==# 'i'
		hi StatusLineMode ctermbg=gray ctermfg=black
	else
		hi StatusLineMode ctermbg=green ctermfg=black
	endif
	return l:m ==# 'i' ? '[I]' :
		\ l:m ==# 'n' ? '[N]' :
		\ l:m ==# 'v' ? '[V]' :
		\ l:m ==# 'V' ? '[VL]' :
		\ l:m ==# "\<C-v>" ? '[VB]' :
		\ l:m ==# 'R'  ? '[R]':
		\ l:m ==# 'c'  ? '[C]':
		\ l:m ==# 't'  ? '[T]':
		\ '[?]'
endfunction
set statusline=
set statusline+=%#StatusLineMode#%{CurrentMode()}
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 

" wl-clipboard
xnoremap "+y y:call system("wl-copy", @")<cr>
nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', '', 'g')<cr>p
nnoremap "*p :let @"=substitute(system("wl-paste --no-newline --primary"), '<C-v><C-m>', '', 'g')<cr>p

" keymap
" do not map Esc as that will trigger wierd characters in tmux
" use gt and gT to navigate between tabs, buffers and shared between tabs
nnoremap H :bprevious<cr>
nnoremap L :bnext<cr>
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>bn :enew<cr>
nnoremap <leader>k :close<cr>
nnoremap \ :Texplore<cr>
nnoremap <leader><Esc> :nohlsearch<cr>
vnoremap > >gv
vnoremap < <gv
tnoremap <leader><Esc><Esc> <C-\><C-n>
nnoremap <C-_> :terminal<cr>

" grep
nnoremap <leader>q :copen<cr>
nnoremap <leader>c :cclose<cr>
nnoremap <C-j> :cnext<cr>
nnoremap <C-k> :cprevious<cr>
cnoreabbrev vimgrep vimgrep /pattern/gj **/*

" find
" note: to edit/find a file, just enter part of the file name and tab complete that
" edit only search under pwd
nnoremap <leader>e :edit **/*
" if you tab with find, all files in path will be searched
" e.g. you can search header files since usr/include is in path
nnoremap <leader>f :find **/*

" --------
" Packages
" --------
let s:package_list = {
	\ 'fzf.vim': 'https://github.com/junegunn/fzf.vim.git',
	\ 'vim-lsp': 'https://github.com/prabirshrestha/vim-lsp.git',
	\ 'vim-sneak': 'https://github.com/justinmk/vim-sneak.git',
	\ }

function! SyncPackages()
	let package_dir = $HOME .. "/.vim/pack/vendor/start/"
	if !isdirectory(package_dir)
		call mkdir(package_dir, "p", 0700)
	endif
	
	echo "Syncing packages..."
	for pkg in keys(s:package_list)
		let full_path = package_dir .. pkg
		if isdirectory(full_path)
			echo "Reinstalling " .. pkg .. "..."
			call delete(full_path, 'rf')
		else
			echo "Installing " .. pkg .. "..."
		endif
		call system('git clone --depth 1 ' .. s:package_list[pkg] .. ' ' .. full_path)
	endfor
	echo "Done! Restart Vim to load plugins."
endfunction

command! SyncPack call SyncPackages()

" ---
" LSP
" ---
" ------------------------------------------------------------------------------------------
" pre-steps:
" - mkdir -p ~/.vim/pack/vendor/start
" - git clone https://github.com/prabirshrestha/vim-lsp.git ~/.vim/pack/vendor/start/vim-lsp
" ------------------------------------------------------------------------------------------
let g:lsp_diagnostics_enabled = 0
" boost LSP performance
let g:lsp_use_native_client = 1
" remove code action sign
let g:lsp_document_code_action_signs_enabled = 0
if executable('clangd')
	au User lsp_setup call lsp#register_server({
		\ 'name': 'clangd',
		\ 'cmd': {server_info->['clangd']},
		\ 'allowlist': ['c', 'cpp'],
		\ })
endif
if executable('pyright-langserver')
	au User lsp_setup call lsp#register_server({
		\ 'name': 'pyright',
		\ 'cmd': {server_info->['pyright-langserver', '--stdio']},
		\ 'allowlist': ['python'],
		\ })
endif
if executable('rust-analyzer')
	au User lsp_setup call lsp#register_server({
		\ 'name': 'rust-analyzer',
		\ 'cmd': {server_info->['rust-analyzer']},
		\ 'allowlist': ['rust'],
		\ })
endif
function! s:on_lsp_buffer_enabled() abort
	setlocal omnifunc=lsp#complete
	nmap <buffer> gd <plug>(lsp-definition)
	nmap <buffer> gr <plug>(lsp-references)
	nmap <buffer> K <plug>(lsp-hover)
	nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
	nnoremap <buffer> <expr><c-d> lsp#scroll(-4)	
endfunction
augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" -------------------
" Some useful plugins
" -------------------
" better search and jump then /
" - git clone https://github.com/justinmk/vim-sneak.git ~/.vim/pack/vendor/start/vim-sneak

" ---
" fzf
" ---
" first, delete system fzf and install fzf locally: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
" then, git clone https://github.com/junegunn/fzf.vim.git ~/.vim/pack/vendor/start/fzf.vim
" add local fzf to the vim runtime path
" Note: do not use fzf in netrw
set rtp+=~/.fzf
" find files
nnoremap <leader><leader> :Files<cr>
" grep
nnoremap <leader>/ :RG<cr>
" search
nnoremap <leader>sl :Lines<cr>
nnoremap <leader>sb :Buffers<cr>
let g:fzf_vim = {}
let g:fzf_vim.files_options = '--style full --border-label " Files "'
let g:fzf_vim.rg_options = '--style full --border-label " Grep "'
let g:fzf_vim.lines_options = '--style full --border-label " Lines "'
let g:fzf_vim.buffers_options = '--style full --border-label " Buffers "'
inoremap <expr> <c-x><c-n> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

" -----
" Theme
" -----
if has('termguicolors')
  set termguicolors
endif
syntax enable
set background=dark

let s:fg = '#EBEBEB'
let s:bg = '#1E1E1E'
let s:black = '#000000'
let s:gray1 = '#333333'
let s:gray2 = '#474747'
let s:gray3 = '#5C5C5C'
let s:gray4 = '#707070'
let s:gray5 = '#858585'
let s:gray6 = '#999999'
let s:gray7 = '#ADADAD'
let s:gray8 = '#C2C2C2'
let s:gray9 = '#D6D6D6'
let s:bg_alt = '#252525'
let s:yellow = '#FFF244'
let s:bright_blue = '#C9E6FD'
let s:bright_yellow = '#FFE6B5'
let s:bright_red = '#FFC4C4'
let s:bright_green = '#EFF6AB'
let s:bright_purple = '#F7D7FF'
let s:bright_aqua = '#DDFCF8'
let s:faded_blue = '#8ABAE1'
let s:faded_yellow = '#CEB581'
let s:faded_red = '#EC8989'
let s:faded_green = '#C9D36A'
let s:faded_purple = '#DB9FE9'
let s:faded_aqua = '#ABEBE2'
let s:neutral_green = '#CCD389'
let s:neutral_blue = '#A5C6E1'
let s:neutral_red = '#ECA8A8'
let s:neutral_yellow = '#EFD5A0'
let s:neutral_orange = '#EFB6A0'
let s:orange = '#CB4B16'
let s:green = '#719E07'
let s:purple = '#D33682'
let s:blue2 = '#6694A9'
let s:green2 = '#A6DA95'
let s:bluegray = '#B8C0E0'
let s:coolgray = '#F9FAFB'
let s:greengray = '#A4B5A7'
let s:yellowgray = '#B1AC8C'
let s:cursor = '#FF8C00'

function! s:Hi(group, fg, bg, style)
	let l:cmd = 'highlight ' . a:group
	if a:fg != ''
		let l:cmd .= ' guifg=' . a:fg . ' ctermfg=NONE'
	endif
	if a:bg != ''
		let l:cmd .= ' guibg=' . a:bg . ' ctermbg=NONE'
	endif
	if a:style != ''
		let l:cmd .= ' gui=' . a:style . ' cterm=' . a:style
	else
		let l:cmd .= ' gui=NONE cterm=NONE'
	endif
	execute l:cmd
endfunction

call s:Hi('Normal', s:fg, s:bg, '')
call s:Hi('Terminal', s:fg, s:bg, '')
call s:Hi('Visual', s:bg, s:gray8, '')
call s:Hi('VisualNOS', s:bg, s:gray8, '')
call s:Hi('LineNr', s:gray6, '', '')
call s:Hi('CursorLineNr', s:yellow, '', '')
call s:Hi('ColorColumn', '', s:bg_alt, '')
call s:Hi('IncSearch', s:bg, s:bright_blue, 'bold')
call s:Hi('Search', s:bg, s:faded_blue, '')
call s:Hi('Pmenu', s:fg, s:gray1, '')
call s:Hi('PmenuSel', s:gray1, s:fg, '')
call s:Hi('PmenuSbar', s:fg, s:gray1, '')
call s:Hi('PmenuThumb', s:bg, s:gray8, '')
call s:Hi('SpellBad', s:orange, '', 'underline')
call s:Hi('SpellCap', '', '', '')
call s:Hi('SpellLocal', '', '', '')
call s:Hi('SpellRare', '', '', '')
call s:Hi('ModeMsg', '', '', '')
call s:Hi('MoreMsg', '', '', '')
call s:Hi('StatusLine', '', '', '')
call s:Hi('StatusLineNC', '', '', '')
call s:Hi('MatchParen', '', '', 'bold')
call s:Hi('VertSplit', s:bg, s:bg, '')
call s:Hi('Comment', s:gray3, '', 'italic')
call s:Hi('SpecialComment', s:gray6, '', 'bold,italic')
call s:Hi('Todo', s:black, '', 'bold')
call s:Hi('Constant', s:fg, '', '')
call s:Hi('String', s:green2, '', '')
call s:Hi('Character', s:fg, '', '')
call s:Hi('Number', s:fg, '', 'bold')
call s:Hi('Boolean', s:fg, '', 'bold')
call s:Hi('Float', s:fg, '', 'bold')
call s:Hi('Identifier', s:bluegray, '', '')
call s:Hi('Function', s:blue2, '', '')
call s:Hi('Statement', s:yellow, '', '')
call s:Hi('Conditional', s:yellow, '', '')
call s:Hi('Repeat', s:yellow, '', '')
call s:Hi('Label', s:bluegray, '', '')
call s:Hi('Operator', s:fg, '', '')
call s:Hi('Keyword', s:yellow, '', '')
call s:Hi('Exception', '', '', 'underline,bold')
call s:Hi('PreProc', '', '', '')
call s:Hi('Include', s:yellow, '', '')
call s:Hi('cPreCondit', s:yellow, '', '')
call s:Hi('Define', s:gray3, '', '')
call s:Hi('Macro', s:yellow, '', '')
call s:Hi('PreCondit', '', '', '')
call s:Hi('Type', s:blue2, '', '')
call s:Hi('StorageClass', s:yellow, '', '')
call s:Hi('Structure', '', '', '')
call s:Hi('Typedef', s:gray7, '', '')
call s:Hi('Special', '', '', '')
call s:Hi('SpecialChar', s:green2, '', '')
call s:Hi('Tag', s:fg, '', '')
call s:Hi('Delimiter', s:fg, '', '')
call s:Hi('Debug', '', '', '')
call s:Hi('Error', '', '', 'underline,italic')
call s:Hi('ErrorMsg', s:bright_red, s:bg, 'bold')
call s:Hi('Conceal', s:gray2, '', '')
call s:Hi('Directory', '', '', '')
call s:Hi('EndOfBuffer', '', '', '')
call s:Hi('FoldColumn', '', '', '')
call s:Hi('Folded', '', '', '')
call s:Hi('NonText', s:green, '', '')
call s:Hi('Question', '', '', '')
call s:Hi('SignColumn', '', '', '')
call s:Hi('SpecialKey', '', '', '')
call s:Hi('Substitute', s:orange, '', 'bold,reverse')
call s:Hi('TabLine', '', '', '')
call s:Hi('TabLineFill', '', '', '')
call s:Hi('TabLineSel', '', '', 'reverse')
call s:Hi('WarningMsg', '', '', '')
call s:Hi('WildMenu', '', '', 'reverse')
call s:Hi('Ignore', '', '', '')
call s:Hi('shDerefVar', s:greengray, '', '')
call s:Hi('kshSpecialVariables', s:greengray, '', '')
call s:Hi('shOption', s:fg, '', '')
call s:Hi('shCommandSub', s:fg, '', '')
call s:Hi('shSpecial', s:fg, '', '')
call s:Hi('shSpecialStart', s:fg, '', '')
call s:Hi('vimString', s:fg, '', '')
call s:Hi('vimEscape', s:fg, '', '')
call s:Hi('vimContinue', s:fg, '', '')
call s:Hi('vimNotation', s:fg, '', '')
call s:Hi('PreProc', s:greengray, '', '')
call s:Hi('shVariable', s:coolgray, '', '')
call s:Hi('Whitespace', s:gray2, '', '')
call s:Hi('DiffAdd', s:neutral_green, '', '')
call s:Hi('DiffChange', s:neutral_blue, '', '')
call s:Hi('DiffDelete', s:neutral_red, '', '')
call s:Hi('DiffText', s:neutral_blue, '', '')
call s:Hi('GitGutterAdd', s:neutral_green, '', '')
call s:Hi('GitGutterChange', s:neutral_yellow, '', '')
call s:Hi('GitGutterChangeDelete', s:neutral_orange, '', '')
call s:Hi('GitGutterDelete', s:neutral_red, '', '')
call s:Hi('SignifySignAdd', s:neutral_green, '', '')
call s:Hi('SignifySignChange', s:neutral_yellow, '', '')
call s:Hi('SignifySignDelete', s:neutral_red, '', '')
call s:Hi('markdownBold', '', '', 'bold')
call s:Hi('markdownCode', '', '', '')
call s:Hi('markdownCodeDelimiter', '', '', '')
call s:Hi('markdownError', '', '', '')
call s:Hi('markdownUrl', s:bright_blue, '', '')
call s:Hi('netrwPlain', s:fg, '', '')
call s:Hi('netrwLink', s:fg, '', '')
call s:Hi('netrwDir', s:bright_aqua, '', '')
call s:Hi('netrwSymLink', s:fg, '', '')
call s:Hi('qfFileName', s:neutral_yellow, '', '')
call s:Hi('tomlTable', s:yellow, '', '')
call s:Hi('markdownH1', '', '', 'bold')
call s:Hi('markdownH2', '', '', 'bold')
call s:Hi('markdownH3', '', '', 'bold')
call s:Hi('tmuxKey', '', '', '')
call s:Hi('shFor', '', '', '')
call s:Hi('shExpr', '', '', '')
call s:Hi('shExpr', '', '', '')
call s:Hi('shIf', '', '', '')
call s:Hi('shTestError', '', '', '')
call s:Hi('shCurlyError', '', '', '')
