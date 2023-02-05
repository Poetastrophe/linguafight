let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/linguafight
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +291 ~/.config/nvim/init.vim
badd +1 third_party/ziglyph/src/segmenter/Grapheme.zig
badd +11 src/main.zig
badd +27 src/WordList.zig
badd +24 src/DanishChar.zig
badd +49 ~/.local/bin/zig/lib/std/array_list.zig
badd +2 src/LinguaFight.zig
badd +1 term://~/linguafight//8423:/bin/zsh
badd +2424 term://~/linguafight//8836:/bin/zsh
badd +37 build.zig
badd +3 src/BinomialPermutations.zig
badd +552 ~/.local/bin/zig/lib/std/mem.zig
badd +10 ~/.local/bin/zig/lib/std/heap/arena_allocator.zig
badd +1 ~/.local/bin/zig/lib/std/fs/file.zig
badd +229 ~/.local/bin/zig/lib/std/io/reader.zig
badd +16 ~/.local/bin/zig/lib/std/io/fixed_buffer_stream.zig
badd +12 src/third_party/dansk.txt
badd +534 ~/.local/bin/zig/lib/std/fs/path.zig
badd +2039 ~/.local/bin/zig/lib/std/fs.zig
badd +2 main.zig.bak
argglobal
%argdel
edit src/WordList.zig
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
split
1wincmd k
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
wincmd =
argglobal
balt ~/.local/bin/zig/lib/std/mem.zig
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 16 - ((1 * winheight(0) + 1) / 2)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 16
normal! 0
wincmd w
argglobal
if bufexists(fnamemodify("term://~/linguafight//8836:/bin/zsh", ":p")) | buffer term://~/linguafight//8836:/bin/zsh | else | edit term://~/linguafight//8836:/bin/zsh | endif
if &buftype ==# 'terminal'
  silent file term://~/linguafight//8836:/bin/zsh
endif
balt src/WordList.zig
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 2375 - ((33 * winheight(0) + 17) / 34)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 2375
normal! 0
wincmd w
wincmd =
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
let g:this_session = v:this_session
let g:this_obsession = v:this_session
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
