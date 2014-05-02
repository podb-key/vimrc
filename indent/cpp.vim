" script local variables
let s:entries=0
let s:previous_vim_lnum=0
let s:script_name=expand("<sfile>:t")

let b:ab_indent=[]
let b:scope=[]

let b:class_declaration=0

" only load this indent file when no other was loaded already
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

let b:DEBUGGING = 1

setlocal indentexpr=CppIndent()
setlocal shiftwidth=3
setlocal expandtab
setlocal nowrap
setlocal cindent

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" debug_log
"
" log message on the command line
" use :messages to review all logging
function! DebugLog(msg)
   if exists("b:DEBUGGING") && b:DEBUGGING
      echomsg '['.s:entries.']'.s:script_name."::".a:msg
   endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" check if line is comment
"
" simple comments beginning with //
function! MatchSimpleComment(line)
   let l:result = (a:line =~# '^\s*\/\/.*$') 
   return l:result
endfunction

" comment blocks starting with /* [...]  and stopping with */ [// ...] 
function! MatchCommentBlockStart(line)
   let l:start_block = (a:line =~# '^\s*\/\*.*$') 
   return l:start_block 
endfunction

function! MatchCommentBlockStop(line)
   let l:stop_block = (a:line =~# '^.*\*\/\s*\(\/\/.*$\|$\)') 
   return l:stop_block
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cpp_indent
"
" enhanced indentation for c++ source files
function! CppIndent()

   " store ignorecase state
   let l:ignore_case = &ignorecase
   set noignorecase

   " increase entry count (for debug logging)
   let s:entries = s:entries + 1

   " current line info
   let l:clnum = v:lnum
   let l:cline = getline(v:lnum)

   call DebugLog("indenting line ".l:clnum)

   " first line check
   let l:plnum=prevnonblank(l:clnum)
   if l:plnum==0 " . == <first line>

      b:ab_indent=[]
      b:scope=[]

      let b:class_declaration=0

      if l:ignore_case | set ignorecase | endif

      return 0
   endif

   " store indendation at each scope
   if (l:cline =~# '^.\{-\}{.*$') > 0 " new scope
      call DebugLog("scope open at ".l:clnum)

      call add(b:scope, [cindent(l:clnum), b:class_declaration])

      if b:class_declaration==1
         call DebugLog("entering class body declaration at ".l:clnum)
         let b:class_declaration=0
         return cindent(l:clnum) + &sw
      endif

      let b:class_declaration=0
   endif

   if (l:cline =~# '^.\{-\};.*$') > 0 " end of expression
      call DebugLog("end of expression at ".l:clnum)
      let b:class_declaration=0
   endif

   if (l:cline =~# '^.\{-\}}.*$') > 0 " scope closed
      call DebugLog("scope closed at ".l:clnum)
      if !empty(b:scope)
         call remove(b:scope, -1)
      endif
      let b:class_declaration=0
   endif

   " indent Qt specific stuff
   if (l:cline =~# '^\s*\(public\|protected\|private\)\s*:.*$') > 0
      if !empty(b:scope)
         return b:scope[-1][0] + 2*&sw
      endif
   endif

   if (l:cline =~# '^\s*signals\s*:.*$') > 0
      if !empty(b:scope)
         return b:scope[-1][0] + 2*&sw
      endif
   endif

   if (l:cline =~# '^\s*\(public\|protected\|private\)\=\s*slots\s*:.*$') > 0
      if !empty(b:scope)
         return b:scope[-1][0] + 2*&sw
      endif
   endif

   if (l:cline =~# '^\s*friend\s*:.*$') > 0
      if !empty(b:scope)
         return b:scope[-1][0] + 2*&sw
      endif
   endif

   " handle class declaration
   if (l:cline =~# '^.\{-\}\s\(class\|struct\)\s\+.*$') > 0 " class declaration
      let b:class_declaration=1
   endif

   if !empty(b:scope)
      if b:scope[-1][1]==1
         let l:c_indent=cindent(l:plnum)
         call DebugLog("at ".l:clnum.": scope=".b:scope[-1][0]." - indent=".l:c_indent)
         if b:scope[-1][0]==l:c_indent - 2*&sw
            return l:c_indent + &sw
         endif
      endif
   endif

   " angle bracket processing (for nicer template indendation)
   "
   " known issues
   "   . == is not working as expected
   "   . template follwed by comment lines
   "   . after template you probably do not want to indent (except when '<' or prev line was 'template<' of course)
   if (l:cline =~# '^\s*<\s*$') > 0 " opening angle bracket: '<'
      if empty(b:ab_indent) 
         let l:p_c_indent=cindent(l:plnum)
         call add(b:ab_indent, l:p_c_indent)
      endif

      let l:c_indent=get(b:ab_indent,-1) + &sw
      call add(b:ab_indent, l:c_indent)

   elseif (l:cline =~# '^\s*>.*$') > 0 " closing angle bracket: '>[possibly other atoms]'
      if !empty(b:ab_indent)
         let l:c_indent = remove(b:ab_indent, -1)
      else
         call DebugLog("Either there is a line with a greater-then as first character or you used == which is not yet working as expected (use gg=G).")
         let l:c_indent = cindent(l:clnum)
      endif

   elseif len(b:ab_indent) == 1 " first line outside last closing angle bracket - restore cindent value
      let l:c_indent = remove(b:ab_indent, -1)

   elseif len(b:ab_indent) > 1 " inside angle brackets
      let l:c_indent = get(b:ab_indent,-1) + 1

   else " fall through to cindent
      let l:c_indent = cindent(l:clnum)
   endif

   return l:c_indent

endfunction

" undo shiftwidth, expandtab, nowrap, cindent and indentexpr when killing the
" active buffer
let b:undo_indent = "setl sw< et< wrap< cin< inde<"
