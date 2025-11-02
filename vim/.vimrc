set history=500
set autoread

" cursor setup
let &t_SI="\e[6 q"
let &t_EI="\e[2 q"
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
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
	     \ '[?]'
endfunction
set statusline=
set statusline+=%{CurrentMode()}
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
set noshowmode
