if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

" from what i've read around online people generally use four columns (label,
" mnemonic, operand, comment) but the actual tabstops vary wildly so I'm just
" going to leave it like this
let s:indentInstruction = 1
let s:indentComment = 2


setlocal indentexpr=GetNasmIndent(v:lnum)
setlocal indentkeys+=<:>,<SPACE>,;,.,%

if exists("*GetNasmIndent")
  finish
endif

" match labels with a colon or containing/beginning with a dot, and labels
" followed by db or similar (but not in comments)
let s:matchLabel = '^\s*\w*[:.]\|^[^;]*\<\(d\|res\)\%([bwd]\|d\?q\)\>'

" directives that are not actual instructions
" TODO make sure this is complete
let s:matchDirective = '^\s*\<\%(absolute\|bits\|use\%(32\|16\)\|alignb\?\|global\|extern\|default\|\%(end\)\?\%(struct\?\|union\|segment\|section\)\|\%(no\)split\|incbin\|equ\)\>'

" preprocessor directives that start with %
let s:matchPreprocessor = '^\s*%'

" comments
let s:matchComment = '^\s*;'

function! s:GetPrevContentLineNum(line_num)
  let l:nline = a:line_num
  while l:nline > 0
    let l:nline = prevnonblank(l:nline - 1)
    if getline(l:nline) !~? s:matchComment .'\|'. s:matchPreprocessor .'\|'. s:matchDirective
      break
    endif
  endwhile
  return l:nline
endfunction

function! GetNasmIndent(lnum)
  let this_line = getline(a:lnum)

  if this_line =~? s:matchLabel .'\|'. s:matchPreprocessor .'\|'. s:matchDirective
    return 0
  endif

  " comments
  if this_line =~? s:matchComment
    let l:indentComment = s:indentComment
    if &expandtab
      let l:indentComment *= &shiftwidth
    else
      let l:indentComment *= &tabstop
    endif

    " try to match other nearby comments, otherwise use default
    if a:lnum == 0
      return l:indentComment
    endif

    let l:prev_code_num = prevnonblank(a:lnum-1)
    if getline(l:prev_code_num) =~? s:matchComment
      return indent(l:prev_code_num)
    endif

    return l:indentComment
  endif

  " instructions
  let prev_code_num = s:GetPrevContentLineNum(a:lnum)
  let prev_code = getline(prev_code_num)

  if prev_code =~? s:matchLabel || prev_code_num == 0
    if &expandtab
      return s:indentInstruction * &shiftwidth
    else
      return s:indentInstruction * &tabstop
    endif
  endif

  return indent(prev_code_num)

endfunction

