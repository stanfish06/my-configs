set history=500
set autoread
set noshowmode

" disable query of some information during startup
set t_RV=
set t_RV=
set t_u7=

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

" status bar
function! CurrentMode()
	let l:m = mode()
	return l:m ==# 'i' ? '[I]' :
	     \ l:m ==# 'n' ? '[N]' :
	     \ l:m ==# 'v' ? '[V]' :
	     \ l:m ==# 'V' ? '[VL]' :
	     \ l:m ==# "\<C-v>" ? '[VB]' :
	     \ '[?]'
endfunction
set statusline=
set statusline+=%{CurrentMode()}
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 

" line number
set number
set relativenumber

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
let s:bright_blue = '#c9e6fd'
let s:bright_yellow = '#ffe6b5'
let s:bright_red = '#ffc4c4'
let s:bright_green = '#eff6ab'
let s:bright_purple = '#f7d7ff'
let s:bright_aqua = '#ddfcf8'
let s:faded_blue = '#8abae1'
let s:faded_yellow = '#ceb581'
let s:faded_red = '#ec8989'
let s:faded_green = '#c9d36a'
let s:faded_purple = '#db9fe9'
let s:faded_aqua = '#abebe2'
let s:neutral_green = '#ccd389'
let s:neutral_blue = '#a5c6e1'
let s:neutral_red = '#eca8a8'
let s:neutral_yellow = '#efd5a0'
let s:neutral_orange = '#efb6a0'
let s:orange = '#cb4b16'
let s:green = '#719e07'
let s:purple = '#d33682'
let s:yellow2 = '#FCE566'
let s:blue2 = '#6694a9'
let s:green2 = '#a6da95'
let s:bluegray = '#b8c0e0'
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
call s:Hi('Visual', s:bg, s:fg, '')
call s:Hi('VisualNOS', s:bg, s:fg, '')
call s:Hi('LineNr', s:gray3, '', '')
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
call s:Hi('Statement', s:yellow2, '', '')
call s:Hi('Conditional', s:yellow2, '', '')
call s:Hi('Repeat', s:yellow2, '', '')
call s:Hi('Label', s:bluegray, '', '')
call s:Hi('Operator', s:fg, '', '')
call s:Hi('Keyword', s:yellow2, '', '')
call s:Hi('Exception', '', '', 'underline,bold')
call s:Hi('PreProc', '', '', '')
call s:Hi('Include', s:yellow2, '', '')
call s:Hi('Define', s:gray3, '', '')
call s:Hi('Macro', s:yellow2, '', '')
call s:Hi('PreCondit', '', '', '')
call s:Hi('Type', s:blue2, '', '')
call s:Hi('StorageClass', s:yellow2, '', '')
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
call s:Hi('markdownH1', '', '', 'bold')
call s:Hi('markdownUrl', s:bright_blue, '', '')
