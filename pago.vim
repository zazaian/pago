"
"
" Pago
" a screenwriting plugin for vim
" Version:      0.0.11
" Updated:      2008-10-07
" Maintainer:   Mike Zazaian, mike@zop.io, http://zop.io
" Originator:   Alex Lance, alla at cyber.com.au
" License:      This file is placed in the public domain.
"
" Blankpage allows the use of vim as a fully-functional piece of screenwritng
" software, automatically formatting the following screenplay elements:
" 
" ELEMENT            characters ( beginning#, ending#, total#, align, caps )
" SCENE HEADING      ( 11, 70, 60, L, yes )
" ACTION             ( 11, 70, 60, L, no )
" CHARACTER          ( 31, 70, 40, L, yes )
" PARANTHETICAL      ( 26, 55, 30, L, no )
" DIALOGUE           ( 21, 55, 35, L, no )
" TRANSITION         ( 70, 11, 60, R, yes )
"
" This plugin elaborates upon on the screenplay.vim plugin developed by Alex Lance,
" which supported ACTION lines, CHARACTER names, and DIALOGUE.
"
" The following elements are planned for integration, with the following key to
" mark the level of completion:
" 'p': PLANNED but not yet completed
" 'd': in DEVELOPMENT
" 't': developed but in the process of TESTING
" 'i': fully developed, tested, and INTEGRATED
"
" p Automatic hilighting and capitalization of SCENE HEADING elements
" d Handling of PARANTHETICAL elements
" p Handling of TRANSITION elements
" d Improved formatting
" p Display type of input in status bar
" p PRINT FORMATTING, including
"   p Page numbers
"   p (CONTINUED) comments
"   p (Cont'd) elements when dialogue for a single characters spills onto another
"   page
"
"
" /// OMIT AFTER USING FOR REFERENCE ///
" The definition of a well formatted screenplay (as I understand it) goes
" something like:
"
" <15 spaces>SCENE/ACTION/DESCRIPTIONS (max 54 chars before wrapping)
" <37 spaces>CHARACTER NAME
" <25 spaces>DIALOG (max 35 chars before wrapping)
"
" It might look like:
"
"
"              EXT. CITY STREET - DAY
"
"              Rain pissing down. Newspaper KID on street. A MAN stops
"              to listen.
"
"                                    KID
"                              (shouting)
"                        Extra! Extra! Child labour used to
"                        sell newspapers!
"
" Features
" ========
"
"  * All text is just a tab away from being indented correctly.
"    The tab button and the backspace button have been modified to go
"    backwards and forwards in helpful chunks 
"    Action  == 16 spaces == 1 tab
"    Dialog  == 26 spaces == 2 tabs
"    Speaker == 38 spamce == 3 tabs
"
"  * The textwidth (tw) variable switches from 68 to 60, when moving from
"    ACTION to DIALOG. This ensures good margins.
"
"  * Control-p will format a paragraph from under the cursor
"    downwards, relative to the (textwidth) margin
"
"  * When you tab three times to type in a character name for DIALOG, and you
"    type the first letter of the characters name and then tab again, then you
"    will be presented with a choice to autocomplete that characters name.
"    (provided you've typed that characters name above a DIALOG at least once
"    before).
"  
"  * Hitting enter after DIALOG should align for a new character name 
"
"  * Hitting enter twice after DIALOG should align for new ACTION block
"       
" TODO: 
"  - provide indentation and textwidth settings for ACTOR DIRECTIONS (31
"    spaces and then ACTOR DIRECTION in brackets)
"  - make vim style help for this plugin
"  - syntax highlighting
"
" HOW TO INSTALL
"
"  * Drop this file in your ${VIMRUNTIME}/ftplugin/ directory
"  * ensure your instance of vim has these options enabled:
"    :filetype on
"    :filetype plugin on
"    :au BufRead,BufNewFile *.pago    set filetype=pago
"  * Ensure the suffix the file you are editing is .pago and away you
"    go!
"
"
" Avoid loading this twice
if exists("loaded_pago")
  finish
endif
let loaded_pago = 1
let g:counter = []

" Three listeners: Enter, Tab and Backspace
imap <CR> <C-R>=ScreenplayEnterPressed()<CR>
imap <TAB> <C-R>=ScreenplayTabPressed()<CR>
imap <BS> <C-R>=ScreenplayBackspacePressed()<CR>
imap  <C-R>=ScreenplayBackspacePressed()<CR>

" Reformat paragraph with Ctrl-P in insert and normal mode
imap <C-P> <C-R>=ScreenplayCtrlPPressed()<CR>
map <C-P> i<C-R>=ScreenplayCtrlPPressed()<CR>

" map ctrl-d to clean up all the whitespace so that ctrl-p work correctly
"imap <C-D> !A!<Esc>:%s/^[ ]\{1,}$//g<CR>?!A!<CR>df!i

set tw=70         " Set text width to 70
set wrap          " Set columns to wrap at tw
set expandtab     " Change tabs into spaces
set softtabstop=0 " softtabstop variable can break my custom backspacing
set autoindent    " Set auto indent
set noshowmatch   " Turn off display of matching parenthesis if already on
set ff=unix       " use unix fileformat

fu! TransitionAdjust()
  let rtn = repeat("\</Left>\<BS>\<Right>", 1)
  return rtn
endfu

function! MapUppercase()
  if g:current == "transition"
    let g:premap = "\<Left>\<BS>\<Right>"
  else
    let g:premap = ""
  endif
  imap a <C-R>=g:premap<CR>A
  imap b <C-R>=g:premap<CR>B
  imap c <C-R>=g:premap<CR>C
  imap d <C-R>=g:premap<CR>D
  imap e <C-R>=g:premap<CR>E
  imap f <C-R>=g:premap<CR>F
  imap g <C-R>=g:premap<CR>G
  imap h <C-R>=g:premap<CR>H
  imap i <C-R>=g:premap<CR>I
  imap j <C-R>=g:premap<CR>J
  imap k <C-R>=g:premap<CR>K
  imap l <C-R>=g:premap<CR>L
  imap m <C-R>=g:premap<CR>M
  imap n <C-R>=g:premap<CR>N
  imap o <C-R>=g:premap<CR>O
  imap p <C-R>=g:premap<CR>P
  imap q <C-R>=g:premap<CR>Q
  imap r <C-R>=g:premap<CR>R
  imap s <C-R>=g:premap<CR>S
  imap t <C-R>=g:premap<CR>T
  imap u <C-R>=g:premap<CR>U
  imap v <C-R>=g:premap<CR>V
  imap w <C-R>=g:premap<CR>W
  imap x <C-R>=g:premap<CR>X
  imap y <C-R>=g:premap<CR>Y
  imap z <C-R>=g:premap<CR>Z
endfunction

function! UnmapUppercase()
  imap a a
  imap b b
  imap c c
  imap d d
  imap e e
  imap f f
  imap g g
  imap h h
  imap i i
  imap j j
  imap k k
  imap l l
  imap m m
  imap n n
  imap o o
  imap p p
  imap q q
  imap r r
  imap s s
  imap t t
  imap u u
  imap v v
  imap w w
  imap x x
  imap y y
  imap z z
endfunction

function! ToggleCase(new_case)
  if a:new_case == "upper"
    call MapUppercase()
    return "gUgU"
  elseif a:new_case == "lower"
    call UnmapUppercase()
    return "gugu"
  endif
endfunction


fu! ElementHelper(begins, ends, case)
  
  if g:current == "scene"
    set cursorline
  else
    set nocursorline
  endif

  exe "set tw=" . a:ends
  call ToggleCase(a:case)
  
  let s:statustxt = toupper(g:current)
  set statusline=%f%{s:statustxt}

endfu

function! Scene()
  let g:current = "scene"
  let s:begins = 11
  let s:ends = 70
  let s:case = "upper"
  call ElementHelper(s:begins, s:ends, s:case)
endfunction

function! Action(key_pressed)
  let g:current = "action"
  let s:begins = 11
  let s:ends = 70
  let s:x_coord = col(".")
  let s:case = "lower"
  call ElementHelper(s:begins, s:ends, s:case)
  
  if a:key_pressed == "tab"
    let s:x_change = s:begins - 1
    let s:prepend = "\<Del>" . repeat("\<BS>", s:x_coord - 1)
    let s:middle = repeat(' ', s:begins - 1)
    let s:append = ""
  endif

  return s:prepend . s:middle . s:append
endfunction

function! Character(key_pressed)
  let g:current = "character"
  let s:begins = 31
  let s:ends = 70
  set tw=70
  set nocursorline
  let s:x_coord = col(".")
  let s:case = "upper"
  call ToggleCase(s:case)
  
  if a:key_pressed == "tab"
    let s:x_change = s:begins - s:x_coord
    let s:prepend = "\<Left>\<Del>\<Del>"
    let s:middle = repeat(' ', s:x_change + 1)
    let s:append = ""
  endif

  return s:prepend . s:middle . s:append
endfunction

function! Parenthetical(key_pressed)
  let g:current = "parenthetical"
  let s:begins = 26
  let s:ends = 55
  set tw=55
  set nocursorline
  let s:x_coord = col(".")
  let s:case = "lower"
  call ToggleCase(s:case)

  if a:key_pressed == "tab"
    let s:x_change = s:begins - s:x_coord
    let s:middle = repeat(' ', s:x_change)
    let s:append = "()\<Left>"
  endif

  return s:middle . s:append
endfunction

function! Dialogue(key_pressed)
  let s:x_coord = col(".")
  let g:current = "dialogue"
  let s:begins = 21
  let s:ends = 55
  set tw=55
  set nocursorline
  let s:case = "lower"
  call ToggleCase(s:case)
  
  if a:key_pressed == "tab"
    let s:x_change = s:begins - s:x_coord
    let s:rtn = repeat(' ', s:x_change)
  endif

  return s:rtn
endfunction

function! Transition(key_pressed)
  let g:current = "transition"
  let s:begins = 70
  let s:ends = 11
  set tw=70
  set nocursorline
  let s:x_coord = col(".")
  let s:case = "upper"
  call ToggleCase(s:case)
  
  if a:key_pressed == "tab"
    let s:x_change = s:begins - s:x_coord
    let s:prepend = ""
    let s:middle = repeat(' ', s:x_change)
    let s:append = ":\<Left>"
  endif

  return s:prepend . s:middle . s:append
endfunction


function! ScreenplayEnterPressed()
  let [lnum, col] = searchpos('[^ ].*', 'bnc', line("."))

  let len = len(g:counter)
  if len > 0
    let len = len -1
  endif
    
  let prev_col = get(g:counter,len)
  call add(g:counter, printf("%d",col))
  let rtn = "\<CR>"
  set tw=70

  " Action -> Scene Heading
  if col == 11

    set tw=70
    let rtn = "\<Esc>gUgU\<CR>"
    let g:current = "scene"
    set cursorline
    call MapUppercase()
    call Scene()

  " Scene Heading -> Next Action Line
 
  " Name -> Dialog
  elseif col == 31 && !pumvisible()
    set tw=55
    let rtn = "\<CR>\<Esc>I".repeat(' ', 20)
    call UnmapUppercase()

  " Parenthentical -> Dialogue
  elseif col == 26
    set tw=55
    let rtn = "\<CR>\<Esc>I".repeat(' ', 20)

  " Dialog -> New Name
  elseif col == 21
    set tw=55
    let rtn = "\<CR>\<CR>\<Esc>I".repeat(' ', 30)
    call MapUppercase()

  " Dialog -> Action
  elseif prev_col == 21 && col == 0
    set tw=70
    let rtn = "\<Esc>I".repeat("\<BS>", 10)
  endif

  "return rtn .prev_col." - ".col
  return rtn 
endfunction


function! ScreenplayTabPressed()
  let s:key = "tab"
  let s:coord = col(".")
  
  if s:coord < 21
    let s:rtn = Dialogue(s:key)
  elseif s:coord == 21
    let s:rtn = Parenthetical(s:key)
  elseif s:coord == 27 
    let s:rtn = Character(s:key)
  elseif s:coord >= 31 && s:coord < 70
    let s:rtn = Transition(s:key)
  elseif s:coord >= 70
    let s:rtn = Action(s:key)
  endif

  return s:rtn 
endfunction


function! ScreenplayBackspacePressed()
  let [lnum, col] = searchpos('[^ ].*', 'bn', line("."))
  let s:x = 1
  let s:action = "\<BS>"
  
  if col == 0
    let s:coord = col(".")

    if s:coord > 31
      let s:x = s:coord - 31
    elseif s:coord > 26
      let s:x = s:coord - 26
    elseif s:coord > 21
      let s:x = s:coord - 21
    elseif s:coord > 11
      let s:x = s:coord - 11
      call UnmapUppercase()
    elseif s:coord <= 11
      let s:x = s:coord
    endif
  endif

  return repeat(s:action, s:x)
endfunction


function! ScreenplayCtrlPPressed()
  let [lnum, col] = searchpos('[^ ].*', 'bnc', line("."))

  if col == 31
    set tw=55
    return "\<Esc>gq}i"
  elseif col == 11
    set tw=70
    return "\<Esc>gq}i"
  endif
  return "\<Esc>gq}i"
endfunction

" This function allows a dropdown list to 
" appear for character names at the top of DIALOG
function! ScreenplayCompleteCharacterName(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    let last_line = str2nr(line("$"))
    let line_num = 1
    let pattern = "^".repeat(" ",30)."[A-Za-z0-9 ']*$"
    "let pattern = 'combination'
    let matches = {}
    let names = []
    let res = []
    
    " need the call to cursos to start the search from the start of doc
    call cursor(1, 1) 

    " loop through all the line
    while line_num <= last_line
      if search(pattern,"cn",line_num) > 0
        let k = substitute(getline(line_num),"^[ ]*","","")
        let k = substitute(k,"[ ]*$","","")
        if !has_key(matches,k) && strlen(k) > 0
          let matches[k] = 1
        endif
      endif
      let line_num = line_num + 1
      call cursor(line_num, 1) 
    endwhile
   
    for key in sort(keys(matches))
      call add(names, key)
    endfor

    for n in names
      if n =~ '^' . a:base
        call add(res, n)
      endif
    endfor
    return res
  endif
endfun
set completefunc=ScreenplayCompleteCharacterName

call Scene()
