"
"
" Blankpage
" a screenwriting plugin for vim
" Version:      0.0.1
" Updated:  2008-10-05
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
"    :au BufRead,BufNewFile *.bp    set filetype=blankpage
"  * Ensure the suffix the file you are editing is .bp and away you
"    go!
"
"
"


" Avoid loading this twice
if exists("loaded_blankpage")
  finish
endif
let loaded_blankpage = 1
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
set expandtab     " Change tabs into spaces
set softtabstop=0 " softtabstop variable can break my custom backspacing
set autoindent    " Set auto indent
set ff=unix       " use unix fileformat


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
 
  " Name -> Dialog
  if col == 31 && !pumvisible()
    set tw=55
    let rtn = "\<CR>\<Esc>I".repeat(' ', 20)

  " Parenthentical -> Dialogue
  if col == 26 && !pumvisible()
    set tw=55
    let rtn = "\<CR>\<Esc>I".repeat(' ', 20)

  " Dialog -> New Name
  elseif col == 21
    set tw=55
    let rtn = "\<CR>\<CR>\<Esc>I".repeat(' ', 30)

  " Dialog -> Action
  elseif prev_col == 21 && col == 0
    set tw=70
    let rtn = "\<Esc>I".repeat("\<BS>", 10)
  endif

  "return rtn .prev_col." - ".col
  return rtn 
endfunction


function! ScreenplayTabPressed()
  let s:x = 4
  let s:extra = ""
  let s:coord = col(".")
  set tw=70
  
  if s:coord < 21
    let s:x = 21 - s:coord
  elseif s:coord < 26
    set tw=55
    let s:x = 26 - s:coord
    let s:extra = "\(\)\<Left>"
  elseif s:coord < 31
    set tw=55
    let s:x = 31 - s:coord
  elseif s:coord >= 31
    let s:x = 0
    let s:extra = "\<C-X>\<C-U>"
  endif
  
  return repeat(' ', s:x) . s:extra
endfunction


function! ScreenplayBackspacePressed()
  let [lnum, col] = searchpos('[^ ].*', 'bn', line("."))
  let s:x = 1
  
  if col == 0
    let s:coord = col(".")

    if s:coord > 31
      let s:x = s:coord - 31
    elseif s:coord > 26
      let s:x = s:coord - 26
    elseif s:coord > 21
      let s:x = s:coord - 21
    elseif s:coord == 11
      let s:x = s:coord - 0
    elseif s:coord > 0
      let s:x = s:coord - 1
    endif
  endif

  return repeat("\<BS>", s:x)
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


