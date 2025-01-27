" Vim syntax file
" Language:     NASM - The Netwide Assembler (v0.98)
" Maintainer:   Andrii Sokolov  <andriy145@gmail.com>
" Original Author:      Manuel M.H. Stol        <Manuel.Stol@allieddata.nl>
" Former Maintainer:    Manuel M.H. Stol        <Manuel.Stol@allieddata.nl>
" Contributors: Leonard König <leonard.r.koenig@gmail.com> (C string highlighting)
" Last Change:  2023 Jan 6
" NASM Home:    http://www.nasm.us/



" Setup Syntax:
" quit when a syntax file was already loaded
if exists("b:current_syntax")
    finish
endif
"  Assembler syntax is case insensetive
syn case ignore



" Vim search and movement commands on identifers
"  Comments at start of a line inside which to skip search for indentifiers
setlocal comments=:;
"  Identifier Keyword characters (defines \k)
setlocal iskeyword=@,48-57,#,$,.,?,@-@,_,~


" Comments:
syn region  nasmComment         start=";" keepend end="$" contains=@nasmGrpInComments
syn region  nasmSpecialComment  start=";\*\*\*" keepend end="$"
syn keyword nasmInCommentTodo   contained TODO FIXME XXX[XXXXX]
syn cluster nasmGrpInComments   contains=nasmInCommentTodo
syn cluster nasmGrpComments     contains=@nasmGrpInComments,nasmComment,nasmSpecialComment



" Label Identifiers:
"  in NASM: 'Everything is a Label'
"  Definition Label = label defined by %[i]define or %[i]assign
"  Identifier Label = label defined as first non-keyword on a line or %[i]macro
syn match   nasmLabelError      "$\=\(\d\+\K\|[#.@]\|\$\$\k\)\k*\>"
syn match   nasmLabel           "\<\(\h\|[?@]\)\k*\>"
syn match   nasmLabel           "[\$\~]\(\h\|[?@]\)\k*\>"lc=1
"  Labels starting with one or two '.' are special
syn match   nasmLocalLabel      "\<\.\(\w\|[#$?@~]\)\k*\>"
syn match   nasmLocalLabel      "\<\$\.\(\w\|[#$?@~]\)\k*\>"ms=s+1
if !exists("nasm_no_warn")
    syn match  nasmLabelWarn      "\<\~\=\$\=[_.][_.\~]*\>"
endif
if exists("nasm_loose_syntax")
    syn match   nasmSpecialLabel  "\<\.\.@\k\+\>"
    syn match   nasmSpecialLabel  "\<\$\.\.@\k\+\>"ms=s+1
    if !exists("nasm_no_warn")
        syn match   nasmLabelWarn   "\<\$\=\.\.@\(\d\|[#$\.~]\)\k*\>"
    endif
    " disallow use of nasm internal label format
    syn match   nasmLabelError    "\<\$\=\.\.@\d\+\.\k*\>"
else
    syn match   nasmSpecialLabel  "\<\.\.@\(\h\|[?@]\)\k*\>"
    syn match   nasmSpecialLabel  "\<\$\.\.@\(\h\|[?@]\)\k*\>"ms=s+1
endif
"  Labels can be dereferenced with '$' to destinguish them from reserved words
syn match   nasmLabelError      "\<\$\K\k*\s*:"
syn match   nasmLabelError      "^\s*\$\K\k*\>"
syn match   nasmLabelError      "\<\~\s*\(\k*\s*:\|\$\=\.\k*\)"



" Constants:
syn match   nasmStringError     +["'`]+
" NASM is case sensitive here: eg. u-prefix allows for 4-digit, U-prefix for
" 8-digit Unicode characters
syn case match
" one-char escape-sequences
syn match   nasmCStringEscape  display contained "\\[’"‘\\\?abtnvfre]"
" hex and octal numbers
syn match   nasmCStringEscape  display contained "\\\(x\x\{2}\|\o\{1,3}\)"
" Unicode characters
syn match   nasmCStringEscape   display contained "\\\(u\x\{4}\|U\x\{8}\)"
" ISO C99 format strings (copied from cFormat in runtime/syntax/c.vim)
syn match   nasmCStringFormat   display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
syn match   nasmCStringFormat   display "%%" contained
syn match   nasmString          +\("[^"]\{-}"\|'[^']\{-}'\)+
" Highlight C escape- and format-sequences within ``-strings
syn match   nasmCString +\(`[^`]\{-}`\)+ contains=nasmCStringEscape,nasmCStringFormat extend
syn case ignore
syn match   nasmBinNumber       "\<[0-1]\+b\>"
syn match   nasmBinNumber       "\<\~[0-1]\+b\>"lc=1
syn match   nasmOctNumber       "\<\o\+q\>"
syn match   nasmOctNumber       "\<\~\o\+q\>"lc=1
syn match   nasmDecNumber       "\<\d\+\>"
syn match   nasmDecNumber       "\<\~\d\+\>"lc=1
syn match   nasmHexNumber       "\<\(\d\x*h\|0x\x\+\|\$\d\x*\)\>"
syn match   nasmHexNumber       "\<\~\(\d\x*h\|0x\x\+\|\$\d\x*\)\>"lc=1
syn match   nasmFltNumber       "\<\d\+\.\d*\(e[+-]\=\d\+\)\=\>"
syn keyword nasmFltNumber       Inf Infinity Indefinite NaN SNaN QNaN
syn match   nasmNumberError     "\<\~\s*\d\+\.\d*\(e[+-]\=\d\+\)\=\>"


" Netwide Assembler Storage Directives:
"  Storage types
syn keyword nasmTypeError       DF EXTRN FWORD RESF TBYTE
syn keyword nasmType            FAR NEAR SHORT
syn keyword nasmType            BYTE WORD DWORD QWORD DQWORD HWORD DHWORD TWORD
syn keyword nasmType            CDECL FASTCALL NONE PASCAL STDCALL
syn keyword nasmStorage         DB DW DD DQ DDQ DT
syn keyword nasmStorage         RESB RESW RESD RESQ RESDQ REST
syn keyword nasmStorage         EXTERN GLOBAL COMMON
"  Structured storage types
syn match   nasmTypeError       "\<\(AT\|I\=\(END\)\=\(STRUCT\=\|UNION\)\|I\=END\)\>"
syn match   nasmStructureLabel  contained "\<\(AT\|I\=\(END\)\=\(STRUCT\=\|UNION\)\|I\=END\)\>"
"   structures cannot be nested (yet) -> use: 'keepend' and 're='
syn cluster nasmGrpCntnStruc    contains=ALLBUT,@nasmGrpInComments,nasmMacroDef,@nasmGrpInMacros,@nasmGrpInPreCondits,nasmStructureDef,@nasmGrpInStrucs
syn region  nasmStructureDef    transparent matchgroup=nasmStructure keepend start="^\s*STRUCT\>"hs=e-5 end="^\s*ENDSTRUCT\>"re=e-9 contains=@nasmGrpCntnStruc
syn region  nasmStructureDef    transparent matchgroup=nasmStructure keepend start="^\s*STRUC\>"hs=e-4  end="^\s*ENDSTRUC\>"re=e-8  contains=@nasmGrpCntnStruc
syn region  nasmStructureDef    transparent matchgroup=nasmStructure keepend start="\<ISTRUCT\=\>" end="\<IEND\(STRUCT\=\)\=\>" contains=@nasmGrpCntnStruc,nasmInStructure
"   union types are not part of nasm (yet)
"syn region  nasmStructureDef   transparent matchgroup=nasmStructure keepend start="^\s*UNION\>"hs=e-4 end="^\s*ENDUNION\>"re=e-8 contains=@nasmGrpCntnStruc
"syn region  nasmStructureDef   transparent matchgroup=nasmStructure keepend start="\<IUNION\>" end="\<IEND\(UNION\)\=\>" contains=@nasmGrpCntnStruc,nasmInStructure
syn match   nasmInStructure     contained "^\s*AT\>"hs=e-1
syn cluster nasmGrpInStrucs     contains=nasmStructure,nasmInStructure,nasmStructureLabel



" PreProcessor Instructions:
" NAsm PreProcs start with %, but % is not a character
syn match   nasmPreProcError    "%{\=\(%\=\k\+\|%%\+\k*\|[+-]\=\d\+\)}\="
if exists("nasm_loose_syntax")
    syn cluster nasmGrpNxtCtx     contains=nasmStructureLabel,nasmLabel,nasmLocalLabel,nasmSpecialLabel,nasmLabelError,nasmPreProcError
else
    syn cluster nasmGrpNxtCtx     contains=nasmStructureLabel,nasmLabel,nasmLabelError,nasmPreProcError
endif

"  Multi-line macro
syn cluster nasmGrpCntnMacro    contains=ALLBUT,@nasmGrpInComments,nasmStructureDef,@nasmGrpInStrucs,nasmMacroDef,@nasmGrpPreCondits,nasmMemReference,nasmInMacPreCondit,nasmInMacStrucDef
syn region  nasmMacroDef        matchgroup=nasmMacro keepend start="^\s*%macro\>"hs=e-5 start="^\s*%imacro\>"hs=e-6 end="^\s*%endmacro\>"re=e-9 contains=@nasmGrpCntnMacro,nasmInMacStrucDef
if exists("nasm_loose_syntax")
    syn match  nasmInMacLabel     contained "%\(%\k\+\>\|{%\k\+}\)"
    syn match  nasmInMacLabel     contained "%\($\+\(\w\|[#\.?@~]\)\k*\>\|{$\+\(\w\|[#\.?@~]\)\k*}\)"
    syn match  nasmInMacPreProc   contained "^\s*%\(push\|repl\)\>"hs=e-4 skipwhite nextgroup=nasmStructureLabel,nasmLabel,nasmInMacParam,nasmLocalLabel,nasmSpecialLabel,nasmLabelError,nasmPreProcError
    if !exists("nasm_no_warn")
        syn match nasmInMacLblWarn  contained "%\(%[$\.]\k*\>\|{%[$\.]\k*}\)"
        syn match nasmInMacLblWarn  contained "%\($\+\(\d\|[#\.@~]\)\k*\|{\$\+\(\d\|[#\.@~]\)\k*}\)"
        hi link nasmInMacCatLabel   nasmInMacLblWarn
    else
        hi link nasmInMacCatLabel   nasmInMacLabel
    endif
else
    syn match  nasmInMacLabel     contained "%\(%\(\w\|[#?@~]\)\k*\>\|{%\(\w\|[#?@~]\)\k*}\)"
    syn match  nasmInMacLabel     contained "%\($\+\(\h\|[?@]\)\k*\>\|{$\+\(\h\|[?@]\)\k*}\)"
    hi link nasmInMacCatLabel     nasmLabelError
endif
syn match   nasmInMacCatLabel   contained "\d\K\k*"lc=1
syn match   nasmInMacLabel      contained "\d}\k\+"lc=2
if !exists("nasm_no_warn")
    syn match  nasmInMacLblWarn   contained "%\(\($\+\|%\)[_~][._~]*\>\|{\($\+\|%\)[_~][._~]*}\)"
endif
syn match   nasmInMacPreProc    contained "^\s*%pop\>"hs=e-3
syn match   nasmInMacPreProc    contained "^\s*%\(push\|repl\)\>"hs=e-4 skipwhite nextgroup=@nasmGrpNxtCtx
"   structures cannot be nested (yet) -> use: 'keepend' and 're='
syn region  nasmInMacStrucDef   contained transparent matchgroup=nasmStructure keepend start="^\s*STRUCT\>"hs=e-5 end="^\s*ENDSTRUCT\>"re=e-9 contains=@nasmGrpCntnMacro
syn region  nasmInMacStrucDef   contained transparent matchgroup=nasmStructure keepend start="^\s*STRUC\>"hs=e-4  end="^\s*ENDSTRUC\>"re=e-8  contains=@nasmGrpCntnMacro
syn region  nasmInMacStrucDef   contained transparent matchgroup=nasmStructure keepend start="\<ISTRUCT\=\>" end="\<IEND\(STRUCT\=\)\=\>" contains=@nasmGrpCntnMacro,nasmInStructure
"   union types are not part of nasm (yet)
"syn region  nasmInMacStrucDef  contained transparent matchgroup=nasmStructure keepend start="^\s*UNION\>"hs=e-4 end="^\s*ENDUNION\>"re=e-8 contains=@nasmGrpCntnMacro
"syn region  nasmInMacStrucDef  contained transparent matchgroup=nasmStructure keepend start="\<IUNION\>" end="\<IEND\(UNION\)\=\>" contains=@nasmGrpCntnMacro,nasmInStructure
syn region  nasmInMacPreConDef  contained transparent matchgroup=nasmInMacPreCondit start="^\s*%ifnidni\>"hs=e-7 start="^\s*%if\(idni\|n\(ctx\|def\|idn\|num\|str\)\)\>"hs=e-6 start="^\s*%if\(ctx\|def\|idn\|nid\|num\|str\)\>"hs=e-5 start="^\s*%ifid\>"hs=e-4 start="^\s*%if\>"hs=e-2 end="%endif\>" contains=@nasmGrpCntnMacro,nasmInMacPreCondit,nasmInPreCondit
" Todo: allow STRUC/ISTRUC to be used inside preprocessor conditional block
syn match   nasmInMacPreCondit  contained transparent "ctx\s"lc=3 skipwhite nextgroup=@nasmGrpNxtCtx
syn match   nasmInMacPreCondit  contained "^\s*%elifctx\>"hs=e-7 skipwhite nextgroup=@nasmGrpNxtCtx
syn match   nasmInMacPreCondit  contained "^\s*%elifnctx\>"hs=e-8 skipwhite nextgroup=@nasmGrpNxtCtx
syn match   nasmInMacParamNum   contained "\<\d\+\.list\>"me=e-5
syn match   nasmInMacParamNum   contained "\<\d\+\.nolist\>"me=e-7
syn match   nasmInMacDirective  contained "\.\(no\)\=list\>"
syn match   nasmInMacMacro      contained transparent "macro\s"lc=5 skipwhite nextgroup=nasmStructureLabel
syn match   nasmInMacMacro      contained "^\s*%rotate\>"hs=e-6
syn match   nasmInMacParam      contained "%\([+-]\=\d\+\|{[+-]\=\d\+}\)"
"   nasm conditional macro operands/arguments
"   Todo: check feasebility; add too nasmGrpInMacros, etc.
"syn match   nasmInMacCond      contained "\<\(N\=\([ABGL]E\=\|[CEOSZ]\)\|P[EO]\=\)\>"
syn cluster nasmGrpInMacros     contains=nasmMacro,nasmInMacMacro,nasmInMacParam,nasmInMacParamNum,nasmInMacDirective,nasmInMacLabel,nasmInMacLblWarn,nasmInMacMemRef,nasmInMacPreConDef,nasmInMacPreCondit,nasmInMacPreProc,nasmInMacStrucDef

"   Context pre-procs that are better used inside a macro
if exists("nasm_ctx_outside_macro")
    syn region nasmPreConditDef   transparent matchgroup=nasmCtxPreCondit start="^\s*%ifnctx\>"hs=e-6 start="^\s*%ifctx\>"hs=e-5 end="%endif\>" contains=@nasmGrpCntnPreCon
    syn match  nasmCtxPreProc     "^\s*%pop\>"hs=e-3
    if exists("nasm_loose_syntax")
        syn match   nasmCtxLocLabel "%$\+\(\w\|[#.?@~]\)\k*\>"
    else
        syn match   nasmCtxLocLabel "%$\+\(\h\|[?@]\)\k*\>"
    endif
    syn match nasmCtxPreProc      "^\s*%\(push\|repl\)\>"hs=e-4 skipwhite nextgroup=@nasmGrpNxtCtx
    syn match nasmCtxPreCondit    contained transparent "ctx\s"lc=3 skipwhite nextgroup=@nasmGrpNxtCtx
    syn match nasmCtxPreCondit    contained "^\s*%elifctx\>"hs=e-7 skipwhite nextgroup=@nasmGrpNxtCtx
    syn match nasmCtxPreCondit    contained "^\s*%elifnctx\>"hs=e-8 skipwhite nextgroup=@nasmGrpNxtCtx
    if exists("nasm_no_warn")
        hi link nasmCtxPreCondit    nasmPreCondit
        hi link nasmCtxPreProc      nasmPreProc
        hi link nasmCtxLocLabel     nasmLocalLabel
    else
        hi link nasmCtxPreCondit    nasmPreProcWarn
        hi link nasmCtxPreProc      nasmPreProcWarn
        hi link nasmCtxLocLabel     nasmLabelWarn
    endif
endif

"  Conditional assembly
syn cluster nasmGrpCntnPreCon   contains=ALLBUT,@nasmGrpInComments,@nasmGrpInMacros,@nasmGrpInStrucs
syn region  nasmPreConditDef    transparent matchgroup=nasmPreCondit start="^\s*%ifnidni\>"hs=e-7 start="^\s*%if\(idni\|n\(def\|idn\|num\|str\)\)\>"hs=e-6 start="^\s*%if\(def\|idn\|nid\|num\|str\)\>"hs=e-5 start="^\s*%ifid\>"hs=e-4 start="^\s*%if\>"hs=e-2 end="%endif\>" contains=@nasmGrpCntnPreCon
syn match   nasmInPreCondit     contained "^\s*%el\(if\|se\)\>"hs=e-4
syn match   nasmInPreCondit     contained "^\s*%elifid\>"hs=e-6
syn match   nasmInPreCondit     contained "^\s*%elif\(def\|idn\|nid\|num\|str\)\>"hs=e-7
syn match   nasmInPreCondit     contained "^\s*%elif\(n\(def\|idn\|num\|str\)\|idni\)\>"hs=e-8
syn match   nasmInPreCondit     contained "^\s*%elifnidni\>"hs=e-9
syn cluster nasmGrpInPreCondits contains=nasmPreCondit,nasmInPreCondit,nasmCtxPreCondit
syn cluster nasmGrpPreCondits   contains=nasmPreConditDef,@nasmGrpInPreCondits,nasmCtxPreProc,nasmCtxLocLabel

"  Other pre-processor statements
syn match   nasmPreProc         "^\s*%\(rep\|use\)\>"hs=e-3
syn match   nasmPreProc         "^\s*%line\>"hs=e-4
syn match   nasmPreProc         "^\s*%\(clear\|error\|fatal\)\>"hs=e-5
syn match   nasmPreProc         "^\s*%\(endrep\|strlen\|substr\)\>"hs=e-6
syn match   nasmPreProc         "^\s*%\(exitrep\|warning\)\>"hs=e-7
syn match   nasmDefine          "^\s*%undef\>"hs=e-5
syn match   nasmDefine          "^\s*%\(assign\|define\)\>"hs=e-6
syn match   nasmDefine          "^\s*%i\(assign\|define\)\>"hs=e-7
syn match   nasmDefine          "^\s*%unmacro\>"hs=e-7
syn match   nasmInclude         "^\s*%include\>"hs=e-7
" Todo: Treat the line tail after %fatal, %error, %warning as text

"  Multiple pre-processor instructions on single line detection (obsolete)
"syn match   nasmPreProcError   +^\s*\([^\t "%';][^"%';]*\|[^\t "';][^"%';]\+\)%\a\+\>+
syn cluster nasmGrpPreProcs     contains=nasmMacroDef,@nasmGrpInMacros,@nasmGrpPreCondits,nasmPreProc,nasmDefine,nasmInclude,nasmPreProcWarn,nasmPreProcError



" Register Identifiers:
"  Register operands:
syn match   nasmGen08Register   "\<[A-D][HL]\>"
syn match   nasmGen16Register   "\<\([A-D]X\|[DS]I\|[BS]P\)\>"
syn match   nasmGen32Register   "\<E\([A-D]X\|[DS]I\|[BS]P\)\>"
syn match   nasmGen64Register   "\<R\([A-D]X\|[DS]I\|[BS]P\|[89]\|1[0-5]\|[89][WD]\|1[0-5][WD]\)\>"
syn match   nasmSegRegister     "\<[C-GS]S\>"
syn match   nasmSpcRegister     "\<E\=IP\>"
syn match   nasmFpuRegister     "\<ST\o\>"
syn match   nasmMmxRegister     "\<MM\o\>"
syn match   nasmSseRegister     "\<XMM\o\>"
syn match   nasmAvxRegister     "\<YMM\o\>"
syn match   nasmCtrlRegister    "\<CR\o\>"
syn match   nasmDebugRegister   "\<DR\o\>"
syn match   nasmTestRegister    "\<TR\o\>"
syn match   nasmRegisterError   "\<\(CR[15-9]\|DR[4-58-9]\|TR[0-28-9]\)\>"
syn match   nasmRegisterError   "\<X\=MM[8-9]\>"
syn match   nasmRegisterError   "\<ST\((\d)\|[8-9]\>\)"
syn match   nasmRegisterError   "\<E\([A-D][HL]\|[C-GS]S\)\>"
"  Memory reference operand (address):
syn match   nasmMemRefError     "[[\]]"
syn cluster nasmGrpCntnMemRef   contains=ALLBUT,@nasmGrpComments,@nasmGrpPreProcs,@nasmGrpInStrucs,nasmMemReference,nasmMemRefError
syn match   nasmInMacMemRef     contained "\[[^;[\]]\{-}\]" contains=@nasmGrpCntnMemRef,nasmPreProcError,nasmInMacLabel,nasmInMacLblWarn,nasmInMacParam
syn match   nasmMemReference    "\[[^;[\]]\{-}\]" contains=@nasmGrpCntnMemRef,nasmPreProcError,nasmCtxLocLabel



" Netwide Assembler Directives:
"  Compilation constants
syn keyword nasmConstant        __BITS__ __DATE__ __FILE__ __FORMAT__ __LINE__
syn keyword nasmConstant        __NASM_MAJOR__ __NASM_MINOR__ __NASM_VERSION__
syn keyword nasmConstant        __TIME__
"  Instruction modifiers
syn match   nasmInstructnError  "\<TO\>"
syn match   nasmInstrModifier   "\(^\|:\)\s*[C-GS]S\>"ms=e-1
syn keyword nasmInstrModifier   A16 A32 O16 O32
syn match   nasmInstrModifier   "\<F\(ADD\|MUL\|\(DIV\|SUB\)R\=\)\s\+TO\>"lc=5,ms=e-1
"   the 'to' keyword is not allowed for fpu-pop instructions (yet)
"syn match   nasmInstrModifier  "\<F\(ADD\|MUL\|\(DIV\|SUB\)R\=\)P\s\+TO\>"lc=6,ms=e-1
"  NAsm directives
syn keyword nasmRepeat          TIMES
syn keyword nasmDirective       ALIGN[B] INCBIN EQU NOSPLIT SPLIT
syn keyword nasmDirective       ABSOLUTE BITS SECTION SEGMENT
syn keyword nasmDirective       ENDSECTION ENDSEGMENT
syn keyword nasmDirective       __SECT__
"  Macro created standard directives: (requires %include)
syn case match
syn keyword nasmStdDirective    ENDPROC EPILOGUE LOCALS PROC PROLOGUE USES
syn keyword nasmStdDirective    ENDIF ELSE ELIF ELSIF IF
"syn keyword nasmStdDirective   BREAK CASE DEFAULT ENDSWITCH SWITCH
"syn keyword nasmStdDirective   CASE OF ENDCASE
syn keyword nasmStdDirective    DO ENDFOR ENDWHILE FOR REPEAT UNTIL WHILE EXIT
syn case ignore
"  Format specific directives: (all formats)
"  (excluded: extension directives to section, global, common and extern)
syn keyword nasmFmtDirective    ORG
syn keyword nasmFmtDirective    EXPORT IMPORT GROUP UPPERCASE SEG WRT
syn keyword nasmFmtDirective    LIBRARY
syn case match
syn keyword nasmFmtDirective    _GLOBAL_OFFSET_TABLE_ __GLOBAL_OFFSET_TABLE_
syn keyword nasmFmtDirective    ..start ..got ..gotoff ..gotpc ..plt ..sym
syn case ignore



" Standard Instructions:
syn match   nasmInstructnError  "\<\(F\=CMOV\|SET\)N\=\a\{0,2}\>"
syn keyword nasmInstructnError  CMPS MOVS LCS LODS STOS XLAT
syn match   nasmStdInstruction  "\<MOV\>"
syn match   nasmInstructnError  "\<MOV\s[^,;[]*\<CS\>\s*[^:]"he=e-1
syn match   nasmStdInstruction  "\<\(CMOV\|J\|SET\)\(N\=\([ABGL]E\=\|[CEOSZ]\)\|P[EO]\=\)\>"
syn match   nasmStdInstruction  "\<POP\>"
syn keyword nasmStdInstruction  AAA AAD AAM AAS ADC ADD AND
syn keyword nasmStdInstruction  BOUND BSF BSR BSWAP BT[C] BTR BTS
syn keyword nasmStdInstruction  CALL CBW CDQ CLC CLD CMC CMP CMPSB CMPSD CMPSW CMPSQ
syn keyword nasmStdInstruction  CMPXCHG CMPXCHG8B CPUID CWD[E] CQO
syn keyword nasmStdInstruction  DAA DAS DEC DIV ENTER
syn keyword nasmStdInstruction  IDIV IMUL INC INT[O] IRET[D] IRETW IRETQ
syn keyword nasmStdInstruction  JCXZ JECXZ JMP
syn keyword nasmStdInstruction  LAHF LDS LEA LEAVE LES LFS LGS LODSB LODSD LODSQ
syn keyword nasmStdInstruction  LODSW LOOP[E] LOOPNE LOOPNZ LOOPZ LSS
syn keyword nasmStdInstruction  MOVSB MOVSD MOVSW MOVSX MOVSQ MOVZX MUL NEG NOP NOT
syn keyword nasmStdInstruction  OR POPA[D] POPAW POPF[D] POPFW POPFQ
syn keyword nasmStdInstruction  PUSH[AD] PUSHAW PUSHF[D] PUSHFW PUSHFQ
syn keyword nasmStdInstruction  RCL RCR RETF RET[N] ROL ROR
syn keyword nasmStdInstruction  SAHF SAL SAR SBB SCASB SCASD SCASW
syn keyword nasmStdInstruction  SHL[D] SHR[D] STC STD STOSB STOSD STOSW STOSQ SUB
syn keyword nasmStdInstruction  TEST XADD XCHG XLATB XOR
syn keyword nasmStdInstruction  LFENCE MFENCE SFENCE


" System Instructions: (usually privileged)
"  Verification of pointer parameters
syn keyword nasmSysInstruction  ARPL LAR LSL VERR VERW
"  Addressing descriptor tables
syn keyword nasmSysInstruction  LLDT SLDT LGDT SGDT
"  Multitasking
syn keyword nasmSysInstruction  LTR STR
"  Coprocessing and Multiprocessing (requires fpu and multiple cpu's resp.)
syn keyword nasmSysInstruction  CLTS LOCK WAIT
"  Input and Output
syn keyword nasmInstructnError  INS OUTS
syn keyword nasmSysInstruction  IN INSB INSW INSD OUT OUTSB OUTSB OUTSW OUTSD
"  Interrupt control
syn keyword nasmSysInstruction  CLI STI LIDT SIDT
"  System control
syn match   nasmSysInstruction  "\<MOV\s[^;]\{-}\<CR\o\>"me=s+3
syn keyword nasmSysInstruction  HLT INVD LMSW
syn keyword nasmSseInstruction  PREFETCHT0 PREFETCHT1 PREFETCHT2 PREFETCHNTA
syn keyword nasmSseInstruction  RSM SFENCE SMSW SYSENTER SYSEXIT UD2 WBINVD
"  TLB (Translation Lookahead Buffer) testing
syn match   nasmSysInstruction  "\<MOV\s[^;]\{-}\<TR\o\>"me=s+3
syn keyword nasmSysInstruction  INVLPG

" Debugging Instructions: (privileged)
syn match   nasmDbgInstruction  "\<MOV\s[^;]\{-}\<DR\o\>"me=s+3
syn keyword nasmDbgInstruction  INT1 INT3 RDMSR RDTSC RDPMC WRMSR


" Floating Point Instructions: (requires FPU)
syn match   nasmFpuInstruction  "\<FCMOVN\=\([AB]E\=\|[CEPUZ]\)\>"
syn keyword nasmFpuInstruction  F2XM1 FABS FADD[P] FBLD FBSTP
syn keyword nasmFpuInstruction  FCHS FCLEX FCOM[IP] FCOMP[P] FCOS
syn keyword nasmFpuInstruction  FDECSTP FDISI FDIV[P] FDIVR[P] FENI FFREE
syn keyword nasmFpuInstruction  FIADD FICOM[P] FIDIV[R] FILD
syn keyword nasmFpuInstruction  FIMUL FINCSTP FINIT FIST[P] FISUB[R]
syn keyword nasmFpuInstruction  FLD[1] FLDCW FLDENV FLDL2E FLDL2T FLDLG2
syn keyword nasmFpuInstruction  FLDLN2 FLDPI FLDZ FMUL[P]
syn keyword nasmFpuInstruction  FNCLEX FNDISI FNENI FNINIT FNOP FNSAVE
syn keyword nasmFpuInstruction  FNSTCW FNSTENV FNSTSW FNSTSW
syn keyword nasmFpuInstruction  FPATAN FPREM[1] FPTAN FRNDINT FRSTOR
syn keyword nasmFpuInstruction  FSAVE FSCALE FSETPM FSIN FSINCOS FSQRT
syn keyword nasmFpuInstruction  FSTCW FSTENV FST[P] FSTSW FSUB[P] FSUBR[P]
syn keyword nasmFpuInstruction  FTST FUCOM[IP] FUCOMP[P]
syn keyword nasmFpuInstruction  FXAM FXCH FXTRACT FYL2X FYL2XP1


" Multi Media Xtension Packed Instructions: (requires MMX unit)
"  Standard MMX instructions: (requires MMX1 unit)
syn match   nasmInstructnError  "\<P\(ADD\|SUB\)U\=S\=[DQ]\=\>"
syn match   nasmInstructnError  "\<PCMP\a\{0,2}[BDWQ]\=\>"
syn keyword nasmMmxInstruction  EMMS MOVD MOVQ
syn keyword nasmMmxInstruction  PACKSSDW PACKSSWB PACKUSWB PADDB PADDD PADDW
syn keyword nasmMmxInstruction  PADDSB PADDSW PADDUSB PADDUSW PAND[N]
syn keyword nasmMmxInstruction  PCMPEQB PCMPEQD PCMPEQW PCMPGTB PCMPGTD PCMPGTW
syn keyword nasmMmxInstruction  PMACHRIW PMADDWD PMULHW PMULLW POR
syn keyword nasmMmxInstruction  PSLLD PSLLQ PSLLW PSRAD PSRAW PSRLD PSRLQ PSRLW
syn keyword nasmMmxInstruction  PSUBB PSUBD PSUBW PSUBSB PSUBSW PSUBUSB PSUBUSW
syn keyword nasmMmxInstruction  PUNPCKHBW PUNPCKHDQ PUNPCKHWD
syn keyword nasmMmxInstruction  PUNPCKLBW PUNPCKLDQ PUNPCKLWD PXOR
"  Extended MMX instructions: (requires MMX2/SSE unit)
syn keyword nasmMmxInstruction  MASKMOVQ MOVNTQ
syn keyword nasmMmxInstruction  PAVGB PAVGW PEXTRW PINSRW PMAXSW PMAXUB
syn keyword nasmMmxInstruction  PMINSW PMINUB PMOVMSKB PMULHUW PSADBW PSHUFW


" Streaming SIMD Extension Packed Instructions: (requires SSE unit)
" SSE1+2
syn match   nasmInstructnError  "\<CMP\A\{1,5}[PS][SD]\>"
syn match   nasmSseInstruction  "\<CMP\(N\=\(EQ\|L[ET]\)\|\(UN\)\=ORD\)\=[PS][SD]\>"
" ROUND is SSE4
syn match   nasmSseInstruction  "\%(ADD\|SUB\|MUL\|DIV\|SQRT\|MAX\|MIN\|ROUND\|\)[PS][SD]"
syn keyword nasmSseInstruction  RSQRTPS RSQRTSS
syn match   nasmSseInstruction  "\<\%(ANDN\?\|X\?OR\|CMP\)[PS][SD]\>"
syn match   nasmSseInstruction  "\<\%(SHUF\|UNPCK[HL]\)P[SD]\>"
syn match   nasmSseInstruction  "\<\%(U\?COM\)S[SD]\>"
syn match   nasmSseInstruction  "\<CVTT\?\([PS]\)[SD]2\1I\>"
syn match   nasmSseInstruction  "\<CVT\([PS]\)I2\1[SD]\>"
syn match   nasmSseInstruction  "\<CVTT\?P[SD]2DQ\>"
syn keyword nasmSseInstruction  CVTDQ2PD CVTDQ2PS CVTPS2PD CVTSS2SD CVTPD2PS CVTSD2SS
syn match   nasmSseInstruction  "\<MOV\%([AHLU]\|MSK\|NT\)P[SD]\>"
syn keyword nasmSseInstruction  MOVSS MOVSD MOVHLPS MOVLHPS
syn keyword nasmSseInstruction  MOVDQA MOVDQU MOVQ2DQ MOVDQ2Q MOVNTDQ MOVNTI
syn keyword nasmSseInstruction  PADDQ PSUBQ SHUFLW PSHUFHW PSHUFD 
syn keyword nasmSseInstruction  PSLLDQ PSRLDQ PUNPCKHQDQ PUNPCKLQDQ
syn keyword nasmSseInstruction  CLFLUSH PAUSE
syn keyword nasmSseInstruction  MASKMOVDQU

syn keyword nasmSseInstruction  CVTSI2SS CVTSS2SI CVTTPS2PI CVTTSS2SI
syn keyword nasmSseInstruction  FXRSTOR FXSAVE LDMXCSR
syn keyword nasmSseInstruction  MOVHLPS
syn keyword nasmSseInstruction  MOVLHPS MOVNTPS MOVSS
syn keyword nasmSseInstruction  RCPPS RCPSS RSQRTPS RSQRTSS
syn keyword nasmSseInstruction  SHUFPS STMXCSR
syn keyword nasmSseInstruction  UNPCKHPS UNPCKLPS
" SSE3
syn keyword nasmSseInstruction  FISTTP LDDQU ADDSUBPS ADDSUBPD
syn match   nasmSseInstruction  "\<\%(ADDSUB\|HADD\|HSUB\)P[DS]\>"
syn keyword nasmSseInstruction  MOVSHDUP MOVSLDUP MOVDDUP MONITOR MWAIT
syn keyword nasmSseInstruction  PMADDUBSW PMULHRSW PSHUFB PALIGNR
syn match   nasmSseInstruction  "\<PH\%(ADD\|SUB\)\%(S\?W\|D\)\>"
syn match   nasmSseInstruction  "\<P\%(ABS\|SIGN\)[BWD]\>"
" SSE4
syn keyword nasmSseInstruction  PMULLD PMULDQ DPPD PDDS MOVNTDQA
syn match   nasmSseInstruction  "\<BLENDV\?P[SD]\>"
syn keyword nasmSseInstruction  PBLENDVB PBLENDW
syn match   nasmSseInstruction  "\<PM\%(IN\|AX\)\%(U[WD]\|S[BD]\)\>"
syn keyword nasmSseInstruction  EXTRACTPS INSERTPS PEXTRW
syn match   nasmSseInstruction  "\<P\%(INS\|EXT\)R[BDQ]\>"
syn match   nasmSseInstruction  "\<PMOV[ZS]X\%(B[WDQ]\|W[DQ]\|DQ\)\>"
syn keyword nasmSseInstruction  MPSADBW PHMINPOSUW PTEST PACKUSDW PCMPEQQ PCMPGTQ
syn match   nasmSseInstruction  "\<PCMP[IE]STR[IM]\>"

syn match   nasmSseInstruction  "\<AES\%(DEC\|ENC\)\%(LAST\)\?\>"
syn keyword nasmSseInstruction  AESIMC AESKEYGENASSIST PCLMULQDQ


" Three Dimensional Now Packed Instructions: (requires 3DNow! unit)
syn keyword nasmNowInstruction  FEMMS PAVGUSB PF2ID PFACC PFADD PFCMPEQ PFCMPGE
syn keyword nasmNowInstruction  PFCMPGT PFMAX PFMIN PFMUL PFRCP PFRCPIT1
syn keyword nasmNowInstruction  PFRCPIT2 PFRSQIT1 PFRSQRT PFSUB[R] PI2FD
syn keyword nasmNowInstruction  PMULHRWA PREFETCH[W]

" Bit Manipulation Instructions: (requires bmi)
syn keyword nasmBmiInstruction  ANDN BEXTR BLSI BLSMSK BLSR BZHI
syn keyword nasmBmiInstruction  LZCNT MULX PDEP PEXT RORX SARX SHLX SHRX TZCNT

" Advanced Vector Extension Instructions: (requires AVX)
" promoted floating point
syn match   nasmAvxInstruction  "\<VMOV\%(\%(\%([AUHL]\|NT\|MSK\)P\|S\)[SD]\|\%(S[HL]\|D\)DUP\|\%(LH\|HL\)PS\|NTDQA\?\|DQ[AU]\|[DQ]\)\>"
syn keyword nasmAvxInstruction  LDDQU EXTRACTPS INSERTPS
syn match   nasmAvxInstruction  "\<V\%(ADD\|SUB\|MUL\|DIV\|MIN\|MAX\|CMP\|ROUND\)[PS][SD]\>"
syn match   nasmAvxInstruction  "\<V\%(ANDN\?\|X\?OR\|SHUF\|ADDSUB\|HADD\|HSUB\|BLENDV\?\|DP\)P[SD]\>"
syn match   nasmAvxInstruction  "\<V\%(RSQRT\|RCP\)[PS]S\>"
syn match   nasmAvxInstruction  "\<VUNPCK[LH]P[SD]\>"

" promoted integer
syn match   nasmAvxInstruction  "\<VPUNPCK[LH]\%(BW\|WD\|DQ\|QDQ\)\>"
syn match   nasmAvxInstruction  "\<VPACK[US]\%(WB\|DW\)\>"
syn match   nasmAvxInstruction  "\<VPCMP\%(\%(EQ\|GT\)[BWDQ]\|[IE]STR[IM]\)\>"
syn match   nasmAvxInstruction  "\<VPSHUF\%([DB]\|[HL]W\)\>"
syn match   nasmAvxInstruction  "\<VP\%(INSR\|EXTR\|ADD\|SUB\)[BWDQ]\>"
syn match   nasmAvxInstruction  "\<VP\%(ABS\|SIGN\|M\%(IN\|AX\)[US]\)[BWD]\>"
syn match   nasmAvxInstruction  "\<VP\%(ADD\|SUB\)U\?S[BW]\>"
syn match   nasmAvxInstruction  "\<VPH\%(ADD\|SUB\)\%(D\|S\?W\)\>"
syn match   nasmAvxInstruction  "\<VPMUL\%(L[WD]\|HU\?W\|U\?DQ\|HRSW\)\>"
syn keyword nasmAvxInstruction  VPAND[N] VPOR VPXOR VPMOVMSKB VPTEST
syn keyword nasmAvxInstruction  VPMADDWD VPSADBW VPMSADBW VMASKMOVDQU VPMADDUBSW VPALIGNR
syn keyword nasmAvxInstruction  VPHMINPOSUW VPBLENDVB VPBLENDW
syn match   nasmAvxInstruction  "\<VPS[RL]L[WDQ]\>"
syn keyword nasmAvxInstruction  VPSRAW VPSRAD
syn match   nasmAvxInstruction  "\<VPMOV[ZS]X\%(B[WDQ]\|W[DQ]\|DQ\)\>"

"promoted other
syn keyword nasmAvxInstruction  VLDMXCSR VSTMXCSR
syn match   nasmAvxInstruction  "\<VU\?COMIS[SD]\>"
syn match   nasmAvxInstruction  "\<VCVT\([PS]\)\%(S2\1D\|D2\1S\|I2\1[SD]\)\>"
syn match   nasmAvxInstruction  "\<VCVTT\?\([PS]\)[SD]2\1I\>"
syn match   nasmAvxInstruction  "\<VCVT\%(T\?P[SD]2DQ\|DQ2P[SD]\)\>"

"new + avx2
syn match   nasmAvxInstruction  "\<V\%(MASKMOV\|PERMIL\|TEST\)P[PS]\>"
syn keyword nasmAvxInstruction  VCVTPH2PS VCVTPS2PH VTESTPD VTESTPS VPBLENDD
syn match   nasmAvxInstruction  "\<VBROADCAST\%([IF]128\|S[SD]\)\>"
syn match   nasmAvxInstruction  "\<V\%(INSERT\|EXTRACT\)[IF]128\>"
syn keyword nasmAvxInstruction  VMASKMOVPS VMASKMOVPD VPMASKMOVD VPMASKMOVQ
syn match   nasmAvxInstruction  "\<VFN\?M\%(ADD\|SUB\)\%(132\|213\|231\)[PS][SD]\>"
syn match   nasmAvxInstruction  "\<VFM\%(ADDSUB\|SUBADD\)\%(132\|213\|231\)P[SD]\>"

syn keyword nasmAvxInstruction  VPBLENDD
syn match   nasmAvxInstruction  "\<VPERM\%(2[IF]128\|\%(IL\)\?P[SD]\|[DQ]\)\>"
syn match   nasmAvxInstruction  "\<VPS\%([RL]LV\?[DQ]\|RAV\?D\)\>"
syn match   nasmAvxInstruction  "\<VGATHER[DQ]\%([DQ]\|P[SD]\)\>"

" Unknown category
syn keyword nasmXXXInstruction  MOVBE
syn keyword nasmXXXInstruction  RDRAND RDSEED
syn keyword nasmXXXInstruction  PREFETCHW PREFETCHWT1 CLFLUSH CLFLUSHOPT
syn keyword nasmXXXInstruction  XSAVE[C] XSAVEOPT XRSTOR XGETBV



" Vendor Specific Instructions:
"  Cyrix instructions (requires Cyrix processor)
syn keyword nasmCrxInstruction  PADDSIW PAVEB PDISTIB PMAGW PMULHRW[C] PMULHRIW
syn keyword nasmCrxInstruction  PMVGEZB PMVLZB PMVNZB PMVZB PSUBSIW
syn keyword nasmCrxInstruction  RDSHR RSDC RSLDT SMINT SMINTOLD SVDC SVLDT SVTS
syn keyword nasmCrxInstruction  WRSHR
"  AMD instructions (requires AMD processor)
syn keyword nasmAmdInstruction  SYSCALL SYSRET


" Undocumented Instructions:
syn match   nasmUndInstruction  "\<POP\s[^;]*\<CS\>"me=s+3
syn keyword nasmUndInstruction  CMPXCHG486 IBTS ICEBP INT01 INT03 LOADALL
syn keyword nasmUndInstruction  LOADALL286 LOADALL386 SALC SMI UD1 UMOV XBTS



" Synchronize Syntax:
syn sync clear
syn sync minlines=50            "for multiple region nesting
syn sync match  nasmSync        grouphere nasmMacroDef "^\s*%i\=macro\>"me=s-1
syn sync match  nasmSync        grouphere NONE         "^\s*%endmacro\>"


" Define the default highlighting.
" Only when an item doesn't have highlighting yet

" Sub Links:
hi def link nasmInMacDirective  nasmDirective
hi def link nasmInMacLabel              nasmLocalLabel
hi def link nasmInMacLblWarn    nasmLabelWarn
hi def link nasmInMacMacro              nasmMacro
hi def link nasmInMacParam              nasmMacro
hi def link nasmInMacParamNum   nasmDecNumber
hi def link nasmInMacPreCondit  nasmPreCondit
hi def link nasmInMacPreProc    nasmPreProc
hi def link nasmInPreCondit     nasmPreCondit
hi def link nasmInStructure     nasmStructure
hi def link nasmStructureLabel  nasmStructure

" Comment Group:
hi def link nasmComment         Comment
hi def link nasmSpecialComment  SpecialComment
hi def link nasmInCommentTodo   Todo

" Constant Group:
hi def link nasmString          String
hi def link nasmCString String
hi def link nasmStringError     Error
hi def link nasmCStringEscape   SpecialChar
hi def link nasmCStringFormat   SpecialChar
hi def link nasmBinNumber               Number
hi def link nasmOctNumber               Number
hi def link nasmDecNumber               Number
hi def link nasmHexNumber               Number
hi def link nasmFltNumber               Float
hi def link nasmNumberError     Error

" Identifier Group:
hi def link nasmLabel           Identifier
hi def link nasmLocalLabel              Identifier
hi def link nasmSpecialLabel    Special
hi def link nasmLabelError              Error
hi def link nasmLabelWarn               Todo

" PreProc Group:
hi def link nasmPreProc         PreProc
hi def link nasmDefine          Define
hi def link nasmInclude         Include
hi def link nasmMacro           Macro
hi def link nasmPreCondit               PreCondit
hi def link nasmPreProcError    Error
hi def link nasmPreProcWarn     Todo

" Type Group:
hi def link nasmType            Type
hi def link nasmStorage         StorageClass
hi def link nasmStructure               Structure
hi def link nasmTypeError               Error

" Directive Group:
hi def link nasmConstant                Constant
hi def link nasmInstrModifier   Operator
hi def link nasmRepeat          Repeat
hi def link nasmDirective               Keyword
hi def link nasmStdDirective    Operator
hi def link nasmFmtDirective    Keyword

" Register Group:
hi def link nasmCtrlRegister    Special
hi def link nasmDebugRegister   Debug
hi def link nasmTestRegister    Special
hi def link nasmRegisterError   Error
hi def link nasmMemRefError     Error

" Instruction Group:
hi def link nasmStdInstruction  Statement
hi def link nasmSysInstruction  Statement
hi def link nasmDbgInstruction  Debug
hi def link nasmAvxInstruction  Statement
hi def link nasmBmiInstruction  Statement
hi def link nasmFpuInstruction  Statement
hi def link nasmMmxInstruction  Statement
hi def link nasmSseInstruction  Statement
hi def link nasmNowInstruction  Statement
hi def link nasmAmdInstruction  Special
hi def link nasmCrxInstruction  Special
hi def link nasmUndInstruction  Todo
hi def link nasmInstructnError  Error

" instructions that have only been added, not put in the correct category
hi def link nasmXXXInstruction  Statement


let b:current_syntax = "nasm"

" vim:ts=8 sw=4
