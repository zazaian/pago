"
" Pago
" screenwriting for vim
" Version:      0.1.3
" Updated:      2008-10-19
" Maintainer:   Mike Zazaian, mike@zop.io, http://zop.io
" Originator:   Alex Lance, alla at cyber.com.au
" License:      This file is placed in the public domain.
"
" Pago allows the use of vim as a fully-functional piece of screenwritng
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
" Known Bugs
" 1: Backspace doesn't call new elements when jumping to a previous line. 
" 2: Remove cursor() call in each ELEMENT function which sets the cursor to the end
" of the line automatically
" 3: URGENT need for a function that automatically wraps and formats text if the word
" count goes over the "end" value for a given element
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
imap <BS> <C-R>=ScreenplayBackspacePressed()<CR><C-R>=ElementDetect("backspace")<CR>
imap  <C-R>=ScreenplayBackspacePressed()<CR>
ino <Up> <Up><C-R>=ElementDetect("up")<CR>
ino <Down> <Down><C-R>=ElementDetect("down")<CR>
" no <Insert> <Insert><C-R>=ElementDetect("insert")<CR>
no <Up> <Insert><Up><C-R>=ElementDetect("up")<CR><Esc>
no <Down> <Insert><Down><C-R>=ElementDetect("down")<CR><Esc>

ino <Space> <Space><C-R>=SceneStart()<CR><Esc>
no <Space> <Space><C-R>=SceneStart()<CR><Esc>


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
  if g:current == "transition"
     let rtn = "\<Esc>:s/^\ //\<CR>:let @/ =\"\"\<CR>A\<Left>"
"     let [lnum, s:whitespace] = searchpos("[A-Za-z_:]", "bnc" , line("."))
"     let s:movements = 70 - s:whitespace
"     let s:taprepend = repeat('\<Left\>', s:movements)
"     let s:tamiddle = "\<bs>"
"     let s:taappend = repeat('\<Right\>', s:movements)
"     let rtn = s:taprepend . s:tamiddle . s:taappend
  else
    let rtn = ""
  endif
  return rtn
endfu

" Dictionary Definitions
let g:alphalower = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
let g:alphaupper = []
for n in g:alphalower
  exe "let N = toupper('" . n . "')"
  exe "let g:alphaupper += ['" . N . "']"
endfor
let g:alphaall = g:alphalower + g:alphaupper
let g:otherkeys = ['<Space>','!','.','-','?']

" Definition of Accepted Screenplay Characters
let g:screenchars = "[A-Za-z_0-9\?\!\.\-]"
let g:emptyline = "[^ ].*"

fu! MapUppercase()  
  if g:current == "transition"
    let g:premap = "<C-R>=TransitionAdjust()<CR>"
  else
    let g:premap = ""
  endif
  
  for n in g:alphaall
    exe "ino " . n . " " . g:premap . toupper(n)
  endfor

  for key in g:otherkeys
    let key1 = key
    let key2 = key

    if g:current == "scene"
      let g:premap = "<C-R>=SceneStart()<CR>"
      let key2 = ""
    else
      let g:premap = g:premap
      let key2 = key2
    endif

    exe "ino " . key1 . " " . g:premap . key2
  endfor

  return ""
endfu

fu! UnmapUppercase()
  for n in g:alphaall
    execute "ino " . n . " " . n
  endfor

  return ""
endfu

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
  
  let g:statustxt = toupper(g:current)
  set statusline=%<[%02n]\ %F%(\ %m%h%w%y%r%)\ %{g:statustxt}\ %a%=\ %8l,%c%V/%L\ (%P)\ [%08O:%02B]

"  call cursor(line("."), a:begins)

  return ''

endfu

fu! ElementDetect(direction)

  " Check if new line is empty.  If so, move on to next line before detecting
  " element
  let [s:newlinestart, s:newlineend, s:newline, s:nextline] = NewLineRange(".", a:direction)
  if s:newlinestart == 11 && s:newlineend == 11
    call cursor(s:nextline, col("$"))
  endif

  " Detect indent of new line
  let s:indent = indent(line("."))
  let s:colon = ColonPos(".")
  let s:colonend = ColonEnd(".")
  let s:lowerchars = LowerChars(".")
  let s:chars = LineStart(".")
  let s:x_coord = col(".")

  if s:colon != 70 && s:colonend < 1 
    if s:indent < 10 
      return repeat("\<BS>", s:x_coord - 1) . repeat(' ', 10)
    elseif s:indent == 10
      " Check whether the line is a SCENE element
      let s:n = search('^[ ].*[INT|EXT]\.', 'bncp', line("."))
      " Check whether there are any lowercase characters on the line
      let s:l = search('[a-z]', 'ncp', line("."))
      if s:n > 0 && s:l < 1
        call Scene(a:direction)
      else
        call Action(a:direction)
      endif
    elseif s:indent == 20 
      call Dialogue(a:direction)
    elseif s:indent == 25
      call Parenthetical(a:direction)
    elseif s:indent == 30
      call Character(a:direction)
    endif
  elseif s:colon == 70 || s:colonend > 0
    call Transition(a:direction)
  else
    call Action(a:direction)
  endif

  return ''

 
endfu

" Line Length and Cursor Position Functions
fu! LineStart(line_num)
  let [s:lnum, s:linestart] = searchpos("[^ ].*", "bnc", line(a:line_num))
  return s:linestart
endfu

fu! LineEnd(line_num)
  let [s:lnum, s:endline] = searchpos("$", "nc", line(a:line_num))
  return s:endline
endfu

fu! ColonPos(line_num)
  let [s:lnum, s:colonpos] = searchpos(":", "enc", line(a:line_num))
  return s:colonpos
endfu

fu! ColonEnd(line_num)
  let s:colonend = search(":$", "enc", line(a:line_num))
  return s:colonend
endfu

fu! CursorPos(line_num)
    let [s:buffer, s:lnum, s:cursorpos, s:off] = getpos(a:line_num)
    return s:cursorpos
endfu

fu! LowerChars(line_num)
  let s:lowerchars = search("[a-z]", "enc", line(a:line_num))
  return s:lowerchars
endfu


fu! NewLineRange(line_num, key_pressed)
  let s:newline = line(a:line_num)

  if a:key_pressed == "up" || a:key_pressed == "backspace"
    let s:nextline = s:newline - 1
  elseif a:key_pressed == "down"
    let s:nextline = s:newline + 1
  endif

  let s:newlinestart = LineStart(s:newline)
  let s:newlineend = LineEnd(s:newline)
  let s:newlinerange = [s:newlinestart, s:newlineend, s:newline, s:nextline]
  return s:newlinerange
endfu


" End Line Length and Cursor Position Functions

" Various Helper Functions
fu! ClearSearch()
  let s:rtn = ':let @/=\"\"\<CR>'
  return s:rtn
endfu

" If SCENE is the active element, cycle through scene prefixes with the <Space> bar
fu! SceneStart()
  if g:current == "scene"

    let s:scenelist = search('\(INT\.\ \)\|\(EXT\.\ \)\|\(INT\.\/EXT\.\ \)\|\([^EXT\. |INT\. |INT\.\/EXT\. ]\)', "bncpe", line("."))
    let s:lineend = LineEnd(".")
    
    if s:scenelist != 5
      let s:clearsearch = ":let @/ = \"\"\<CR>"
      if s:scenelist == 0
        let s:rtn = "INT. "
      elseif s:scenelist == 2
        let s:rtn = "\<Esc>:s/INT\\. .*/EXT\\. /\<CR>" . s:clearsearch . "A"
      elseif s:scenelist == 3
        let s:rtn = "\<Esc>:s/EXT\\. .*/INT\\.\\/EXT\\. /\<CR>" . s:clearsearch . "A"
      elseif s:scenelist == 4
        let s:rtn = "\<Esc>:s/INT\\.\\/EXT\. .*/INT\\. /\<CR>" . s:clearsearch . "A"
      endif

"      let s:reset = repeat("\<Backspace>", s:lineend - 1) . repeat("\<Space>", 10)
"      if s:scenelist == 0 || s:scenelist == 4
"        let s:rtn = s:reset . "INT. "
"      elseif s:scenelist == 2
"        let s:rtn = s:reset . "EXT. "
"      elseif s:scenelist == 3
"        let s:rtn = s:reset . "INT./EXT. "
"      endif

    else
      let s:rtn = "\<Space>"
    endif
  
  else
    let s:rtn = "\<Space>"
  endif

  return s:rtn
endfu


" 
" fu! BackspaceAdjust()
"   let s:linestart = LineStart(".")
"   let s:colonpos = ColonPos(".")
"   let s:endline = LineEnd(".")
"   let s:x_coord = col(".")
" 
"   if s:linestart == 0
"   elseif s:linestart == 11
"     let s:rtn = Action("none")
"   elseif s:linestart == 21
"     let s:rtn = Dialogue("none")
"   elseif s:linestart == 26
"     let s:rtn = Parenthetical("none")
"   elseif s:linestart == 31
"     let s:rtn = Character("none")
"   elseif s:colonpos == 70
"     let s:rtn = Transition("none")
"   endif
" 
"   call cursor(line("."), s:endline)
"   return s:rtn
" endfu


let scene = { 'name': 'scene', 'begins': 11, 'ends': 70, 'case': 'upper', 'align': 'L' }
let action = { 'name': 'action', 'begins': 11, 'ends': 70, 'case': 'lower', 'align': 'L' }
let dialogue = { 'name': 'dialogue', 'begins': 21, 'ends': 55, 'case': 'lower', 'align': 'L' }
let parenthetical = { 'name': 'parenthetical', 'begins': 21, 'ends': 55, 'case': 'lower', 'align': 'L' }
let character = { 'name': 'character', 'begins': 31, 'ends': 70, 'case': 'upper', 'align': 'L' }
let transition = { 'name': 'transition', 'begins': 70, 'ends': 11, 'case': 'upper', 'align': 'R' }

fu! Scene(key_pressed)
  let g:current = "scene"
  let s:begins = 11
  let s:ends = 70
  let s:case = "upper"
  let s:x_coord = col(".")
  call ElementHelper(s:begins, s:ends, s:case)
  
  if a:key_pressed == "tab"
    let s:rtn = "\<Del>" . repeat("\<BS>", s:x_coord - 1) . repeat(' ', s:begins - 1)
  elseif a:key_pressed == "backspace"
    let [s:lnum, s:col] = searchpos(g:emptyline, "bnc", line("."))
    if s:col > 0
      let s:rtn = "\<BS>"
    else
      let s:rtn = repeat("\<BS>", s:x_coord)
    endif
  elseif a:key_pressed == "enter"
    let s:rtn = "\<Enter>"
  else
    let s:rtn = ""
    let s:endline = LineEnd(".")
    call cursor(line("."), s:endline)
  endif

  return s:rtn
endfu

fu! Action(key_pressed)
  let g:previous = g:current
  let g:current = "action"
  let s:begins = 11
  let s:ends = 70
  let s:x_coord = col(".")
  let s:case = "lower"
  call ElementHelper(s:begins, s:ends, s:case)
  
  if a:key_pressed == "tab"
    let s:rtn = "\<Del>" . repeat("\<BS>", s:x_coord - 1) . repeat(' ', s:begins - 1)
  elseif a:key_pressed == "enter"
    let [s:lnum, s:chars] = searchpos(g:emptyline, "bnc", line("."))
    if s:chars > 0
      let s:rtn = "\<CR>\<CR>"
    else
      if exists("g:switch")
        let g:switch += 1
      else
        let g:switch = 1
      endif

      let s:rtn = ""
      if g:previous == "action"
        call Scene("none")
      endif
      if g:switch == 2
        let s:rtn = "\<CR>\<CR>"
        let g:switch = 0
      endif
    endif
  elseif a:key_pressed != "backspace"
    let s:rtn = ""
    let s:endline = LineEnd(".")
    call cursor(line("."), s:endline)
  endif

  return s:rtn
endfu

fu! Dialogue(key_pressed)
  let s:x_coord = col(".")
  let g:previous = g:current
  let g:current = "dialogue"
  let s:begins = 21
  let s:ends = 55
  let s:case = "lower"
  call ElementHelper(s:begins, s:ends, s:case)
  
  if a:key_pressed == "tab"
    let s:x_change = s:begins - s:x_coord
    let s:rtn = repeat(' ', s:x_change)
  elseif a:key_pressed == "backspace"
    let [lnum, col] = searchpos(g:emptyline , "bnc", line(".")) 
    if col > 0
      let s:rtn = "\<BS>"
    else
      let s:rtn = repeat("\<BS>", 10)
    endif
  elseif a:key_pressed == "enter"    
    if g:previous == "parenthetical"
      let [s:lnum, s:endofline] = searchpos("$", "nc", line("."))
      call cursor(line("."), s:endofline)
      let s:rtn = "\<CR>\<Esc>I".repeat(' ', s:begins - 1)
    elseif g:previous == "character"
      let s:rtn = "\<CR>\<Esc>I".repeat(' ', s:begins - 1)
    endif
  else
    let s:rtn = ""
    let s:endline = LineEnd(".")
    call cursor(line("."), s:endline)
  endif

  return s:rtn
endfu

fu! Parenthetical(key_pressed)
  let g:current = "parenthetical"
  let s:begins = 26
  let s:ends = 55
  let s:x_coord = col(".")
  let s:case = "lower"
  call ElementHelper(s:begins, s:ends, s:case)

  if a:key_pressed == "tab"
    let s:x_change = s:begins - s:x_coord
    let s:rtn = repeat(' ', s:x_change) . "()\<Left>"
  elseif a:key_pressed == "backspace"
    let [lnum, col] = searchpos(g:emptyline , "bnc", line(".")) 
    if col > 0
      let s:rtn = "\<BS>"
    else
      let [lnum, openparen] = searchpos("(", "bnc", line("."))
      let [lnum, closeparen] = searchpos(")", "bnc", line("."))  
      let s:backspaces = 5
      if openparen > 0
        let s:backspaces += 1
      endif
      if closeparen > 0
        let s:backspaces += 1
      endif

      let s:rtn = "\<right>" . repeat("\<BS>", s:backspaces)
    endif
  else
    let s:rtn = ""
    let s:endline = LineEnd(".")
    call cursor(line("."), s:endline)
  endif

  return s:rtn
endfu

fu! Character(key_pressed)
  let g:current = "character"
  let s:begins = 31
  let s:ends = 70
  let s:x_coord = col(".")
  let s:case = "upper"
  call ElementHelper(s:begins, s:ends, s:case)
  
  if a:key_pressed == "tab"
    let s:x_change = s:begins - s:x_coord
    let s:rtn = "\<Left>\<Del>\<Del>" . repeat(' ', s:x_change + 1)
  elseif a:key_pressed == "backspace"
    let [lnum, col] = searchpos(g:screenchars , "bnc", line(".")) 
    if col > 0
      let s:rtn = "\<BS>"
    else
      let s:rtn = repeat("\<BS>", 5) . "()\<left>"
    endif
  elseif a:key_pressed == "enter"
    let s:rtn = "\<CR>\<CR>\<Esc>I".repeat(' ', s:begins - 1)
  else
    let s:rtn = ""
    let s:endline = LineEnd(".")
    call cursor(line("."), s:endline)
  endif

  return s:rtn
endfu

fu! Transition(key_pressed)
  let g:current = "transition"
  let s:begins = 70
  let s:ends = 11
  let s:x_coord = col(".")
  let s:case = "upper"
  call ElementHelper(s:begins, s:ends, s:case)
  set tw=1000

  let [lnum, col] = searchpos(g:emptyline , 'bnc', line("."))
  if a:key_pressed == "tab"
"    if col > 0
    let s:x_change = s:begins - s:x_coord
    let s:rtn = repeat(' ', s:x_change) . ":\<Left>"
  elseif a:key_pressed == "backspace"
    if col > 0
      let s:rtn = "\<BS>\<Esc>:s/^/ /\<CR>:let @/ =\"\"\<CR>A\<Left>"
      echo col
    else
      let s:rtn = "\<Del>\<Esc>A" . repeat("\<BS>", 39)
    endif
  else
    let s:rtn = ""
    let s:endline = LineEnd(".")
    call cursor(line("."), s:endline)
  endif

  return s:rtn
endfu


fu! ScreenplayEnterPressed()
  let s:key = "enter"
   
    if g:current == "scene"
      let s:rtn = Action(s:key)
    elseif g:current == "action"
      let s:rtn = Action(s:key)
    elseif g:current == "dialogue"
      let s:rtn = Character(s:key)
    elseif g:current == "parenthetical"
      let s:rtn = Dialogue(s:key)
    elseif g:current == "character"
      let s:rtn = Dialogue(s:key)
    elseif g:current == "transition"
      let s:rtn = Scene(s:key)
    endif
  
    return s:rtn
endfu


function! ScreenplayTabPressed()
  let s:key = "tab"
  
    if g:current == "action" || g:current == "scene"
      let s:rtn = Dialogue(s:key)
    elseif g:current == "dialogue"
      let s:rtn = Parenthetical(s:key)
    elseif g:current == "parenthetical"
      let s:rtn = Character(s:key)
    elseif g:current == "character"
      let s:rtn = Transition(s:key)
    elseif g:current == "transition"
      let s:rtn = Action(s:key)
    endif

  return s:rtn 
endfunction


function! ScreenplayBackspacePressed()
  let s:key = "backspace"
  let s:cursorpos = CursorPos(".")
  let s:linestart = LineStart(".")
  let s:x_coord = col(".")
   
    if g:current == "transition"
      let s:rtn = Transition(s:key)
    elseif g:current == "character"
      let s:rtn = Character(s:key)
    elseif g:current == "parenthetical"
      let s:rtn = Parenthetical(s:key)
    elseif g:current == "dialogue"
      let s:rtn = Dialogue(s:key)
    elseif g:current == "action" || g:current == "scene"
      if s:linestart > 0 && s:cursorpos != 11
        let s:rtn = "\<BS>"
      else
        let s:rtn = repeat("\<BS>", s:x_coord)
        let [s:newlinestart, s:newlineend, s:newline, s:nextline] = NewLineRange(".", "backspace")
        if s:newlinestart <= 10
          let s:rtn = s:rtn . repeat(" ", 10)
        endif
      endif
    endif

  return s:rtn
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

if !exists("g:current")
  let g:current = "action"
  call Action("none")
endif
